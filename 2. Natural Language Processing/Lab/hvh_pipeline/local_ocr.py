"""Local OCR engine: fine-tuned PaddleOCRv5 recognition, no API rate limit.

Recognition weights come from the HCMUS HF space
https://huggingface.co/spaces/MinhDS/Fine-tuned-PaddleOCRv5 (PP-OCRv5_server_rec
fine-tuned on ~400K Sino-Nom line images, 4,865-char charset baked into
inference.yml). Detection is the stock PP-OCRv5_server_det model, which
PaddleOCR downloads on first use. See HANDOFF.md for the GPU setup.

A page is OCR'd in three steps:
  1. text-line detection (DBNet) -> one box per line;
  2. reading-order sort -- classical layout is vertical: columns right-to-left,
     top-to-bottom within a column (horizontal pages are handled too);
  3. recognition of each line crop with the fine-tuned weights.

Usage:
    python local_ocr.py --download-models    # fetch weights into models/
    python local_ocr.py --selftest           # geometry tests, no paddle needed
    python local_ocr.py IMAGE ...            # smoke test: print OCR of images
"""

import json
import sys
from pathlib import Path

import requests

HERE = Path(__file__).parent
MODELS_DIR = HERE / "models"
REC_MODEL_DIR = MODELS_DIR / "PP-OCRv5_server_rec_finetuned"

HF_SPACE = "https://huggingface.co/spaces/MinhDS/Fine-tuned-PaddleOCRv5/resolve/main"
# The space's repo root holds the exported inference model (the same files as
# inside PP-OCRv5_server_rec_infer.tar); inference.yml carries the charset.
REC_MODEL_FILES = ["inference.json", "inference.pdiparams", "inference.yml"]

DET_MODEL_NAME = "PP-OCRv5_server_det"
REC_MODEL_NAME = "PP-OCRv5_server_rec"


class LocalOCRError(RuntimeError):
    pass


# ---- model download ---------------------------------------------------------

def _fetch(url, dest):
    tmp = dest.with_name(dest.name + ".part")
    with requests.get(url, stream=True, timeout=300) as resp:
        resp.raise_for_status()
        total = int(resp.headers.get("content-length") or 0)
        done = 0
        with open(tmp, "wb") as fh:
            for chunk in resp.iter_content(1 << 20):
                fh.write(chunk)
                done += len(chunk)
                if total:
                    print(f"\r  {dest.name}: {done * 100 // total}% of {total // (1 << 20)} MB", end="")
        print()
    tmp.rename(dest)


def download_models():
    """Fetch the fine-tuned recognition model; warm up the stock detector."""
    REC_MODEL_DIR.mkdir(parents=True, exist_ok=True)
    for name in REC_MODEL_FILES:
        dest = REC_MODEL_DIR / name
        if dest.exists() and dest.stat().st_size > 0:
            print(f"  {name}: already downloaded")
            continue
        _fetch(f"{HF_SPACE}/{name}", dest)
    print(f"recognition model ready in {REC_MODEL_DIR}")

    try:
        from paddleocr import TextDetection
    except ImportError:
        print(f"paddleocr not installed — {DET_MODEL_NAME} will download on first run")
        return
    TextDetection(model_name=DET_MODEL_NAME)  # triggers its own download
    print("detection model ready")


# ---- reading order ----------------------------------------------------------

def _lanes(intervals, descending):
    """Group index intervals into lanes (columns/rows) by >50% overlap.

    Returns lanes in scan order (right-to-left when descending): each lane is
    [lo, hi, [indices]] and grows to cover its members.
    """
    lanes = []
    order = sorted(range(len(intervals)),
                   key=lambda i: intervals[i][0] + intervals[i][1], reverse=descending)
    for i in order:
        lo, hi = intervals[i]
        for lane in lanes:
            overlap = min(hi, lane[1]) - max(lo, lane[0])
            if overlap > 0.5 * min(hi - lo, lane[1] - lane[0]):
                lane[0], lane[1] = min(lane[0], lo), max(lane[1], hi)
                lane[2].append(i)
                break
        else:
            lanes.append([lo, hi, [i]])
    return lanes


def reading_order(boxes):
    """Return the indices of (x0, y0, x1, y1) line boxes in reading order.

    Lines taller than wide (the classical vertical layout) read as columns
    right-to-left, top-to-bottom within a column; otherwise as rows
    top-to-bottom, left-to-right within a row — matching the order the CLC
    API returns, so the two caches are comparable line by line.
    """
    if not boxes:
        return []
    widths = sorted(b[2] - b[0] for b in boxes)
    heights = sorted(b[3] - b[1] for b in boxes)
    vertical = heights[len(heights) // 2] > widths[len(widths) // 2]
    if vertical:
        lanes = _lanes([(b[0], b[2]) for b in boxes], descending=True)
        within = lambda i: boxes[i][1]
    else:
        lanes = _lanes([(b[1], b[3]) for b in boxes], descending=False)
        within = lambda i: boxes[i][0]
    return [i for lane in lanes for i in sorted(lane[2], key=within)]


# ---- the engine --------------------------------------------------------------

def _order_quad(pts):
    """Order 4 corner points as top-left, top-right, bottom-right, bottom-left."""
    import numpy as np
    pts = np.asarray(pts, dtype="float32")
    s = pts.sum(axis=1)
    d = (pts[:, 1] - pts[:, 0])
    return np.float32([pts[s.argmin()], pts[d.argmin()], pts[s.argmax()], pts[d.argmax()]])


def _field(res, key):
    """Read a field from a PaddleOCR module result (dict-like or Result object)."""
    try:
        return res[key]
    except (KeyError, TypeError):
        return res.json["res"][key]


class LocalOCR:
    """Same page-level interface as KimHanNomClient: ocr_page(path) -> dict."""

    def __init__(self, device=None, batch_size=16):
        if not all((REC_MODEL_DIR / f).exists() for f in REC_MODEL_FILES):
            raise LocalOCRError(
                f"fine-tuned model missing in {REC_MODEL_DIR} — "
                "run: python local_ocr.py --download-models"
            )
        from paddleocr import TextDetection, TextRecognition
        kw = {"device": device} if device else {}
        self.det = TextDetection(model_name=DET_MODEL_NAME, **kw)
        self.rec = TextRecognition(model_name=REC_MODEL_NAME,
                                   model_dir=str(REC_MODEL_DIR), **kw)
        self.batch_size = batch_size

    def _crop(self, img, poly):
        """Perspective-crop one detected line; rotate vertical lines flat.

        Same convention as PaddleOCR's get_rotate_crop_image: a crop 1.5x
        taller than wide is a vertical text line and is rotated 90° CCW so the
        first (top) character ends up leftmost for the recognizer.
        """
        import cv2
        import numpy as np
        pts = np.asarray(poly, dtype="float32")
        if len(pts) != 4:
            pts = cv2.boxPoints(cv2.minAreaRect(pts))
        pts = _order_quad(pts)
        w = int(max(np.linalg.norm(pts[0] - pts[1]), np.linalg.norm(pts[2] - pts[3])))
        h = int(max(np.linalg.norm(pts[0] - pts[3]), np.linalg.norm(pts[1] - pts[2])))
        w, h = max(w, 1), max(h, 1)
        dst = np.float32([[0, 0], [w, 0], [w, h], [0, h]])
        crop = cv2.warpPerspective(img, cv2.getPerspectiveTransform(pts, dst), (w, h),
                                   flags=cv2.INTER_CUBIC, borderMode=cv2.BORDER_REPLICATE)
        if h >= w * 1.5:
            crop = np.rot90(crop)
        return crop

    def ocr_page(self, image_path):
        import cv2
        img = cv2.imread(str(image_path))
        if img is None:
            raise LocalOCRError(f"cannot read image {image_path}")

        det_res = self.det.predict(img)[0]
        polys = list(_field(det_res, "dt_polys"))
        if not polys:
            return {"image": str(image_path), "source": "local", "lines": []}

        boxes = []
        for poly in polys:
            xs = [p[0] for p in poly]
            ys = [p[1] for p in poly]
            boxes.append((min(xs), min(ys), max(xs), max(ys)))
        order = reading_order(boxes)

        crops = [self._crop(img, polys[i]) for i in order]
        lines, scores = [], []
        for res in self.rec.predict(crops, batch_size=self.batch_size):
            lines.append(str(_field(res, "rec_text")))
            scores.append(round(float(_field(res, "rec_score")), 4))
        return {
            "image": str(image_path),
            "source": "local",
            "lines": lines,
            "scores": scores,
            "boxes": [[int(v) for v in boxes[i]] for i in order],
        }


# ---- selftest / smoke test ---------------------------------------------------

def selftest():
    # three vertical columns, right one first, top-to-bottom inside each
    cols = [
        (300, 10, 330, 200), (300, 210, 330, 400),   # right column
        (200, 10, 230, 400),                          # middle
        (100, 10, 130, 150), (100, 160, 130, 400),   # left
    ]
    assert reading_order(cols) == [0, 1, 2, 3, 4], reading_order(cols)

    # shuffled input, same geometry: right top/bottom, middle, left top/bottom
    shuffled = [cols[3], cols[1], cols[4], cols[0], cols[2]]
    assert reading_order(shuffled) == [3, 1, 4, 0, 2], reading_order(shuffled)

    # horizontal layout: rows top-to-bottom, left-to-right
    rows = [(10, 100, 400, 130), (10, 10, 200, 40), (220, 10, 400, 40)]
    assert reading_order(rows) == [1, 2, 0], reading_order(rows)

    # slightly ragged columns still group (60% x-overlap)
    ragged = [(298, 10, 328, 200), (305, 210, 335, 400), (200, 10, 230, 400)]
    assert reading_order(ragged) == [0, 1, 2], reading_order(ragged)

    quad = _order_quad([[10, 0], [0, 10], [0, 0], [10, 10]])
    assert quad.tolist() == [[0, 0], [10, 0], [10, 10], [0, 10]], quad
    print("selftest OK")


def main():
    args = sys.argv[1:]
    if "--download-models" in args:
        download_models()
    elif "--selftest" in args:
        selftest()
    elif args:
        engine = LocalOCR()
        for path in args:
            result = engine.ocr_page(path)
            print(f"== {path}: {len(result['lines'])} lines ==")
            print(json.dumps(result, ensure_ascii=False, indent=1))
    else:
        print(__doc__)


if __name__ == "__main__":
    main()
