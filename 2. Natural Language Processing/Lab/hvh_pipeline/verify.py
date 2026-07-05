"""Quality report: candidate OCR outputs vs the CLC API benchmark.

For every page that has a CLC/API cache file (page_NNN.json) and one or more
candidate cache files (page_NNN.<candidate>.json), compute character error rate
of the candidate text against the API text, plus line-count agreement.

Usage:
    python verify.py                    # all units that have any cache
    python verify.py HVH_090 ...        # restrict to works/units
    python verify.py --sample 3         # additionally API-OCR up to 3 random
                                        # local-only pages per unit first, to
                                        # widen benchmark coverage

Writes verify_report.tsv:
    unit  candidate  pages_compared  mean_CER  worst_page  worst_CER
"""

import json
import random
import re
import sys
from pathlib import Path

from works import select

HERE = Path(__file__).parent
IMAGES_DIR = HERE / "images"
CACHE_DIR = HERE / "cache"
REPORT = HERE / "verify_report.tsv"
API_PAGE_RE = re.compile(r"page_\d+\.json$")
CANDIDATE_PAGE_RE = re.compile(r"(page_\d+)\.([^.]+)\.json$")


def levenshtein(a, b):
    try:
        from rapidfuzz.distance import Levenshtein
        return Levenshtein.distance(a, b)
    except ImportError:
        pass
    if len(a) < len(b):
        a, b = b, a
    prev = list(range(len(b) + 1))
    for i, ca in enumerate(a, start=1):
        cur = [i]
        for j, cb in enumerate(b, start=1):
            cur.append(min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (ca != cb)))
        prev = cur
    return prev[-1]


def cer(ref, hyp):
    """Character error rate of hyp against ref (0 = identical)."""
    return levenshtein(ref, hyp) / max(len(ref), 1)


def _load(cache_file):
    return json.loads(cache_file.read_text())


def _text(cache_file):
    return "".join(_load(cache_file)["lines"])


def sample_gold(client, unit_code, n):
    """API-OCR up to n random pages that only have candidate results, writing
    the normal API cache file so they become benchmark pages here."""
    import time
    from run_pipeline import DELAY_S

    cache_dir = CACHE_DIR / unit_code
    candidate_stems = set()
    for path in cache_dir.glob("page_*.*.json"):
        match = CANDIDATE_PAGE_RE.fullmatch(path.name)
        if match:
            candidate_stems.add(match.group(1))
    candidates = [
        stem for stem in sorted(candidate_stems)
        if not (cache_dir / f"{stem}.json").exists()
        and (IMAGES_DIR / unit_code / f"{stem}.jpg").exists()
    ]
    for stem in random.sample(candidates, min(n, len(candidates))):
        image = IMAGES_DIR / unit_code / f"{stem}.jpg"
        try:
            result = client.ocr_page(image)
        except Exception as err:
            print(f"  sample {unit_code}/{stem}: FAILED — {err}")
            continue
        (cache_dir / f"{stem}.json").write_text(json.dumps(result, ensure_ascii=False, indent=1))
        print(f"  sample {unit_code}/{stem}: {len(result['lines'])} lines from API")
        time.sleep(DELAY_S)


def candidate_files(cache_dir, stem):
    files = []
    for path in sorted(cache_dir.glob(f"{stem}.*.json")):
        match = CANDIDATE_PAGE_RE.fullmatch(path.name)
        if match:
            files.append((match.group(2), path))
    return files


def unit_report(unit_code):
    """Compare all candidate caches against API benchmark pages for one unit."""
    cache_dir = CACHE_DIR / unit_code
    rows_by_candidate = {}
    for api_file in sorted(f for f in cache_dir.glob("page_*.json") if API_PAGE_RE.fullmatch(f.name)):
        stem = api_file.stem
        ref = _text(api_file)
        if not ref:
            continue
        api_lines = len(_load(api_file)["lines"])
        for candidate, candidate_file in candidate_files(cache_dir, stem):
            hyp = _text(candidate_file)
            page_cer = cer(ref, hyp)
            rows_by_candidate.setdefault(candidate, []).append((stem, page_cer))
            n_candidate = len(_load(candidate_file)["lines"])
            print(
                f"  {unit_code}/{stem} [{candidate}]: CER {page_cer:.3f}  "
                f"lines api={api_lines} candidate={n_candidate}"
            )
    report = []
    for candidate, rows in sorted(rows_by_candidate.items()):
        mean_cer = sum(c for _, c in rows) / len(rows)
        worst_page, worst_cer = max(rows, key=lambda r: r[1])
        report.append((unit_code, candidate, len(rows), round(mean_cer, 4), worst_page, round(worst_cer, 4)))
    return report


def main():
    argv = sys.argv[1:]
    sample = 0
    if "--sample" in argv:
        i = argv.index("--sample")
        sample = int(argv[i + 1])
        del argv[i:i + 2]

    selection = select(argv)
    client = None
    if sample:
        from ocr_client import KimHanNomClient
        client = KimHanNomClient()

    report = []
    for _work, unit_code, _vol in selection:
        if not (CACHE_DIR / unit_code).exists():
            continue
        if sample:
            sample_gold(client, unit_code, sample)
        report.extend(unit_report(unit_code))

    if not report:
        print("no pages have both an API benchmark file and a candidate cache file yet")
        return
    with open(REPORT, "w", encoding="utf-8") as fh:
        fh.write("unit\tcandidate\tpages_compared\tmean_CER\tworst_page\tworst_CER\n")
        for row in report:
            fh.write("\t".join(str(v) for v in row) + "\n")
    print(f"\n{REPORT.name}:")
    for row in report:
        print("  " + "\t".join(str(v) for v in row))


if __name__ == "__main__":
    main()
