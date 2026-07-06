# Report — Đề tài 4 (HVH): Building a monolingual chữ Hán corpus for Vietnamese history

**Works:** HVH_090–HVH_107 (18 works, 38 units — HVH_107 *Hoàng Việt Luật Lệ* has 21
volumes), scanned from lib.nomfoundation.org. **Scope of this report:** corpus
construction pipeline, the OCR benchmarking study, results, and current status.

## 1. Task and deliverables

Per `../OutputRequirement.pdf` (section B), each unit must ship:

- `output/HVH_xxx/HVH_xxx_raw.txt` — raw OCR text;
- `output/HVH_xxx/HVH_xxx_seg.tsv` — sentence segmentation, `[sentence_id]\t[sentence]`;
- multi-volume works nest per-volume folders (`output/HVH_107/HVH_107_01/…`).

The input is ~2,071 page images of classical Vietnamese Hán and Nôm text in
traditional vertical layout (columns read right-to-left, top-to-bottom within a
column), so the central technical problem is **OCR quality on Sino-Nôm script**.

## 2. Pipeline architecture

Four resumable stages, all sharing one per-page cache (`cache/<unit>/`):

1. **Crawl** (`download_images.py`) — downloads page JPEGs from
   lib.nomfoundation.org with retry/backoff; survives per-volume failures.
   Status: **complete, 38/38 units, 2,071 pages**.
2. **OCR** (`run_pipeline.py --engine …`) — writes one JSON per page. Two tracks:
   - **API benchmark track**: the CLC Kim Hán Nôm API
     (tools.clc.hcmus.edu.vn) is the reference system. It rate-limits
     sustained anonymous use (~5 pages per burst, 75 s cooldowns), so the
     corpus is split four ways (`assignments.py --person P1..P4`) and each
     team member runs their share from their own machine (separate
     rate-limit buckets). Merging results = copying cache folders together.
   - **Candidate-model track**: local GPU models with no rate limit
     (RTX 3060). Candidates write suffixed cache files
     (`page_NNN.local.json`, `.trocr.json`, `.nomnaocr*.json`) that never
     collide with API files (`page_NNN.json`); wherever an API result
     exists it wins when outputs are regenerated.
3. **Segmentation** — for HVH image OCR, each ordered OCR line is emitted as
   one `_seg.tsv` row. Sentence ids preserve document, page, and line/sentence
   position, e.g. `HVH_090_000001_000001`.
4. **Verification** (`verify.py`) — character error rate (CER, Levenshtein
   distance / reference length) of every candidate against the API text on
   pages that have both, reported per (unit, candidate) in
   `verify_report.tsv`; `--sample N` spends a little API budget on random
   candidate-only pages to widen the benchmark.

For local candidates, text detection is PaddleOCR `PP-OCRv5_server_det`
followed by a reading-order step that groups line boxes into vertical columns
(>50 % x-interval overlap → same column), orders columns right-to-left and
lines top-to-bottom. Line ordering was validated 1:1 against the API's output
on HVH_090; all candidate recognizers reuse the same boxes so CER comparisons
are recognition-only.

## 3. OCR benchmark study

**Gold data:** CLC API output for all 11 pages of HVH_090 (Nôm verse,
*Đinh Triều Sự Chí*) plus 3 sampled pages each of HVH_093 (mixed Hán/Nôm) and
HVH_094 (Hán prose). **Acceptance gate:** mean CER < 0.3 (< 0.2 =
adoption-grade).

### Results (CER vs CLC API)

| candidate | HVH_090 (Nôm verse, 11 pp) | HVH_093 (mixed, 3 pp) | HVH_094 (Hán prose, 3 pp) | verdict |
|---|---|---|---|---|
| PaddleOCRv5 fine-tune (MinhDS/Fine-tuned-PaddleOCRv5, HCMUS) | **0.477** | 0.419 | **0.195** | PASS on Hán prose only |
| TrOCR `nxquang-al/finetuned-trocr-base-vietnamese-nom` | 0.976–0.998 (3 orientations) | — | — | FAIL |
| TrOCR `tt1225/finetuned-trocr-base-vietnamese-nom` | 0.975–0.999 (3 orientations) | — | — | FAIL |
| NomNaOCR CRNN+CTC (verified decode, vertical) | 0.971 | — | — | FAIL — no domain transfer |
| NomNaOCR SC-CNN×Transformer (verified decode, vertical) | 0.975 | — | — | FAIL — no domain transfer |

### Findings

1. **Charset coverage is the hard ceiling for Nôm.** The PaddleOCRv5
   fine-tune's 18,383-entry dictionary contains only 205 characters from CJK
   Extension B and beyond, where much of Nôm lives (𧡊, 𤛠, …). 26.5 % of
   HVH_090's gold characters are *not in the model's output vocabulary at
   all* — a structural CER floor of ~0.27 that no tuning can fix. The same
   model passes on Hán prose (0.195), which stays inside the base charset.
2. **Model confidence is a free Nôm-heaviness router.** The fine-tune's mean
   line confidence tracks CER almost linearly (0.81 → CER 0.20,
   0.69 → 0.42, 0.64 → 0.48). Per-unit mean confidence from the bulk local
   pass therefore classifies units into "ship the local draft" (Hán prose)
   vs "route to the API team first" (Nôm-heavy) — without needing gold.
3. **NomNaOCR's published numbers (val CER 0.029) did not transfer — and we
   can prove it's the model, not our harness.** A first run scored ≈ 0.97
   because the decode vocabulary (7,479 characters ordered by frequency
   with ties broken by first occurrence in the dataset's `All.txt`) had
   been rebuilt from a copy with a different line order — same characters,
   same counts, scrambled tie groups, so every token decoded to a
   same-frequency sibling. After installing the byte-exact Kaggle
   `Patches/All.txt`, the harness decodes the authors' own demo patch
   perfectly (CRNN 8/8 characters) — yet HVH_090 stays at CER 0.971/0.975.
   The models emit valid but wrong (and truncated: their decoder caps at
   24 characters, our columns run ~27) text on unseen works. This matches
   the paper's own caveat: trained on 3 works with 64 % train/val
   character overlap, the models do not generalize to new manuscripts.
4. **Both public TrOCR Nôm checkpoints are duds** (plausible Nôm glyphs at
   correct line lengths, wrong content, best CER 0.975). Unlike NomNaOCR
   they carry their own self-contained tokenizers, so no decode-table
   issue is possible — the checkpoints are simply weak.
5. **Detection also loses lines on dense pages** (31 vs the API's 38 lines
   on HVH_093 p010, dense interlinear script), inflating CER via deletions.

### Conclusion of the study

No freely available local model currently reaches the gate on Nôm-heavy
text; the CLC API remains the only adequate system for those units. The
adopted strategy is therefore **routing**: Hán-prose units (e.g. HVH_094,
HVH_098, HVH_107's 21 legal volumes) ship local drafts at CER ≈ 0.2 that
API results progressively upgrade, while Nôm-heavy units (flagged by the
confidence router) are prioritized for the 4-person API track.

## 4. Current status

- Crawl complete: 2,071 pages, 38/38 units.
- API benchmark cache: 17 pages (HVH_090 complete + HVH_093/094 samples).
- Local candidate cache: 221 pages across HVH_090–095; the remaining units
  need one idempotent `run_pipeline.py --engine local` pass (~minutes on GPU).
- Outputs generated so far: HVH_090–HVH_095 (HVH_090 API-quality; others
  draft-quality pending API upgrades).
- `verify_report.tsv` records all candidate scores and regenerates from the
  cache at any time (`python verify.py`).

## 5. Red-ink punctuation segmentation (pilot, HVH_090)

The manuscripts carry reader-added punctuation in red ink (mực chu): slanted
dashes after clause breaks and small hollow rings (khuyên ○). These are
invisible to every OCR engine, but recoverable with OpenCV — **only on the
`/large/` ~2000px scans** (`download_images.py --large`); on the default
~700px crawl the marks are 2–4 px and cannot even be classified.

Pipeline (`punct_detect.py` → `run_pipeline.py --reseg --punct`):

1. HSV red masking (two hue bands) + connected components, filtered by size,
   distance from the page border, and containment in a detector line box;
   fragments of one physical mark are merged.
2. Circle-vs-stroke by shape: khuyên rings are round **and hollow**
   (minAreaRect elongation ≤ 1.8, fill ≤ 0.6); everything else — slashes and
   solid dots — is a stroke. Zoomed spot checks on HVH_090 p003/p009 confirm
   the ring detections are genuine khuyên.
3. Marks anchor to (line, relative Y) on the detector's line grid, then remap
   onto the API text lines by CER-based sequence alignment
   (`punct_detect.align_lines`), so API/local line-count disagreements don't
   lose pages.
4. Rings insert `。`, dashes insert `、`; page lines are joined in reading
   order and split at `。`. Splits shorter than 4 characters merge into the
   previous sentence — consecutive rings often flag proper names (one ring
   per character, e.g. 丁佃), not back-to-back sentence ends.

**Pilot result:** 11/11 HVH_090 pages segmented; 211 physical lines →
85 sentence units (~117–148 raw marks per page, of which 2–19 rings).
Sentences read as coherent prose spans with clause-level `、` inside.

**Baseline check:** the CLC `/separate-sentences` endpoint was also cached
per page (`bench_punct.py` → `punct_report.tsv`). It proved too coarse to be
a reference for raw Nôm prose — 1–7 boundaries per ~500-character page at
positions that never coincide with the red marks (boundary F1 = 0 at ±2
chars). The red marks are a human reader's segmentation; the disagreement
mainly reflects the CLC splitter's weakness on unpunctuated Nôm, so proper
evaluation needs a small hand-annotated gold sample.

**Open questions:** (a) some khuyên may mark names/emphasis rather than
sentence ends — needs a Hán-Nôm expert ruling; (b) mark→character-index
mapping is proportional within the line box, so ±1-character insertion error
is possible on uneven handwriting; (c) only HVH_090 is piloted — other units
need their `--large` scans (and `.local.json` geometry) before `--punct`
applies.

## 6. Limitations and next steps

- **Segmentation**: `_seg.tsv` defaults to line units; `--punct` (section 5)
  upgrades pages that have red-mark detections to sentence units. A manual
  cleanup pass can still merge or split units if stricter boundaries are
  required.
- **All surveyed public candidates are now benchmarked and fail on Nôm.**
  The remaining local option is fine-tuning our own recognizer with an
  Ext-B-complete charset on NomNaOCR data + CLC pseudo-labels from our
  2,071 pages (day-scale task); otherwise Nôm-heavy units are covered by
  the team's API track per the routing strategy.
- **NER** (`_ner.json`) applies when input is text and is not part of the
  OCR scope covered here.
- CER here is *agreement with the CLC API*, not with human ground truth —
  the API itself makes errors, so candidate CERs are slightly pessimistic.
