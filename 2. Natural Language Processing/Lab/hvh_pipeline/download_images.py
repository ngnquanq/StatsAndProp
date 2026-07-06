"""Stage 1: crawl page images from lib.nomfoundation.org.

Each volume page embeds a static JPEG:
    <img src="/site_media/nom/nlvnpf-XXXX/jpeg/nlvnpf-XXXX-NNN.jpg">
and shows "Page n of N", so we read the count once, then follow each page's
own <img> tag (numbering is not always contiguous, so we don't guess URLs).

Usage:
    python download_images.py                  # all works
    python download_images.py HVH_090 ...       # given work/unit codes
    python download_images.py --person P1       # this person's assigned share
    python download_images.py HVH_100 --max-pages 1  # smoke test
"""

import re
import sys
import time
from pathlib import Path

import requests

from works import select

BASE = "https://lib.nomfoundation.org"
IMAGES_DIR = Path(__file__).parent / "images"
DELAY_S = 1.0
RETRIES = 6  # nomfoundation.org intermittently read-times-out for minutes

session = requests.Session()
session.headers["User-Agent"] = "Mozilla/5.0 (HVH corpus project; academic use)"

PAGE_COUNT_RE = re.compile(r"Page\s+\d+\s+of\s+(\d+)")
IMG_RE = re.compile(r'<img\s+src="(/site_media/nom/[^"]+\.jpg)"')


def get(url, **kw):
    last_err = None
    for attempt in range(RETRIES):
        try:
            resp = session.get(url, timeout=60, **kw)
            resp.raise_for_status()
            return resp
        except requests.RequestException as err:
            last_err = err
            time.sleep(min(2 ** attempt * 3, 120))  # 3s .. 96s
    raise RuntimeError(f"GET {url} failed after {RETRIES} tries: {last_err}")


def page_info(volume_id, page_no):
    """Return (total_pages, image_url) for one page of a volume."""
    html = get(f"{BASE}/collection/1/volume/{volume_id}/page/{page_no}").text
    count = PAGE_COUNT_RE.search(html)
    img = IMG_RE.search(html)
    if not count or not img:
        raise RuntimeError(f"volume {volume_id} page {page_no}: unexpected page layout")
    return int(count.group(1)), BASE + img.group(1)


def download_volume(unit_code, volume_id, max_pages=None):
    out_dir = IMAGES_DIR / unit_code
    out_dir.mkdir(parents=True, exist_ok=True)

    total, _ = page_info(volume_id, 1)
    done_marker = out_dir / ".complete"
    if done_marker.exists():
        print(f"{unit_code}: already complete ({total} pages), skipping")
        return

    page_limit = min(total, max_pages) if max_pages is not None else total
    print(f"{unit_code}: volume {volume_id}, {total} pages")
    for n in range(1, page_limit + 1):
        out_file = out_dir / f"page_{n:03d}.jpg"
        if out_file.exists() and out_file.stat().st_size > 0:
            continue
        _, img_url = page_info(volume_id, n)
        data = get(img_url).content
        out_file.write_bytes(data)
        print(f"  page {n}/{total} ({len(data) // 1024} KB)")
        time.sleep(DELAY_S)

    if page_limit == total:
        done_marker.touch()
        print(f"{unit_code}: done")
    else:
        print(f"{unit_code}: downloaded {page_limit}/{total} pages for limited run")


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
    max_pages_s = _pop_option(argv, "--max-pages")
    max_pages = None
    if max_pages_s is not None:
        try:
            max_pages = int(max_pages_s)
        except ValueError as err:
            raise SystemExit("--max-pages must be an integer") from err
        if max_pages < 1:
            raise SystemExit("--max-pages must be >= 1")

    # One bad volume must not kill an overnight run — record and move on;
    # the crawl is resumable, so failed volumes are just re-run later.
    failed = []
    for _work, unit_code, volume_id in select(argv):
        try:
            download_volume(unit_code, volume_id, max_pages=max_pages)
        except (RuntimeError, requests.RequestException) as err:
            print(f"{unit_code}: giving up on this volume — {err}")
            failed.append(unit_code)
    if failed:
        print(f"\nincomplete volumes (re-run to resume): {' '.join(failed)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
