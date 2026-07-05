"""Benchmark NomNaOCR candidates against the CLC/API benchmark cache."""

import argparse
import json
from pathlib import Path

from nomnaocr_ocr import MODELS, ORIENTATIONS, NomNaOCR, NomNaOCRError, recognize_page_with_boxes
from verify import API_PAGE_RE, cer

HERE = Path(__file__).parent


def gold_pages(unit_code):
    cache_dir = HERE / "cache" / unit_code
    return [path.stem for path in sorted(cache_dir.glob("page_*.json")) if API_PAGE_RE.fullmatch(path.name)]


def cached_boxes(unit_code, stem):
    local_file = HERE / "cache" / unit_code / f"{stem}.local.json"
    if not local_file.exists():
        return None
    return json.loads(local_file.read_text(encoding="utf-8")).get("boxes")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("unit", nargs="?", default="HVH_090")
    parser.add_argument("--nomnaocr-model", choices=MODELS, action="append")
    parser.add_argument("--orientation", choices=ORIENTATIONS, action="append")
    parser.add_argument("--write-cache", action="store_true")
    parser.add_argument("--candidate-name")
    args = parser.parse_args()

    pages = gold_pages(args.unit)
    if not pages:
        raise SystemExit(f"{args.unit}: no CLC/API benchmark cache found")

    for model_name in args.nomnaocr_model or ("sc_transformer",):
        for orientation in args.orientation or ORIENTATIONS:
            try:
                engine = NomNaOCR(model=model_name, orientation=orientation)
            except NomNaOCRError as err:
                raise SystemExit(str(err)) from err
            total_ref = total_dist = 0.0
            per_page = []
            for stem in pages:
                gold_file = HERE / "cache" / args.unit / f"{stem}.json"
                gold = "".join(json.loads(gold_file.read_text(encoding="utf-8"))["lines"])
                image = HERE / "images" / args.unit / f"{stem}.jpg"
                boxes = cached_boxes(args.unit, stem)
                if boxes is None:
                    raise SystemExit(
                        f"{args.unit}/{stem}: missing .local.json boxes; run "
                        f"conda run -n hvh python run_pipeline.py --engine local {args.unit}"
                    )
                result = recognize_page_with_boxes(engine, image, boxes)
                hyp = "".join(result["lines"])
                page_cer = cer(gold, hyp)
                per_page.append(page_cer)
                total_ref += len(gold)
                total_dist += page_cer * len(gold)

                if args.write_cache:
                    suffix = args.candidate_name or f"nomnaocr_{model_name}_{orientation}"
                    out = HERE / "cache" / args.unit / f"{stem}.{suffix}.json"
                    out.write_text(json.dumps(result, ensure_ascii=False, indent=1), encoding="utf-8")

            print(
                f"NomNaOCR {model_name} [{orientation}]: mean page CER {sum(per_page) / len(per_page):.3f} "
                f"(weighted {total_dist / max(total_ref, 1):.3f}); pages: "
                + " ".join(f"{c:.2f}" for c in per_page),
                flush=True,
            )


if __name__ == "__main__":
    main()
