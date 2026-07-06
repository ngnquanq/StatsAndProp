"""Detect red-ink reader punctuation (mực chu) on high-resolution page scans.

HVH manuscripts carry reader-added punctuation in red ink: a slanted dash
(độc điểm, mapped to 、) after clause breaks and a small circle (cú điểm /
khuyên, mapped to 。) after sentence ends. The OCR engines only see black
glyphs, so these marks are recovered separately with OpenCV and later merged
into the text by `run_pipeline.py --punct`.

Requires the /large/ scans (~2000px, `download_images.py --large`); on the
default ~700px images the marks are 2–4px and cannot be classified. Line
geometry and text come from the PaddleOCRv5 cache (`page_NNN.local.json`),
whose `boxes` are in small-image coordinates and are scaled up here.

Usage:
    python punct_detect.py HVH_090            # -> cache/HVH_090/page_NNN.punct.json
    python punct_detect.py HVH_090 --debug    # also write overlays to debug_punct/
    python punct_detect.py --selftest
"""

import json
import sys
from pathlib import Path

import cv2
import numpy as np

HERE = Path(__file__).parent
IMAGES_DIR = HERE / "images"
IMAGES_LARGE_DIR = HERE / "images_large"
CACHE_DIR = HERE / "cache"
DEBUG_DIR = HERE / "debug_punct"

# HSV red: hue wraps around 0, so mask two bands.
HSV_LO_1, HSV_HI_1 = (0, 60, 60), (18, 255, 255)
HSV_LO_2, HSV_HI_2 = (165, 60, 60), (180, 255, 255)

# Component-size window, expressed relative to a 2000px-wide reference image
# (marks are ~10–30px across there); rescaled by (width/2000)^2 at runtime.
REF_WIDTH = 2000
AREA_MIN_REF = 25
AREA_MAX_REF = 1500
BORDER_MARGIN_FRAC = 0.015  # ignore blobs hugging the image border (scan edges)

# circle-vs-stroke: khuyên rings (。) are round AND hollow; độc điểm dashes and
# solid dots (、) are either elongated or filled. Elongation is measured along
# the blob's own principal axis (minAreaRect), so a 45°-slanted dash is still
# seen as elongated; hollowness = red pixels / minAreaRect area.
CIRCLE_MAX_ELONGATION = 1.8   # minAreaRect long/short side ratio
CIRCLE_MAX_FILL = 0.6         # rings are hollow; solid dots fill their rect
MERGE_CHAR_FRAC = 0.6         # same-line marks closer than this (in character
                              # heights) are fragments of one physical mark


class PunctError(RuntimeError):
    pass


def red_mask(img_bgr):
    hsv = cv2.cvtColor(img_bgr, cv2.COLOR_BGR2HSV)
    mask = cv2.inRange(hsv, HSV_LO_1, HSV_HI_1) | cv2.inRange(hsv, HSV_LO_2, HSV_HI_2)
    return cv2.morphologyEx(mask, cv2.MORPH_OPEN, np.ones((2, 2), np.uint8))


def _classify(points):
    """points: Nx2 int array of (x, y) pixels of one component."""
    (_cx, _cy), (rw, rh), _angle = cv2.minAreaRect(points.astype(np.float32))
    long_side, short_side = max(rw, rh), max(min(rw, rh), 1.0)
    fill = len(points) / max(rw * rh, 1.0)
    if long_side / short_side <= CIRCLE_MAX_ELONGATION and fill <= CIRCLE_MAX_FILL:
        return "circle"
    return "stroke"


def detect_marks(img_bgr, line_boxes, line_texts):
    """Find red marks and anchor each to (line index, char index).

    line_boxes are (x0, y0, x1, y1) in the *same* coordinate space as img_bgr,
    ordered right-to-left like line_texts. Returns marks sorted by (line, char).
    """
    height, width = img_bgr.shape[:2]
    scale2 = (width / REF_WIDTH) ** 2
    area_min, area_max = AREA_MIN_REF * scale2, AREA_MAX_REF * scale2
    margin = int(min(width, height) * BORDER_MARGIN_FRAC)

    mask = red_mask(img_bgr)
    n, labels, stats, cents = cv2.connectedComponentsWithStats(mask)

    marks = []
    for i in range(1, n):
        x, y, w, h, area = (int(v) for v in stats[i][:5])
        if not (area_min <= area <= area_max):
            continue
        cx, cy = cents[i]
        if not (margin <= cx < width - margin and margin <= cy < height - margin):
            continue
        line_idx = _owning_line(cx, cy, line_boxes)
        if line_idx is None:
            continue
        x0, y0, _x1, y1 = line_boxes[line_idx]
        text = line_texts[line_idx]
        rel_y = (cy - y0) / max(y1 - y0, 1)
        # the mark sits beside the character it follows -> same relative slot
        char_idx = min(int(rel_y * len(text)), max(len(text) - 1, 0))
        ys, xs = np.where(labels[y:y + h, x:x + w] == i)
        points = np.column_stack((xs + x, ys + y))
        marks.append({
            "line": line_idx,
            "char": char_idx,
            "rel_y": round(rel_y, 4),
            "kind": _classify(points),
            "bbox": [x, y, x + w, y + h],
            "area": area,
            "_cy": cy,
        })
    marks = _merge_fragments(marks, line_boxes, line_texts)
    for m in marks:
        del m["_cy"]
    marks.sort(key=lambda m: (m["line"], m["char"], m["bbox"][1]))
    return marks


def _merge_fragments(marks, line_boxes, line_texts):
    """A broken ring or blotchy dash can surface as several components; keep
    only the largest of any same-line marks closer than MERGE_CHAR_FRAC of a
    character height."""
    kept = []
    for m in sorted(marks, key=lambda m: -m["area"]):
        _x0, y0, _x1, y1 = line_boxes[m["line"]]
        char_h = (y1 - y0) / max(len(line_texts[m["line"]]), 1)
        too_close = any(
            k["line"] == m["line"] and abs(k["_cy"] - m["_cy"]) < char_h * MERGE_CHAR_FRAC
            for k in kept
        )
        if not too_close:
            kept.append(m)
    return kept


def _owning_line(cx, cy, line_boxes):
    """Index of the line box containing (cx, cy), widened by half a column
    width so marks written beside the column edge still attach; None if the
    point belongs to no line (paper stains in the margins)."""
    best, best_dist = None, None
    for i, (x0, y0, x1, y1) in enumerate(line_boxes):
        pad = (x1 - x0) / 2
        if x0 - pad <= cx <= x1 + pad and y0 <= cy <= y1:
            dist = abs(cx - (x0 + x1) / 2)
            if best_dist is None or dist < best_dist:
                best, best_dist = i, dist
    return best


# ---- aligning geometry lines with another engine's text lines -----------------


def align_lines(geom_lines, text_lines, gap_cost=0.6):
    """Monotonic alignment between the detector's line texts and another
    engine's line texts (they usually agree but can split/merge differently).
    Returns {geometry line index -> text line index} for aligned pairs; lines
    consumed by a gap are absent. Substitution cost is the pairwise CER."""
    from verify import cer

    n, m = len(geom_lines), len(text_lines)
    dp = [[0.0] * (m + 1) for _ in range(n + 1)]
    for i in range(1, n + 1):
        dp[i][0] = i * gap_cost
    for j in range(1, m + 1):
        dp[0][j] = j * gap_cost
    for i in range(1, n + 1):
        for j in range(1, m + 1):
            sub = cer(str(text_lines[j - 1]), str(geom_lines[i - 1]))
            dp[i][j] = min(dp[i - 1][j - 1] + sub, dp[i - 1][j] + gap_cost, dp[i][j - 1] + gap_cost)

    mapping, i, j = {}, n, m
    while i > 0 and j > 0:
        sub = cer(str(text_lines[j - 1]), str(geom_lines[i - 1]))
        if abs(dp[i][j] - (dp[i - 1][j - 1] + sub)) < 1e-9:
            mapping[i - 1] = j - 1
            i, j = i - 1, j - 1
        elif abs(dp[i][j] - (dp[i - 1][j] + gap_cost)) < 1e-9:
            i -= 1
        else:
            j -= 1
    return mapping


# ---- merging marks into text -------------------------------------------------

MARK_CHAR = {"circle": "。", "stroke": "、"}
MIN_SENT_CHARS = 4  # splits shorter than this merge into the previous sentence:
                    # consecutive rings often flag proper names (one ring per
                    # character), not back-to-back sentence ends


def apply_marks(lines, marks):
    """Insert 。/、 into OCR line strings after the character each mark follows.

    lines may come from a different engine than the geometry (API text vs
    local boxes), so positions use each mark's rel_y against the target line's
    own length. Requires len(lines) to match the geometry the marks were
    detected on — callers check that.
    """
    out = [str(l) for l in lines]
    by_line = {}
    for m in marks:
        by_line.setdefault(m["line"], []).append(m)
    for i, line_marks in by_line.items():
        if not (0 <= i < len(out)) or not out[i]:
            continue
        text = out[i]
        # insert back-to-front so earlier positions stay valid
        for m in sorted(line_marks, key=lambda m: m["rel_y"], reverse=True):
            pos = min(int(m["rel_y"] * len(text)) + 1, len(text))
            text = text[:pos] + MARK_CHAR[m["kind"]] + text[pos:]
        out[i] = text
    return out


def split_sentences(punctuated_lines):
    """Join a page's punctuated lines (already in reading order) and split into
    sentences at 。 (the terminator stays with its sentence). Splits that carry
    no actual text (stray marks) are dropped; leading marks are trimmed."""
    joined = "".join(punctuated_lines)
    pieces, start = [], 0
    for pos, ch in enumerate(joined):
        if ch == "。":
            pieces.append(joined[start:pos + 1])
            start = pos + 1
    pieces.append(joined[start:])

    sentences = []
    for piece in pieces:
        piece = piece.strip().lstrip("。、")
        content = piece.strip("。、")
        if not content:
            continue
        if sentences and len(content) < MIN_SENT_CHARS:
            sentences[-1] += piece
        else:
            sentences.append(piece)
    return sentences


# ---- per-page driver ---------------------------------------------------------


def load_geometry(unit_code, stem):
    """(large image, scaled line boxes, line texts) for one page, or None when
    the page lacks either the large scan or the .local.json geometry."""
    local_file = CACHE_DIR / unit_code / f"{stem}.local.json"
    large_image = IMAGES_LARGE_DIR / unit_code / f"{stem}.jpg"
    small_image = IMAGES_DIR / unit_code / f"{stem}.jpg"
    if not (local_file.exists() and large_image.exists() and small_image.exists()):
        return None

    cached = json.loads(local_file.read_text())
    boxes, texts = cached.get("boxes"), cached.get("lines")
    if not boxes or not texts or len(boxes) != len(texts):
        return None

    img = cv2.imread(str(large_image))
    small = cv2.imread(str(small_image))
    if img is None or small is None:
        return None
    scale = img.shape[1] / small.shape[1]
    scaled = [[v * scale for v in box] for box in boxes]
    return img, scaled, texts, scale


def detect_unit(unit_code, debug=False, force=False):
    cache_dir = CACHE_DIR / unit_code
    large_dir = IMAGES_LARGE_DIR / unit_code
    if not large_dir.exists():
        raise PunctError(
            f"{unit_code}: no high-res scans — run `python download_images.py --large {unit_code}` first"
        )

    done = skipped = 0
    for large_image in sorted(large_dir.glob("page_*.jpg")):
        stem = large_image.stem
        out_file = cache_dir / f"{stem}.punct.json"
        if out_file.exists() and not force and not debug:
            done += 1
            continue
        geom = load_geometry(unit_code, stem)
        if geom is None:
            print(f"  {stem}: missing .local.json geometry or images, skipping")
            skipped += 1
            continue
        img, boxes, texts, scale = geom
        marks = detect_marks(img, boxes, texts)
        out_file.write_text(json.dumps({
            "image_large": str(large_image.relative_to(HERE)),
            "scale": round(scale, 4),
            "marks": marks,
        }, ensure_ascii=False, indent=1))
        kinds = [m["kind"] for m in marks]
        print(f"  {stem}: {len(marks)} marks ({kinds.count('circle')} circle, {kinds.count('stroke')} stroke)")
        if debug:
            _write_overlay(unit_code, stem, img, boxes, marks)
        done += 1
    if not done and not skipped:
        raise PunctError(f"{unit_code}: no page_*.jpg under {large_dir}")
    return done


def _write_overlay(unit_code, stem, img, boxes, marks):
    vis = img.copy()
    for x0, y0, x1, y1 in boxes:
        cv2.rectangle(vis, (int(x0), int(y0)), (int(x1), int(y1)), (180, 180, 180), 1)
    for m in marks:
        x0, y0, x1, y1 = m["bbox"]
        color = (0, 200, 0) if m["kind"] == "circle" else (255, 0, 0)
        cv2.rectangle(vis, (x0 - 4, y0 - 4), (x1 + 4, y1 + 4), color, 2)
        cv2.putText(vis, f"{m['line']}:{m['char']}", (x0 + 6, y0 - 6),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.45, color, 1)
    out = DEBUG_DIR / unit_code / f"{stem}.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    cv2.imwrite(str(out), vis)


# ---- selftest ----------------------------------------------------------------


def selftest():
    """Synthetic page: one red ring + one slanted red dash inside a line box,
    plus border noise that must be rejected."""
    img = np.full((2000, 1400, 3), 210, np.uint8)
    red = (40, 40, 200)  # BGR
    # line box for a 10-char column
    box = (600, 100, 700, 1900)
    # ring (hollow circle) beside char 2: rel_y = 0.25 -> char 2 of 10
    cv2.circle(img, (660, 550), 14, red, 3)
    # slanted dash beside char 7: rel_y = 0.75
    cv2.line(img, (640, 1440), (668, 1462), red, 6)
    # border noise: red smudge at the very edge (must be dropped)
    cv2.circle(img, (8, 1000), 12, red, -1)
    # margin stain far from any line box (must be dropped)
    cv2.circle(img, (200, 1000), 10, red, -1)

    marks = detect_marks(img, [box], ["零一二三四五六七八九"])
    assert len(marks) == 2, f"expected 2 marks, got {len(marks)}: {marks}"
    ring, dash = marks
    assert ring["kind"] == "circle", ring
    assert dash["kind"] == "stroke", dash
    assert ring["char"] == 2, ring
    assert dash["char"] == 7, dash
    print("selftest OK:", [(m["kind"], m["char"]) for m in marks])


def main():
    argv = sys.argv[1:]
    if "--selftest" in argv:
        selftest()
        return
    debug = "--debug" in argv
    if debug:
        argv.remove("--debug")
    force = "--force" in argv
    if force:
        argv.remove("--force")

    from works import select
    for _work, unit_code, _vol in select(argv):
        if not (IMAGES_LARGE_DIR / unit_code).exists():
            continue
        print(f"== {unit_code} ==")
        detect_unit(unit_code, debug=debug, force=force)


if __name__ == "__main__":
    main()
