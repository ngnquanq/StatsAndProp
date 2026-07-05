"""Quality report: local PaddleOCRv5 results vs the CLC API gold standard.

For every page that has both cache flavours (page_NNN.json from the API,
page_NNN.local.json from local_ocr.py) compute the character error rate of
the local text against the API text, plus line-count agreement. Units whose
CER is high should be re-OCR'd through the API by the team (or benched
against NomNaOCR).

Usage:
    python verify.py                    # all units that have any cache
    python verify.py HVH_090 ...        # restrict to works/units
    python verify.py --sample 3         # additionally API-OCR up to 3 random
                                        # local-only pages per unit first, to
                                        # widen gold coverage (uses API budget)

Writes verify_report.tsv: unit  pages_compared  mean_CER  worst_page  worst_CER
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
API_PAGE_RE = re.compile(r"page_\d+\.json$")  # excludes .local.json


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


def _text(cache_file):
    return "".join(json.loads(cache_file.read_text())["lines"])


def sample_gold(client, unit_code, n):
    """API-OCR up to n random pages that only have a local result, writing the
    normal API cache file (so they become gold here and win in run_pipeline)."""
    import time
    from run_pipeline import DELAY_S
    cache_dir = CACHE_DIR / unit_code
    candidates = [
        f for f in cache_dir.glob("page_*.local.json")
        if not f.with_name(f.name.replace(".local", "")).exists()
        and (IMAGES_DIR / unit_code / (f.name.split(".")[0] + ".jpg")).exists()
    ]
    for local_file in random.sample(candidates, min(n, len(candidates))):
        stem = local_file.name.split(".")[0]
        image = IMAGES_DIR / unit_code / f"{stem}.jpg"
        try:
            result = client.ocr_page(image)
        except Exception as err:
            print(f"  sample {unit_code}/{stem}: FAILED — {err}")
            continue
        (cache_dir / f"{stem}.json").write_text(json.dumps(result, ensure_ascii=False, indent=1))
        print(f"  sample {unit_code}/{stem}: {len(result['lines'])} lines from API")
        time.sleep(DELAY_S)


def unit_report(unit_code):
    """Compare all doubly-cached pages of one unit; returns a report row."""
    cache_dir = CACHE_DIR / unit_code
    rows = []
    for api_file in sorted(f for f in cache_dir.glob("page_*.json")
                           if API_PAGE_RE.fullmatch(f.name)):
        local_file = api_file.with_name(api_file.stem + ".local.json")
        if not local_file.exists():
            continue
        ref, hyp = _text(api_file), _text(local_file)
        if not ref:
            continue
        page_cer = cer(ref, hyp)
        rows.append((api_file.name.split(".")[0], page_cer))
        n_api = len(json.loads(api_file.read_text())["lines"])
        n_local = len(json.loads(local_file.read_text())["lines"])
        print(f"  {unit_code}/{rows[-1][0]}: CER {page_cer:.3f}  lines api={n_api} local={n_local}")
    if not rows:
        return None
    mean_cer = sum(c for _, c in rows) / len(rows)
    worst_page, worst_cer = max(rows, key=lambda r: r[1])
    return (unit_code, len(rows), round(mean_cer, 4), worst_page, round(worst_cer, 4))


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
        row = unit_report(unit_code)
        if row:
            report.append(row)

    if not report:
        print("no pages have both an API and a local cache file yet")
        return
    with open(REPORT, "w", encoding="utf-8") as fh:
        fh.write("unit\tpages_compared\tmean_CER\tworst_page\tworst_CER\n")
        for row in report:
            fh.write("\t".join(str(v) for v in row) + "\n")
    print(f"\n{REPORT.name}:")
    for row in report:
        print("  " + "\t".join(str(v) for v in row))


if __name__ == "__main__":
    main()
