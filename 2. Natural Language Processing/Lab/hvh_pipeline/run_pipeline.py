"""Stages 2+3: OCR every downloaded page, then write the HVH deliverables.

Per OutputRequirement.pdf (section B, HVH):
    output/HVH_xxx/HVH_xxx_raw.txt   — raw OCR text, page order
    output/HVH_xxx/HVH_xxx_seg.tsv   — [sentence_id]\t[sentence]
Multi-volume works nest chapters: output/HVH_107/HVH_107_01/HVH_107_01_raw.txt ...

OCR engines share one cache (cache/<unit>/):
    page_NNN.json        — CLC Kim Hán Nôm API result (the benchmark)
    page_NNN.local.json  — fine-tuned PaddleOCRv5 candidate result
    page_NNN.trocr.json  — TrOCR candidate result
    page_NNN.nomnaocr.json — NomNaOCR candidate result
Outputs always prefer the API benchmark file, so merging a colleague's API cache
upgrades pages without re-running anything.

Usage:
    python run_pipeline.py                    # API engine, all downloaded works
    python run_pipeline.py --person P1        # this person's assigned API share
    python run_pipeline.py --engine local     # PaddleOCRv5 candidate
    python run_pipeline.py --engine trocr     # TrOCR candidate
    python run_pipeline.py --engine nomnaocr  # NomNaOCR candidate
    python run_pipeline.py --engine trocr --orientation rot_ccw --candidate-name trocr_rot_ccw
    python run_pipeline.py --reseg HVH_090    # no OCR: rebuild outputs from
                                              # cache, segmenting via the API
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

# Classical Han sentence-final punctuation, used by the punctuation segmenter.
SENT_END = "。！？；"


def _page_stems(unit_code):
    """Page stems (page_001, ...) from images, or from cache when images are
    absent (lets --reseg rebuild outputs on a machine that only has cache/)."""
    image_dir = IMAGES_DIR / unit_code
    pages = sorted(p.stem for p in image_dir.glob("page_*.jpg"))
    if pages:
        return pages
    cache_dir = CACHE_DIR / unit_code
    return sorted({f.name.split(".")[0] for f in cache_dir.glob("page_*.json")})


def _cache_file(cache_dir, stem, suffix):
    if suffix == "api":
        return cache_dir / f"{stem}.json"
    return cache_dir / f"{stem}.{suffix}.json"


def _best_cached(cache_dir, stem, suffixes):
    for suffix in suffixes:
        cache_file = _cache_file(cache_dir, stem, suffix)
        if cache_file.exists():
            return json.loads(cache_file.read_text())
    return None


def ocr_unit(
    unit_code,
    api_client=None,
    local_engine=None,
    candidate_engine=None,
    candidate_suffix="trocr",
    read_suffixes=None,
):
    """OCR uncached pages with the selected engine, then return cached results.

    API benchmark cache wins. Candidate caches are only read when explicitly
    allowed by the selected run mode; default regeneration does not use the
    rejected PaddleOCRv5 .local.json files.
    """
    stems = _page_stems(unit_code)
    if not stems:
        raise OCRError(f"{unit_code}: no images and no cache — run download_images.py first")

    cache_dir = CACHE_DIR / unit_code
    cache_dir.mkdir(parents=True, exist_ok=True)

    results, failures = [], []
    for stem in stems:
        api_file = _cache_file(cache_dir, stem, "api")
        local_file = _cache_file(cache_dir, stem, "local")
        candidate_file = _cache_file(cache_dir, stem, candidate_suffix)
        image = IMAGES_DIR / unit_code / f"{stem}.jpg"

        engine = None
        if api_client is not None and not api_file.exists():
            engine, target = api_client, api_file
        elif local_engine is not None and not api_file.exists() and not local_file.exists():
            engine, target = local_engine, local_file
        elif candidate_engine is not None and not api_file.exists() and not candidate_file.exists():
            engine, target = candidate_engine, candidate_file

        if engine is not None:
            try:
                result = engine.ocr_page(image)
            except Exception as err:  # OCRError / LocalOCRError
                print(f"  {image.name}: FAILED — {err}")
                failures.append({"page": image.name, "error": str(err)})
            else:
                target.write_text(json.dumps(result, ensure_ascii=False, indent=1))
                note = result.get("skipped", f"{len(result['lines'])} lines")
                print(f"  {image.name}: {note} ({result.get('source', 'api')})")
                if engine is api_client:
                    time.sleep(DELAY_S)

        cached = _best_cached(cache_dir, stem, read_suffixes or ("api", "trocr"))
        if cached is not None:
            results.append(cached)

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

    With client=None (candidate-model runs) only the punctuation segmenter is used;
    rebuild seg.tsv later with --reseg once API budget allows. Classical scans
    are often unpunctuated, so watch for giant "sentences" in that mode.
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
            print(f"  separate-sentences failed ({err}); using punctuation segmenter")
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
        if client is not None:
            time.sleep(DELAY_S)

    with open(out_dir / f"{unit_code}_seg.tsv", "w", encoding="utf-8") as fh:
        for i, sent in enumerate(sentences, start=1):
            fh.write(f"{unit_code}_{i:06d}\t{sent}\n")
    print(f"  {unit_code}: {len(raw_lines)} OCR lines -> {len(sentences)} sentences ({'/'.join(hows) or 'none'})")


def _pop_option(argv, name, default=None):
    if name not in argv:
        return default
    i = argv.index(name)
    try:
        value = argv[i + 1]
    except IndexError as err:
        raise SystemExit(f"{name} needs a value") from err
    del argv[i:i + 2]
    return value


def main():
    argv = sys.argv[1:]
    engine = _pop_option(argv, "--engine", "api")
    if engine not in ("api", "local", "trocr", "nomnaocr"):
        raise SystemExit(f"--engine must be 'api', 'local', 'trocr', or 'nomnaocr', not {engine!r}")
    candidate_name = _pop_option(argv, "--candidate-name")
    model_name = _pop_option(argv, "--model")
    nomnaocr_model = _pop_option(argv, "--nomnaocr-model", "sc_transformer")
    orientation = _pop_option(argv, "--orientation", "rot_cw")
    reseg = "--reseg" in argv
    if reseg:
        argv.remove("--reseg")

    selection = select(argv)
    explicit = bool(argv)  # a specific request may target a not-yet-complete unit

    api_client = local_engine = candidate_engine = None
    candidate_suffix = candidate_name or ("nomnaocr" if engine == "nomnaocr" else "trocr")
    read_suffixes = ("api", candidate_suffix)
    if reseg:
        api_client = KimHanNomClient()  # segmentation only, no OCR
    elif engine == "api":
        api_client = KimHanNomClient()
        read_suffixes = ("api",)
    elif engine == "local":
        from local_ocr import LocalOCR
        local_engine = LocalOCR()
        read_suffixes = ("api", "local")
    elif engine == "trocr":
        from candidate_ocr import DEFAULT_MODEL, TrocrOCR
        candidate_engine = TrocrOCR(model_name=model_name or DEFAULT_MODEL, orientation=orientation)
        read_suffixes = ("api", candidate_suffix)
    else:
        from nomnaocr_ocr import NomNaOCR, NomNaOCRError
        try:
            candidate_engine = NomNaOCR(model=nomnaocr_model, orientation=orientation)
        except NomNaOCRError as err:
            raise SystemExit(str(err)) from err
        read_suffixes = ("api", candidate_suffix)
    seg_client = api_client

    for work, unit_code, _vol in selection:
        image_dir = IMAGES_DIR / unit_code
        if not image_dir.exists() and not (CACHE_DIR / unit_code).exists():
            print(f"{unit_code}: no images downloaded yet, skipping")
            continue
        if not (image_dir / ".complete").exists() and not explicit and not reseg:
            print(f"{unit_code}: download still in progress, skipping this pass")
            continue
        print(f"== {unit_code} ({work['title']}) ==")
        page_results = ocr_unit(
            unit_code,
            api_client=None if reseg else api_client,
            local_engine=local_engine,
            candidate_engine=candidate_engine,
            candidate_suffix=candidate_suffix,
            read_suffixes=read_suffixes,
        )
        # multi-volume works nest each volume under the work folder
        out_dir = OUTPUT_DIR / work["code"]
        if unit_code != work["code"]:
            out_dir = out_dir / unit_code
        write_outputs(seg_client, unit_code, page_results, out_dir)


if __name__ == "__main__":
    main()
