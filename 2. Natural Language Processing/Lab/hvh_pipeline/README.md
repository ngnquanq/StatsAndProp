# HVH Pipeline — Đề tài 4

Builds the monolingual chữ Hán corpus (HVH_090–HVH_107, ~2036 pages) from
lib.nomfoundation.org scans. Two OCR engines share one cache:

- **local** — fine-tuned PaddleOCRv5 (`local_ocr.py`), no rate limit; the bulk
  engine on a GPU machine (see `HANDOFF.md`).
- **api** — the CLC Kim Hán Nôm API (`ocr_client.py`), the gold standard but
  rate-limited; run by the team as `--person` shares and for verification.

Per page, `cache/<unit>/page_NNN.json` (API) beats `page_NNN.local.json`
(local) when outputs are written, so merging a teammate's API cache upgrades
pages automatically. `verify.py` reports local-vs-API CER per unit.

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
python run_pipeline.py               # stages 2+3: API OCR -> cache/, outputs -> output/
python run_pipeline.py --engine local   # same, with the local GPU engine
python run_pipeline.py --reseg HVH_090  # no OCR: rebuild outputs from cache,
                                        # segmenting via the API
# or restrict to specific work/unit codes:
python download_images.py HVH_090 HVH_107_06
python run_pipeline.py   HVH_090 HVH_107_06
```

Both stages are resumable: downloaded images, per-page OCR JSON in `cache/`,
and `.complete` markers are skipped on re-run. Sentence segmentation uses the
API when the API engine is active and falls back to splitting on 。！？；
otherwise; classical scans are often unpunctuated, so after a local bulk run
rebuild `_seg.tsv` with `--reseg` once API budget allows. Output format
follows `../OutputRequirement.pdf` section B:

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

Each person then sends back their `cache/` folder; merging is just copying the
files in (API `page_NNN.json` never collides with local `page_NNN.local.json`
and wins when outputs are regenerated). Pacing (delay + back-off in
`run_pipeline.py` / `ocr_client.py`) is tuned to stay under the per-machine
limit — see the rate-limit notes there.

## Local engine + quality check

See `HANDOFF.md` for the GPU setup, the validation go/no-go, and the full
dual-track run order. In short:

```bash
python local_ocr.py --download-models   # fine-tuned weights -> models/
python run_pipeline.py --engine local   # bulk OCR, no rate limit
python verify.py                        # CER local-vs-API -> verify_report.tsv
python verify.py --sample 3             # widen gold coverage via API budget
```
