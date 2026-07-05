"""Stages 2+3: OCR every downloaded page, then write the HVH deliverables.

Per OutputRequirement.pdf (section B, HVH):
    output/HVH_xxx/HVH_xxx_raw.txt   — raw OCR text, page order
    output/HVH_xxx/HVH_xxx_seg.tsv   — [sentence_id]\t[sentence]
Multi-volume works nest chapters: output/HVH_107/HVH_107_01/HVH_107_01_raw.txt ...

Each page's OCR result is cached as JSON under cache/<unit>/page_NNN.json so the
run can resume and the output files can be regenerated without re-OCR.

Usage:
    python run_pipeline.py                  # all works with downloaded images
    python run_pipeline.py HVH_090 ...       # given work/unit codes
    python run_pipeline.py --person P1       # this person's assigned share
"""

import json
import sys
import time
from pathlib import Path

from ocr_client import KimHanNomClient, OCRError
from works import select

HERE = Path(__file__).parent
IMAGES_DIR = HERE / "images"
CACHE_DIR = HERE / "cache"
OUTPUT_DIR = HERE / "output"
DELAY_S = 5.0  # each page = 2–4 API calls; the server's burst quota is small

# Classical Han sentence-final punctuation, used as the fallback segmenter.
SENT_END = "。！？；"


def ocr_unit(client, unit_code):
    """OCR all pages of one unit; returns list of per-page results (page order)."""
    image_dir = IMAGES_DIR / unit_code
    pages = sorted(image_dir.glob("page_*.jpg"))
    if not pages:
        raise OCRError(f"{unit_code}: no images in {image_dir} — run download_images.py first")

    cache_dir = CACHE_DIR / unit_code
    cache_dir.mkdir(parents=True, exist_ok=True)

    results, failures = [], []
    for page in pages:
        cache_file = cache_dir / (page.stem + ".json")
        if cache_file.exists():
            results.append(json.loads(cache_file.read_text()))
            continue
        try:
            result = client.ocr_page(page)
        except OCRError as err:
            print(f"  {page.name}: FAILED — {err}")
            failures.append({"page": page.name, "error": str(err)})
            continue
        cache_file.write_text(json.dumps(result, ensure_ascii=False, indent=1))
        results.append(result)
        n_lines = len(result["lines"])
        note = result.get("skipped", f"{n_lines} lines")
        print(f"  {page.name}: {note}")
        time.sleep(DELAY_S)

    if failures:
        (cache_dir / "failures.json").write_text(json.dumps(failures, ensure_ascii=False, indent=1))
        print(f"  {unit_code}: {len(failures)} page(s) failed — see cache/{unit_code}/failures.json")
    return results


def _punct_split(text):
    sents, buf = [], ""
    for ch in text:
        buf += ch
        if ch in SENT_END:
            sents.append(buf.strip())
            buf = ""
    if buf.strip():
        sents.append(buf.strip())
    return sents


def segment_page(client, lines):
    """Segment one page's OCR lines into sentences.

    The separate-sentences endpoint segments best when given continuous text
    (no OCR line breaks): it inserts sentence-final 。 and returns the result
    as a newline-separated string in data["sentences"]. Segmenting per page
    keeps payloads small (the whole-work blob comes back empty) at the cost of
    cutting sentences that straddle a page boundary.
    """
    text = "".join(lines).strip()
    if not text:
        return [], "empty"
    if client is not None:
        try:
            data = client.separate_sentences(text)
            raw = data.get("sentences") if isinstance(data, dict) else data
            if isinstance(raw, list):
                sents = [str(s).strip() for s in raw if str(s).strip()]
            elif isinstance(raw, str):
                sents = [s.strip() for s in raw.splitlines() if s.strip()]
            else:
                sents = []
            if sents:
                return sents, "api"
        except OCRError as err:
            print(f"  separate-sentences failed ({err}); punctuation fallback")
    return _punct_split(text), "punctuation"


def write_outputs(client, unit_code, page_results, out_dir):
    out_dir.mkdir(parents=True, exist_ok=True)

    raw_lines = [line for res in page_results for line in res["lines"]]
    (out_dir / f"{unit_code}_raw.txt").write_text("\n".join(raw_lines) + "\n", encoding="utf-8")

    sentences, hows = [], set()
    for res in page_results:
        page_sents, how = segment_page(client, res["lines"])
        sentences.extend(page_sents)
        if page_sents:
            hows.add(how)
        time.sleep(DELAY_S)

    with open(out_dir / f"{unit_code}_seg.tsv", "w", encoding="utf-8") as fh:
        for i, sent in enumerate(sentences, start=1):
            fh.write(f"{unit_code}_{i:06d}\t{sent}\n")
    print(f"  {unit_code}: {len(raw_lines)} OCR lines -> {len(sentences)} sentences ({'/'.join(hows) or 'none'})")


def main():
    selection = select(sys.argv[1:])
    explicit = len(sys.argv) > 1  # a specific request may target a not-yet-complete unit
    client = KimHanNomClient()

    for work, unit_code, _vol in selection:
        image_dir = IMAGES_DIR / unit_code
        if not image_dir.exists():
            print(f"{unit_code}: no images downloaded yet, skipping")
            continue
        if not (image_dir / ".complete").exists() and not explicit:
            print(f"{unit_code}: download still in progress, skipping this pass")
            continue
        print(f"== {unit_code} ({work['title']}) ==")
        page_results = ocr_unit(client, unit_code)
        # multi-volume works nest each volume under the work folder
        out_dir = OUTPUT_DIR / work["code"]
        if unit_code != work["code"]:
            out_dir = out_dir / unit_code
        write_outputs(client, unit_code, page_results, out_dir)


if __name__ == "__main__":
    main()
