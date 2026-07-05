# Handoff — running the HVH pipeline on the GPU machine

The CLC Kim Hán Nôm API rate-limits anonymous use after a handful of pages, so
the ~2036-page corpus runs as **two tracks at once**:

- **Local track (primary, this machine):** fine-tuned PaddleOCRv5 OCRs every
  page locally on the GPU — no rate limit. Model: HF space
  [MinhDS/Fine-tuned-PaddleOCRv5](https://huggingface.co/spaces/MinhDS/Fine-tuned-PaddleOCRv5)
  (HCMUS; PP-OCRv5_server_rec fine-tuned on ~400K Sino-Nom line images).
- **API track (quality):** the CLC API stays the gold standard. Colleagues run
  their `--person P1..P4` shares from their own machines (separate rate-limit
  buckets) and send back their `cache/` folders. Wherever an API result exists
  for a page it automatically wins over the local result, and pages with both
  feed the CER quality report (`verify.py`).

NomNaOCR is the bench fallback — only wire it up if the fine-tuned model fails
validation (step 2 below).

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
2. **Validate the local model.** Get API gold for HVH_090 (11 pages — one
   evening of polite pacing): `python run_pipeline.py HVH_090`, then
   `python run_pipeline.py --engine local HVH_090` and
   `python verify.py HVH_090`.
   **Go/no-go:** mean CER ≲ 0.3 vs the CLC gold → proceed; much worse →
   stop and bench NomNaOCR instead. Also eyeball page 1: the local line order
   must match the API's (columns right-to-left).
3. **Bulk local run:** `python run_pipeline.py --engine local`
   (all units; GPU-hours, not weeks). Segmentation in this mode is the
   punctuation fallback — see "Segmentation" below.
4. **In parallel, the team's API track:** each colleague runs
   `python download_images.py --person Pn` and
   `python run_pipeline.py --person Pn` on their own machine and sends back
   `cache/`. **Merging = copying their `cache/` folders into yours** — API
   files (`page_NNN.json`) never collide with local ones (`page_NNN.local.json`)
   and win by the read rule. After each merge run `python verify.py` to grow
   `verify_report.tsv`; units with high CER go to the team for full API re-OCR.
   `python verify.py --sample 3` additionally spends a little API budget on
   random local-only pages to widen gold coverage.
5. **Regenerate outputs** once caches settle: `python run_pipeline.py --reseg`
   re-writes `output/` from cache without any OCR, segmenting through the API.

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
| `local_ocr.py` | local engine: detection + reading order + fine-tuned rec |
| `run_pipeline.py` | stages 2+3: OCR (either engine) + outputs; merge rule |
| `verify.py` | CER report local-vs-API → `verify_report.tsv` |
