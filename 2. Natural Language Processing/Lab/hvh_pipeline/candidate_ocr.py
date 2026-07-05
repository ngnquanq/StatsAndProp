"""Candidate OCR engines for the HVH pipeline.

The CLC Kim Han Nom API cache is treated as the benchmark. Candidate model
outputs stay in separate cache files so they can be compared without replacing
benchmark results.

Usage:
    python candidate_ocr.py images/HVH_090/page_001.jpg
"""

import argparse
import json
from pathlib import Path

from PIL import Image

from local_ocr import DET_MODEL_NAME, _field, reading_order

HERE = Path(__file__).parent
CACHE_DIR = HERE / "cache"
DEFAULT_MODEL = "nxquang-al/finetuned-trocr-base-vietnamese-nom"
ORIENTATIONS = ("vertical", "rot_ccw", "rot_cw")


class CandidateOCRError(RuntimeError):
    pass


def _crop(page, box, orientation):
    crop = page.crop(tuple(box))
    if orientation == "rot_ccw":
        crop = crop.rotate(90, expand=True)
    elif orientation == "rot_cw":
        crop = crop.rotate(-90, expand=True)
    return crop


class TrocrOCR:
    """Page-level OCR interface compatible with run_pipeline.ocr_unit."""

    cache_suffix = "trocr"

    def __init__(self, model_name=DEFAULT_MODEL, device=None, orientation="rot_cw", batch_size=16):
        if orientation not in ORIENTATIONS:
            raise CandidateOCRError(f"orientation must be one of {ORIENTATIONS}, not {orientation!r}")
        try:
            import torch
            from paddleocr import TextDetection
            from transformers import TrOCRProcessor, VisionEncoderDecoderModel
        except ImportError as err:
            raise CandidateOCRError(
                "candidate TrOCR needs torch, transformers, paddleocr, and pillow installed"
            ) from err

        self.torch = torch
        self.device = device or ("cuda" if torch.cuda.is_available() else "cpu")
        paddle_device = "gpu" if self.device.startswith("cuda") else self.device
        self.orientation = orientation
        self.batch_size = batch_size
        self.det = TextDetection(model_name=DET_MODEL_NAME, device=paddle_device)
        try:
            self.processor = TrOCRProcessor.from_pretrained(model_name)
        except (ValueError, OSError):
            # checkpoints saved with old transformers lack image_processor_type
            from transformers import AutoTokenizer, ViTImageProcessor

            self.processor = TrOCRProcessor(
                image_processor=ViTImageProcessor.from_pretrained(model_name),
                tokenizer=AutoTokenizer.from_pretrained(model_name),
            )
        self.model = VisionEncoderDecoderModel.from_pretrained(model_name).to(self.device).eval()
        self.model_name = model_name

    def _boxes(self, image_path):
        import cv2

        img = cv2.imread(str(image_path))
        if img is None:
            raise CandidateOCRError(f"cannot read image {image_path}")
        det_res = self.det.predict(img)[0]
        polys = list(_field(det_res, "dt_polys"))
        boxes = []
        for poly in polys:
            xs = [p[0] for p in poly]
            ys = [p[1] for p in poly]
            boxes.append((min(xs), min(ys), max(xs), max(ys)))
        order = reading_order(boxes)
        return [[int(v) for v in boxes[i]] for i in order]

    def _recognize(self, crops):
        lines, scores = [], []
        for i in range(0, len(crops), self.batch_size):
            batch = crops[i:i + self.batch_size]
            pixel_values = self.processor(images=batch, return_tensors="pt").pixel_values.to(self.device)
            with self.torch.no_grad():
                generated_ids = self.model.generate(pixel_values, max_new_tokens=64)
            lines.extend(
                t.replace(" ", "")
                for t in self.processor.batch_decode(generated_ids, skip_special_tokens=True)
            )
            scores.extend([None] * len(batch))
        return lines, scores

    def ocr_page(self, image_path):
        image_path = Path(image_path)
        boxes = self._boxes(image_path)
        page = Image.open(image_path).convert("RGB")
        crops = [_crop(page, box, self.orientation) for box in boxes]
        lines, scores = self._recognize(crops)
        return {
            "image": str(image_path),
            "source": "trocr",
            "model": self.model_name,
            "orientation": self.orientation,
            "lines": lines,
            "scores": scores,
            "boxes": boxes,
        }


def cached_boxes(unit_code, stem):
    """Use existing PaddleOCR detector boxes for fast candidate benchmarking."""
    local_file = CACHE_DIR / unit_code / f"{stem}.local.json"
    if not local_file.exists():
        return None
    data = json.loads(local_file.read_text())
    return data.get("boxes")


def recognize_page_with_boxes(engine, image_path, boxes):
    page = Image.open(image_path).convert("RGB")
    crops = [_crop(page, box, engine.orientation) for box in boxes]
    lines, scores = engine._recognize(crops)
    return {
        "image": str(image_path),
        "source": "trocr",
        "model": engine.model_name,
        "orientation": engine.orientation,
        "lines": lines,
        "scores": scores,
        "boxes": boxes,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("images", nargs="*")
    parser.add_argument("--model", default=DEFAULT_MODEL)
    parser.add_argument("--device")
    parser.add_argument("--orientation", choices=ORIENTATIONS, default="rot_cw")
    args = parser.parse_args()

    if not args.images:
        parser.print_help()
        return

    engine = TrocrOCR(model_name=args.model, device=args.device, orientation=args.orientation)
    for path in args.images:
        result = engine.ocr_page(path)
        print(f"== {path}: {len(result['lines'])} lines ==")
        print(json.dumps(result, ensure_ascii=False, indent=1))


if __name__ == "__main__":
    main()
