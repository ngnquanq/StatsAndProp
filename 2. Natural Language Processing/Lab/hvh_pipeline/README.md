# HVH Pipeline — Đề tài 4

Builds the monolingual chữ Hán corpus (HVH_090–HVH_107, ~2036 pages) from
lib.nomfoundation.org scans, OCR'd through the CLC Kim Hán Nôm API.

## Setup

Uses the conda base environment (`/opt/anaconda3/bin/python`); packages in
`requirements.txt`.

The OCR API is open — it only rejects requests without browser-like headers,
which `ocr_client.py` sends. If the service ever starts requiring login, put
a Kim Hán Nôm account in `credentials.json` (git-ignored,
`{"username": "...", "password": "..."}`) or set `KHN_USERNAME` /
`KHN_PASSWORD`; the client logs in automatically on 401.

## Run

```bash
python download_images.py            # stage 1: crawl JPEGs -> images/
python run_pipeline.py               # stages 2+3: OCR -> cache/, outputs -> output/
# or restrict to specific work/unit codes:
python download_images.py HVH_090 HVH_107_06
python run_pipeline.py   HVH_090 HVH_107_06
```

Both stages are resumable: downloaded images, per-page OCR JSON in `cache/`,
and `.complete` markers are skipped on re-run. Output format follows
`../OutputRequirement.pdf` section B:

```
output/HVH_090/HVH_090_raw.txt      raw OCR text
output/HVH_090/HVH_090_seg.tsv      sentence_id<TAB>sentence
output/HVH_107/HVH_107_01/...       multi-volume works nest chapters
```

## Team split (4 people)

The OCR API rate-limits sustained anonymous use, so the ~2036 pages are split
four ways (~509 pages each) in `assignments.py`. Each person runs **only their
share, from their own machine** — separate machines mean separate rate-limit
buckets, so the team's aggregate throughput scales:

```bash
python download_images.py --person P1     # P1 / P2 / P3 / P4
python run_pipeline.py    --person P1
```

Each person then commits/shares their `output/` folders; together they cover
all 38 units. Pacing (delay + back-off in `run_pipeline.py` / `ocr_client.py`)
is tuned to stay under the per-machine limit — see the rate-limit notes there.
