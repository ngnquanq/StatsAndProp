# HVH Pipeline — Đề tài 4

Builds the monolingual chữ Hán corpus (HVH_090–HVH_107, ~2036 pages) from
lib.nomfoundation.org scans. API benchmark results and local candidate-model
results share one cache:

- **api** — the CLC Kim Hán Nôm API (`ocr_client.py`), the rate-limited website
  benchmark; run by the team as `--person` shares and for verification.
- **local** — fine-tuned PaddleOCRv5 (`local_ocr.py`), a no-rate-limit GPU
  candidate model.
- **trocr** — TrOCR candidate models (`candidate_ocr.py`, `bench_trocr.py`).
- **nomnaocr** — NomNaOCR candidate recognition (`nomnaocr_ocr.py`,
  `bench_nomnaocr.py`), run from the TensorFlow `py310-ml` env against the
  same `.local.json` detector boxes.

Per page, `cache/<unit>/page_NNN.json` (API benchmark) beats candidate files
such as `page_NNN.local.json` or `page_NNN.trocr.json` when outputs are written,
so merging a teammate's API cache upgrades pages automatically. `verify.py`
reports candidate-vs-API CER per unit.

## Setup

Use the `hvh` conda environment on the GPU machine; packages are listed in
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
python run_pipeline.py --engine local   # PaddleOCRv5 candidate
python run_pipeline.py --engine trocr   # TrOCR candidate
conda run -n py310-ml python run_pipeline.py --engine nomnaocr --orientation vertical HVH_090
python run_pipeline.py --engine trocr --orientation rot_ccw --candidate-name trocr_rot_ccw
python run_pipeline.py --reseg HVH_090  # no OCR: rebuild outputs from cache
# or restrict to specific work/unit codes:
python download_images.py HVH_090 HVH_107_06
python run_pipeline.py   HVH_090 HVH_107_06
```

### Sentence segmentation from red-ink marks (punct track)

The scans carry reader punctuation in red ink (dashes = clause break `、`,
hollow rings = sentence end `。`). `punct_detect.py` recovers them with
OpenCV from the high-resolution scans and `--punct` turns `_seg.tsv` rows
into sentence units (pages without detections keep line units):

```bash
python download_images.py --large HVH_090   # ~2000px scans -> images_large/
python punct_detect.py HVH_090 --debug      # -> cache/.../page_NNN.punct.json
                                            #    + overlays in debug_punct/
python run_pipeline.py --reseg --punct HVH_090
python bench_punct.py HVH_090               # vs CLC /separate-sentences
```

Needs the unit's `.local.json` files for line geometry (run
`--engine local` first). Details and pilot numbers: `REPORT.md` section 5.

Both stages are resumable: downloaded images, per-page OCR JSON in `cache/`,
and `.complete` markers are skipped on re-run. For HVH image OCR, each ordered
OCR line is emitted as one `_seg.tsv` row; the sentence id preserves document,
page, and line/sentence position, for example `HVH_090_000001_000001`.
Output format follows `../OutputRequirement.pdf` section B:

```
output/HVH_090/HVH_090_raw.txt      raw OCR text
output/HVH_090/HVH_090_seg.tsv      HVH_090_000001_000001<TAB>sentence
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

## Candidate models + benchmark check

See `HANDOFF.md` for the GPU setup and the full dual-track run order. In short:

```bash
python local_ocr.py --download-models   # fine-tuned PaddleOCRv5 weights -> models/
python run_pipeline.py HVH_090          # API benchmark cache for the sample
python run_pipeline.py --engine local HVH_090
python bench_trocr.py HVH_090           # benchmark TrOCR candidate orientations
conda run -n py310-ml python bench_nomnaocr.py HVH_090
python run_pipeline.py --engine trocr --candidate-name trocr_v1 HVH_090
python verify.py                        # candidate-vs-API CER -> verify_report.tsv
python verify.py --sample 3             # widen benchmark coverage via API budget
```
