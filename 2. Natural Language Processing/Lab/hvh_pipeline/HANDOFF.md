# Handoff — running the HVH pipeline on the GPU machine

The CLC Kim Hán Nôm API rate-limits anonymous use after a handful of pages, so
the ~2036-page corpus runs as **two tracks at once**:

- **Candidate-model track (this GPU machine):** run local OCR models without the
  API rate limit. The first candidate is the fine-tuned PaddleOCRv5 model from
  [MinhDS/Fine-tuned-PaddleOCRv5](https://huggingface.co/spaces/MinhDS/Fine-tuned-PaddleOCRv5)
  (HCMUS; PP-OCRv5_server_rec fine-tuned on ~400K Sino-Nom line images). TrOCR
  candidates can be tested through `bench_trocr.py` / `--engine trocr`, and NomNaOCR candidates through `bench_nomnaocr.py` / `--engine nomnaocr`.
- **API benchmark track:** the CLC API is the website benchmark. Colleagues run
  their `--person P1..P4` shares from their own machines (separate rate-limit
  buckets) and send back their `cache/` folders. Wherever an API result exists
  for a page it automatically wins over candidate results, and pages with both
  feed the CER benchmark report (`verify.py`).

The goal is to test multiple local models against the rate-limited website/API
benchmark, not to treat one local model as the final source before comparison.

## What to copy

The whole `hvh_pipeline/` folder. `images/` and `cache/` are git-ignored, so
copy them along if they exist; otherwise both stages resume from scratch
(the crawler and OCR both skip anything already on disk).

> Note (2026-07-05): the original dev machine no longer has `images/` or
> `cache/` — the 898 crawled pages and the 16 HVH_090/091 API pages must be
> regenerated. Both are cheap: the crawl resumes by itself, and re-OCR'ing
> HVH_090's 11 pages through the API (step 2) stays under the burst limit.

## Setup

```bash
conda create -n hvh python=3.11 -y && conda activate hvh
pip install -r requirements.txt
# GPU stack — pick the CUDA build matching `nvidia-smi` (see
# https://www.paddlepaddle.org.cn/en/install/quick for the exact index URL):
pip install paddlepaddle-gpu==3.0.0 -i https://www.paddlepaddle.org.cn/packages/stable/cu118/
pip install "paddleocr>=3.0"
python local_ocr.py --download-models    # ~85 MB rec weights + stock detector
python local_ocr.py --selftest           # reading-order geometry tests
```

Smoke test (any downloaded page image):

```bash
python local_ocr.py images/HVH_090/page_001.jpg
```

## Run order

1. **Finish the crawl** (resumable; survives per-volume failures):
   `python download_images.py`
2. **Benchmark candidate models.** Get API benchmark text for HVH_090 (11 pages
   — one evening of polite pacing): `python run_pipeline.py HVH_090`, then run
   candidates such as `python run_pipeline.py --engine local HVH_090`,
   `python bench_trocr.py HVH_090`, and
   `conda run -n py310-ml python bench_nomnaocr.py HVH_090`. To cache a TrOCR
   or NomNaOCR candidate, use a distinct
   suffix such as `python run_pipeline.py --engine trocr --orientation rot_ccw --candidate-name trocr_rot_ccw HVH_090`.
   Finish with `python verify.py HVH_090`.
   Record each candidate's mean CER vs the CLC/API benchmark; also eyeball page
   1 so local line order matches the API's columns right-to-left.
3. **Bulk candidate run:** run only candidates that look acceptable on the
   benchmark sample, for example `python run_pipeline.py --engine trocr --candidate-name trocr_v1` or
   `python run_pipeline.py --engine local`. Segmentation in candidate mode is
   the punctuation segmenter — see "Segmentation" below.
4. **In parallel, the team's API track:** each colleague runs
   `python download_images.py --person Pn` and
   `python run_pipeline.py --person Pn` on their own machine and sends back
   `cache/`. **Merging = copying their `cache/` folders into yours** — API
   files (`page_NNN.json`) never collide with candidate files such as
   `page_NNN.local.json` or `page_NNN.trocr.json` and win by the read rule.
   After each merge run `python verify.py` to grow `verify_report.tsv`; units
   with high candidate CER go to the team for full API re-OCR.
   `python verify.py --sample 3` additionally spends a little API budget on
   random local-only pages to widen gold coverage.
5. **Regenerate outputs** once caches settle: `python run_pipeline.py --reseg`
   re-writes `output/` from cache without any OCR, segmenting through the API.

## Current benchmark status

As of 2026-07-05, all surveyed public candidates are benchmarked on the
`HVH_090` CLC/API sample (see `verify_report.tsv` and `REPORT.md`):
PaddleOCRv5 candidate mean CER `0.4766` (but `0.195` on Han-prose HVH_094 —
the only PASS); TrOCR checkpoints `nxquang-al/...` and `tt1225/...` both
≈ `0.98` (weak checkpoints); NomNaOCR CRNN `0.971` / SC-Transformer `0.975`.

NomNaOCR's assets are fully installed under `models/NomNaOCR/` and the
harness is *verified correct* (it decodes the authors' bundled demo patch
exactly). Its failure on HVH_090 is a genuine domain-generalization limit,
not a wiring bug. Critical gotcha: `models/NomNaOCR/All.txt` must be the
byte-exact Kaggle `Patches/All.txt` — the decode vocabulary's tie-break
depends on its line order (see `models/NomNaOCR/MISSING_METADATA.md`).

## Segmentation caveat

CLC separate-sentences is rate-limited like the OCR, so the bulk local run
falls back to splitting on 。！？；. Classical scans are often *unpunctuated* —
if `_seg.tsv` shows giant one-page "sentences", rebuild with `--reseg` (API
budget) or evaluate a local classical-Chinese punctuation-restoration model
(open research task, not built here).

## File map

| file | role |
|---|---|
| `works.py` | manifest of HVH_090–107 + unit/volume selection |
| `assignments.py` | 4-way team split (`--person P1..P4`) |
| `download_images.py` | stage 1: crawl JPEGs from lib.nomfoundation.org |
| `ocr_client.py` | CLC Kim Hán Nôm API client (backoff, rate-limit waits) |
| `local_ocr.py` | PaddleOCRv5 candidate: detection + reading order + fine-tuned rec |
| `nomnaocr_ocr.py` | NomNaOCR candidate recognizer using cached `.local.json` boxes |
| `run_pipeline.py` | stages 2+3: API/candidate OCR + outputs; merge rule |
| `verify.py` | CER report candidate-vs-API benchmark → `verify_report.tsv` |
