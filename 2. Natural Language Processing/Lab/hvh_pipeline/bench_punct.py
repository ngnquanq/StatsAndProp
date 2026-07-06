"""Benchmark red-ink punctuation segmentation against the CLC sentence splitter.

For every page that has both an API text cache (page_NNN.json) and red-mark
detections (page_NNN.punct.json, see punct_detect.py), send the page's joined
text to the CLC /separate-sentences endpoint (cached as page_NNN.sentsep.json)
and compare the two segmentations: sentence counts and boundary agreement
(precision/recall/F1 of CV boundaries vs CLC boundaries, ±TOLERANCE chars in
the punctuation-free page string).

The CLC splitter is a linguistic model and the red marks are a human reader's
— neither is gold truth, so agreement is a consistency signal, not accuracy.

Usage:
    python bench_punct.py HVH_090       # -> punct_report.tsv
"""

import json
import re
import sys
import time
from pathlib import Path

from works import select

HERE = Path(__file__).parent
CACHE_DIR = HERE / "cache"
REPORT = HERE / "punct_report.tsv"
TOLERANCE = 2
PUNCT_CHARS = "。、，。？！：；,.?!:; \n\t"


def _strip_boundaries(sentences):
    """(punctuation-free text, sorted boundary offsets) for a sentence list."""
    clean_parts, boundaries, offset = [], [], 0
    for sent in sentences:
        clean = re.sub(f"[{re.escape(PUNCT_CHARS)}]", "", str(sent))
        if not clean:
            continue
        offset += len(clean)
        clean_parts.append(clean)
        boundaries.append(offset)
    return "".join(clean_parts), boundaries[:-1]  # last offset = end of text


def _clc_sentences(response):
    """Pull the sentence list out of whatever shape the endpoint returns."""
    if isinstance(response, list):
        if all(isinstance(s, str) for s in response):
            return response
    if isinstance(response, dict):
        for key in ("result", "result_text", "sentences", "text", "data"):
            value = response.get(key)
            if isinstance(value, list) and all(isinstance(s, str) for s in value):
                return value
            if isinstance(value, str):
                return [s for s in re.split(r"[\n。]", value) if s.strip()]
    if isinstance(response, str):
        return [s for s in re.split(r"[\n。]", response) if s.strip()]
    raise ValueError(f"unrecognised /separate-sentences response: {str(response)[:200]}")


def _boundary_prf(cv_bounds, clc_bounds):
    matched = 0
    unused = list(clc_bounds)
    for b in cv_bounds:
        hit = next((c for c in unused if abs(c - b) <= TOLERANCE), None)
        if hit is not None:
            matched += 1
            unused.remove(hit)
    precision = matched / len(cv_bounds) if cv_bounds else 0.0
    recall = matched / len(clc_bounds) if clc_bounds else 0.0
    f1 = 2 * precision * recall / (precision + recall) if precision + recall else 0.0
    return precision, recall, f1


def bench_unit(client, unit_code):
    from run_pipeline import DELAY_S, _punct_sentences

    cache_dir = CACHE_DIR / unit_code
    rows = []
    for punct_file in sorted(cache_dir.glob("page_*.punct.json")):
        stem = punct_file.name.split(".")[0]
        api_file = cache_dir / f"{stem}.json"
        if not api_file.exists():
            continue
        api = json.loads(api_file.read_text())
        api["_page_stem"] = stem
        text = "".join(str(l) for l in api["lines"])
        if not text:
            continue

        cv_sents = _punct_sentences(unit_code, api)
        if cv_sents is None:
            print(f"  {stem}: punct segmentation not applicable (line mismatch), skipping")
            continue

        sentsep_file = cache_dir / f"{stem}.sentsep.json"
        if sentsep_file.exists():
            response = json.loads(sentsep_file.read_text())
        else:
            response = client.separate_sentences(text)
            sentsep_file.write_text(json.dumps(response, ensure_ascii=False, indent=1))
            time.sleep(DELAY_S)
        clc_sents = _clc_sentences(response)

        marks = json.loads(punct_file.read_text())["marks"]
        kinds = [m["kind"] for m in marks]
        _cv_text, cv_bounds = _strip_boundaries(cv_sents)
        _clc_text, clc_bounds = _strip_boundaries(clc_sents)
        precision, recall, f1 = _boundary_prf(cv_bounds, clc_bounds)
        rows.append((
            unit_code, stem, len(marks), kinds.count("circle"), kinds.count("stroke"),
            len(cv_sents), len(clc_sents),
            round(precision, 3), round(recall, 3), round(f1, 3),
        ))
        print(
            f"  {stem}: marks={len(marks)} sent_cv={len(cv_sents)} sent_clc={len(clc_sents)} "
            f"boundary P={precision:.2f} R={recall:.2f} F1={f1:.2f}"
        )
    return rows


def main():
    from ocr_client import KimHanNomClient

    client = KimHanNomClient()
    rows = []
    for _work, unit_code, _vol in select(sys.argv[1:]):
        if not (CACHE_DIR / unit_code).exists():
            continue
        print(f"== {unit_code} ==")
        rows.extend(bench_unit(client, unit_code))

    if not rows:
        print("no pages have both API text and punct.json — run punct_detect.py first")
        return
    header = ("unit", "page", "marks", "circles", "strokes",
              "sent_cv", "sent_clc", "boundary_P", "boundary_R", "boundary_F1")
    with open(REPORT, "w", encoding="utf-8") as fh:
        fh.write("\t".join(header) + "\n")
        for row in rows:
            fh.write("\t".join(str(v) for v in row) + "\n")
    mean_f1 = sum(r[-1] for r in rows) / len(rows)
    print(f"\n{REPORT.name}: {len(rows)} pages, mean boundary F1 = {mean_f1:.3f}")


if __name__ == "__main__":
    main()
