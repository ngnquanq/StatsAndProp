"""Benchmark TrOCR Nôm candidate models against CLC API gold.

Uses the detection boxes already cached in page_NNN.local.json (reading order),
crops rectangles from the page images, tries selected orientations, and reports
per-model page CER against the website/API benchmark cache.
"""

import argparse
import json
from pathlib import Path

from candidate_ocr import DEFAULT_MODEL, ORIENTATIONS, TrocrOCR, cached_boxes, recognize_page_with_boxes
from verify import API_PAGE_RE, cer

HERE = Path(__file__).parent


def gold_pages(unit_code):
    cache_dir = HERE / "cache" / unit_code
    pages = []
    for path in sorted(cache_dir.glob("page_*.json")):
        if not API_PAGE_RE.fullmatch(path.name):
            continue
        pages.append(path.stem)
    return pages


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("unit", nargs="?", default="HVH_090")
    parser.add_argument("--model", default=DEFAULT_MODEL)
    parser.add_argument("--device")
    parser.add_argument("--orientation", choices=ORIENTATIONS, action="append")
    args = parser.parse_args()

    pages = gold_pages(args.unit)
    if not pages:
        raise SystemExit(f"{args.unit}: no CLC/API benchmark cache found")

    for orientation in args.orientation or ORIENTATIONS:
        engine = TrocrOCR(model_name=args.model, device=args.device, orientation=orientation)
        total_ref = total_dist = 0.0
        per_page = []
        for stem in pages:
            gold_file = HERE / "cache" / args.unit / f"{stem}.json"
            gold = "".join(json.loads(gold_file.read_text())["lines"])
            image = HERE / "images" / args.unit / f"{stem}.jpg"
            boxes = cached_boxes(args.unit, stem)
            if boxes is None:
                result = engine.ocr_page(image)
            else:
                result = recognize_page_with_boxes(engine, image, boxes)
            hyp = "".join(result["lines"])
            page_cer = cer(gold, hyp)
            per_page.append(page_cer)
            total_ref += len(gold)
            total_dist += page_cer * len(gold)
        print(
            f"{args.model} [{orientation}]: mean page CER {sum(per_page) / len(per_page):.3f} "
            f"(weighted {total_dist / total_ref:.3f}); pages: "
            + " ".join(f"{c:.2f}" for c in per_page),
            flush=True,
        )


if __name__ == "__main__":
    main()
