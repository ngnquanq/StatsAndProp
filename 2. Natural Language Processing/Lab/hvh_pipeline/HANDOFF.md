# Handoff — running the HVH pipeline on the GPU machine

## Session status — 2026-07-06 (cloud fleet run, paused mid-way)

A one-shot 8-VM GCE fleet (`--startup-run`, `infra/`) was launched to crawl and
API-OCR the whole corpus in parallel. It was **stopped early and torn down**;
here is exactly where things stand so the next person/agent can resume.

**Collected and merged into this repo (durable):**
- `images_large/` — **1986 / 2071 high-res /large/ scans (96%)**, corpus-wide.
  The missing ~85 are mostly HVH_103 (volume nlvnpf-0600 has no `/large/`
  variant on nomfoundation — a 404, expected). This unblocks the punct track
  for essentially all 38 units.
- `cache/` — **228 new API pages** (`page_NNN.json`) across ~12 units, plus the
  full `.local.json` geometry (2071 pages) from the earlier GPU pass.
- `output/` regenerated (`run_pipeline.py --engine local`): all 38 units have
  non-empty `_raw.txt` + `_seg.tsv`; API pages win where present.

**Why it stopped — CLC API incident (not an IP block):**
The fleet's OCR stalled at ~29 pages/worker. Diagnosis (evidence, not
inference): the CLC **OCR/upload endpoint degraded for *all* clients** — the
same `image-upload` call went from 6.3 s to 25 s timeouts **from the home IP
too**, while `tools.clc.hcmus.edu.vn/` homepage stayed fast (0.25 s) and general
connectivity from the VMs was fine (nomfoundation, google all 200). So it is a
server-side OCR-backend saturation, and 8 VMs + retries hammering a modest
academic server plausibly contributed. Earlier over-confident "GCP IP is
blocked" / "null-route" guesses were **wrong** — see the corrected reasoning.
The right move was to back off and let the server recover. CLC use here is
authorized instructor-assigned work; this was load management, not a ban.

**What remains (the handoff):**
1. **Finish API OCR** for the ~1843 pages not yet API-covered, *once CLC
   recovers*. Do it gently — a single stream from a home IP (which works), or
   very few workers with larger delays; do not re-launch 8 concurrent VMs at the
   same endpoint. Resume is idempotent (cached pages skip): `python
   run_pipeline.py` (or `--person P1..P4` shares across teammates' machines).
2. **Run the punct track corpus-wide** now that `images_large/` exists:
   `python punct_detect.py <unit>` then `python run_pipeline.py --reseg --punct`.
   Geometry comes from API `result_bbox` where present, else `.local.json`.
3. Re-run `verify.py` to refresh CER numbers as API coverage grows.

**Infra to resume the fleet** (if ever): `infra/run_gce_workers.sh
--startup-run --workers N` provisions, `infra/collect_run.sh --watch --merge`
gathers + merges bundles. Note GCP quota caps this project at **8 in-use IPs**
in asia-southeast1. Always `terraform destroy` after collecting.

---


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
   `python run_pipeline.py --engine local`. `_seg.tsv` uses the ordered OCR
   lines as sentence-like units and keeps page provenance in the ids.
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
   re-writes `output/` from cache without any OCR.

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

## Segmentation convention

For HVH image OCR, `_seg.tsv` treats each ordered OCR line as one sentence-like
unit by default. Sentence ids preserve source page and line position, e.g.
`HVH_090_000001_000001` means document HVH_090, page 1, line/sentence 1.

`run_pipeline.py --reseg --punct` upgrades pages to true sentence units using
the reader's red-ink punctuation (see `punct_detect.py` and REPORT.md §5):
detected rings insert `。`, dashes insert `、`, lines are joined in reading
order and split at `。`. Prerequisites per unit: `images_large/` scans
(`download_images.py --large`) and line geometry — the API cache's
`result_bbox` (pages OCRed with the current client) or `.local.json`
(`--engine local`).
Sentences spanning a page boundary are cut at the page edge to keep id
provenance. Pilot on HVH_090: 211 lines -> 85 sentences, 11/11 pages.

## File map

| file | role |
|---|---|
| `works.py` | manifest of HVH_090–107 + unit/volume selection |
| `assignments.py` | 4-way team split (`--person P1..P4`) |
| `download_images.py` | stage 1: crawl JPEGs from lib.nomfoundation.org |
| `ocr_client.py` | CLC Kim Hán Nôm API client (backoff, rate-limit waits) |
| `local_ocr.py` | PaddleOCRv5 candidate: detection + reading order + fine-tuned rec |
| `nomnaocr_ocr.py` | NomNaOCR candidate recognizer using cached `.local.json` boxes |
| `run_pipeline.py` | stages 2+3: API/candidate OCR + outputs; merge rule; `--punct` |
| `punct_detect.py` | red-ink punctuation detection on `images_large/` scans |
| `bench_punct.py` | red-mark segmentation vs CLC `/separate-sentences` → `punct_report.tsv` |
| `verify.py` | CER report candidate-vs-API benchmark → `verify_report.tsv` |
