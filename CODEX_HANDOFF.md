# Handoff — HVH Sino-Nôm OCR corpus (Đề tài 4): state & next steps

**Date:** 2026-07-05 · **Machine:** this Linux box (RTX 3060 12 GB, driver 580/CUDA 13)
**Project:** `2. Natural Language Processing/Lab/hvh_pipeline/` — read its `README.md`
(architecture) and `HANDOFF.md` (benchmark methodology + run order) first. This file
adds session results, the model-survey findings, and the prioritized to-do list.

## Machine state (already set up — do not redo)

- Conda env **`hvh`** (`~/anaconda3/envs/hvh/bin/python`, py3.11): paddlepaddle-gpu
  3.0.0 (cu126), paddleocr 3.7, torch 2.12 (cu130), transformers, rapidfuzz.
  GPU verified for both paddle and torch. A separate **`py310-ml`** env is
  referenced by the NomNaOCR candidate (TensorFlow) — see `HANDOFF.md`.
- **Crawl COMPLETE**: all 38 units, 2071 pages in `images/` (git-ignored).
- Fine-tuned PaddleOCRv5 rec weights in `models/PP-OCRv5_server_rec_finetuned/`;
  stock `PP-OCRv5_server_det` in `~/.paddlex/official_models/`.
- Cache (`cache/`, git-ignored): API benchmark pages for HVH_090 (all 11) +
  3 sampled pages each of HVH_093/094; `.local.json` (PaddleOCRv5 candidate)
  for every unit crawled at the time of the bulk run — **re-run
  `run_pipeline.py --engine local` once to cover the units crawled later**
  (idempotent, seconds per unit on GPU).
- Git: candidate-engine infrastructure (`candidate_ocr.py`, `nomnaocr_ocr.py`,
  `bench_nomnaocr.py`, multi-candidate `verify.py`/`run_pipeline.py`,
  `third_party/nomnaocr`) is **uncommitted** on `master` as of writing.

## Benchmark results so far (CER vs CLC API, `verify_report.tsv`)

| unit | content | candidate | mean CER | verdict |
|---|---|---|---|---|
| HVH_090 (11 pp) | Nôm verse | PaddleOCRv5 fine-tune (`local`) | **0.477** | FAIL — structural |
| HVH_093 (3 pp) | mixed Han/Nôm | `local` | **0.419** | FAIL |
| HVH_094 (3 pp) | Han prose | `local` | **0.195** | PASS (≤0.3 gate) |
| HVH_090 (11 pp) | Nôm verse | `nxquang-al/finetuned-trocr-base-vietnamese-nom` | **0.976–0.998** (all 3 orientations) | FAIL — outputs well-formed but wrong glyphs; likely stub checkpoint (1 download) |

Root causes / signals worth keeping:
- The PaddleOCRv5 fine-tune **cannot emit 26.5% of HVH_090's gold characters** —
  its 18,383-entry charset has only 205 CJK Ext-B+ entries, and Nôm lives there
  (𧡊 𤛠 …). Charset gap = hard CER floor; no tuning fixes it.
- The model's own mean line confidence tracks CER (0.81→0.20, 0.69→0.42,
  0.64→0.48): **per-unit mean of `scores` in `.local.json` is a free
  Nôm-heaviness router** — no gold needed.
- Local detection misses dense interlinear/small script (31 vs API's 38 lines on
  HVH_093 p010), inflating CER via deletions. Tunable via `TextDetection`
  params in `local_ocr.py` if it matters.
- TrOCR input format note: rotated-90°-CCW line crops gave per-line char counts
  matching gold (18/18) — that orientation is right for TrOCR-family candidates.

## Model survey (web research, completed today) — ranked

1. **TrOCR Nôm fine-tunes** — `tt1225/finetuned-trocr-base-vietnamese-nom`,
   `tt1225/finetuned-trocr-small-vietnamese-nom` (UNTESTED; the tested
   `nxquang-al` sibling failed, but tt1225's `vocab.json` (6,197 tokens) is
   verified to contain Ext-B surrogate-pair entries; nxquang-al used a 31K Nôm
   vocab). ViT 224×224 encoder + Nôm RoBERTa decoder; trained on NomNaOCR
   (38K real lines) after synthetic pretraining (IHR-NomDB). No published CER;
   no license/model card. Bench with `bench_trocr.py <model_id>`. Avoid the
   `pretrained-*` variants (synthetic-only).
2. **NomNaOCR original models** — github.com/ds4v/NomNaOCR (IEEE paper
   10013842). CRNN+CTC (val CER 0.031) and SC-CNNxTransformer (val CER
   **0.029** — best published Nôm numbers; beware 64% train/val char overlap,
   expect worse on unseen works). TF2/Keras, weights on Google Drive (link in
   their README), MIT license. Input = vertical patches rotated 90° to
   horizontal. **Already wired as a candidate** (`nomnaocr_ocr.py`,
   `--engine nomnaocr`, `bench_nomnaocr.py`) — only the external assets are
   missing: clone to `models/NomNaOCR/source`, put `All.txt`/`vocab.json` in
   `models/NomNaOCR`, extract weights to `models/NomNaOCR/weights` (keep the
   authors' `Fine-tuning/`, `NomNaOCR/` folder names), run from `py310-ml`.
3. **NDLkotenOCR-Lite PARSeq** — github.com/ndl-lab/ndlkotenocr-lite. ONNX,
   CC BY 4.0, solid classical-CJK line recognizer BUT its ~7,500-char charset
   has almost no Ext-B → **not for Nôm as-is**; credible as (a) a second
   Han-prose candidate and (b) a fine-tune base: its `train/` pipeline +
   NomNaOCR data + CLC pseudo-labels from our 2071 pages + expanded charset.
4. **Qwen2.5-VL-7B 4-bit** (fits 12 GB) — byte-level BPE = no charset ceiling,
   but zero published Nôm evidence and high hallucination risk on rare
   variants. Bench 10 lines before investing.

Skip: `Nicias/ocr_nom` (French ID-card OCR — "nom" = name field);
`Haruoki/HanNomOCR` space (its CRNN/PARSeq line ONNX models lack the
`charset.json` needed to decode outputs; its `parseq_ndl_*` = repackaged #3);
kuzushiji/kraken/CHAT models (no Nôm charset); GOT-OCR2 (no Ext-B/vertical
evidence); CLC's own models (never released — that's the benchmark API).

## Next steps, in order

1. **Bench tt1225 TrOCR variants** (30 min): `cd hvh_pipeline &&
   python bench_trocr.py tt1225/finetuned-trocr-base-vietnamese-nom` (env
   `hvh`; script tests 3 orientations vs HVH_090 gold — expect rot_ccw to be
   the valid one).
2. **Fetch NomNaOCR assets and bench** (the infrastructure is already wired;
   see `HANDOFF.md` "Current benchmark status" for exact asset layout), then
   `conda run -n py310-ml python bench_nomnaocr.py HVH_090`. This is the most
   promising Nôm candidate (published CER 0.03 in-domain).
3. **Acceptance gate** per candidate: mean CER < 0.3 on HVH_090 (Nôm) —
   below 0.2 is adoption-grade. Record every result in `verify_report.tsv`
   via candidate cache files + `verify.py` (multi-candidate aware).
4. **Complete the PaddleOCRv5 draft pass** over late-crawled units:
   `python run_pipeline.py --engine local` — also produces the `scores` used
   for routing.
5. **Routing report** (small new script): per unit, mean/median `scores` from
   `.local.json` → TSV `(unit, pages, mean_score, router)`. Units < ~0.7 mean
   score = Nôm-heavy → the 4-person API team (`assignments.py`) should OCR
   those FIRST; Han-prose units (HVH_107's 21 legal volumes, HVH_098, HVH_094…)
   can ship local/candidate drafts meanwhile.
6. **Widen gold**: `python verify.py --sample 3 <unit>` on unverified units
   when API budget allows (~5 pages/burst, 75s cooldowns; never run two API
   jobs at once — same rate-limit bucket).
7. **Final outputs**: after caches settle, `python run_pipeline.py --reseg`
   (rebuilds `output/` from cache, segmenting via the API). Punct-split seg on
   unpunctuated scans is poor — see README caveat.
8. If no candidate passes on Nôm: fine-tune route #3 (NDL PARSeq pipeline,
   expanded charset, NomNaOCR + CLC pseudo-labels) — a day-scale task, or
   accept API-only coverage for Nôm-heavy units via the team split.

## Verification quick refs (from `hvh_pipeline/`, env `hvh`)

```bash
python local_ocr.py --selftest              # geometry tests, no GPU
python verify.py HVH_090                    # paddle candidate ≈ 0.477
python run_pipeline.py --engine local HVH_090   # idempotent, ~3 s
```
