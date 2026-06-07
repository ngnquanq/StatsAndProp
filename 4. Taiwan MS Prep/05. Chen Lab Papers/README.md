# Chen Lab Papers (NTU AIS Lab)

These are Shang-Tse Chen's own papers. Read at least Trap-MID and DRAG before sending the cold email — you must be able to reference one of them specifically with a concrete observation, not just "I read your paper."

## Reading order

| # | File | Venue | What it covers | Priority |
|---|---|---|---|---|
| 1 | quasiconcave_smoothing_aaai2024.pdf | AAAI 2024 | Improves certified radius in randomized smoothing via quasiconcave optimization. Requires reading randomized_smoothing_cohen_2019.pdf first. | Medium |
| 2 | asdr_adversarial_training_iclr2024.pdf | ICLR 2024 | Annealing Self-Distillation Rectification — improves adversarial training by correcting overconfident predictions near the decision boundary. Builds on TRADES. | Medium |
| 3 | block_reflector_orthogonal_icml2025.pdf | ICML 2025 (Spotlight) | Certified robustness via orthogonal weight matrices constructed from block reflectors. Most theory-heavy paper in the lab. | Low (for now) |
| 4 | trap_mid_neurips2024.pdf | NeurIPS 2024 | **Read this first.** Trapdoor-based defense against model inversion attacks. Plants a trapdoor in training so inversion attacks produce a detectable fake image. Directly relevant to your thesis direction. | **High** |
| 5 | drag_icml2025.pdf | ICML 2025 | Data Reconstruction Attack using Guided Diffusion. Uses diffusion models to reconstruct training data from model gradients. Most recent privacy attack paper from the lab. | **High** |

## What to extract from each paper

For **Trap-MID** — answer these before the cold email:
- What is the trapdoor mechanism? How does it differ from standard defenses like DP?
- What datasets did they evaluate on? (CelebA, FFHQ — all image datasets)
- What's the open question? → Nobody has applied Trap-MID style defense to *tabular behavioral data*. That's your angle.

For **DRAG** — answer these:
- How does guided diffusion improve over GAN-based inversion (KEDMI)?
- What does the attack require from the model? (gradient access = white-box)
- What makes CERT data a different threat model? → No image structure to exploit; behavioral sequences are the "pixels"

## Open questions in each paper (your research angles)

These are limitations the authors acknowledge or that careful reading reveals. Use one as the basis for your cold email and your thesis proposal.

**Trap-MID open questions:**
1. **Adaptive attacker** — the defense assumes the attacker doesn't know trap samples exist. An attacker who probes for output discontinuities (trying random inputs near the decision boundary) might detect and avoid the trap. The paper doesn't evaluate adaptive adversaries.
2. **Tabular/behavioral data** — all experiments are on CelebA and FFHQ (face images). No one has tested whether trapdoor-based defense works on non-image structured data (logs, transaction sequences). This is your exact domain.
3. **Trap sample poisoning** — what if an attacker poisons the training pipeline to remove traps before they take effect? Trap-MID assumes a trusted training environment.

**DRAG open questions:**
1. **White-box requirement** — DRAG needs gradient access. The paper doesn't address the black-box case (score-only or output-only access), which is more realistic in enterprise deployment.
2. **DP-SGD robustness** — does DRAG still reconstruct accurately when the target model was trained with DP-SGD (Gaussian noise on gradients)? The paper doesn't test this. If DP breaks DRAG, that's evidence for DP as a practical defense.
3. **Behavioral/sequential data** — all experiments on image models. Reconstruction via diffusion assumes spatial structure. What's the analog for time-series behavioral logs?

**Your thesis angle (the intersection):**
> Apply MIA (LiRA) + model inversion (DRAG-style or KEDMI) to a tabular behavioral anomaly detector trained on CERT data. Test Trap-MID style defense on non-image data. This is a gap that exists in all three of Chen's recent papers simultaneously.

---

## Cold email hook (use one of these)

Option A (Trap-MID angle):
> "Reading Trap-MID, I was struck by the trapdoor verification mechanism — it elegantly separates detection from prevention. I've been wondering whether a similar approach could work on tabular behavioral models, where there's no pixel structure to exploit but the feature correlations might create an analogous vulnerability."

Option B (DRAG angle):
> "DRAG's use of the score function as a reconstruction signal is a clean generalization of gradient-based inversion. It made me think about whether diffusion-based reconstruction is feasible on behavioral log data, where the 'image' is a time-series of access events rather than pixels."
