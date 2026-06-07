# SPML Missing Papers

Papers for the SPML weeks not covered by other folders. These complete the full 16-week syllabus.

---

## Week 4 — Poisoning & Backdoor Attacks

### backdoor_badnets_gu_2017.pdf
**"BadNets: Identifying Vulnerabilities in the Machine Learning Model Supply Chain"** — Gu et al. (2017)
- The original backdoor attack: embed a trigger pattern into training data → model behaves normally except on triggered inputs
- Example: a stop sign with a sticker → misclassified as speed limit sign
- Foundation for understanding backdoor defense literature

### backdoor_spectral_signatures_tran_2018.pdf
**"Spectral Signatures in Backdoor Attacks"** — Tran et al. (NeurIPS 2018)
- Defense against BadNets: poisoned samples leave detectable signatures in feature representations
- Uses SVD on activations to identify and filter poisoned training data

---

## Week 8 — Hallucination

### hallucination_survey_2023.pdf
**"Survey of Hallucination in Natural Language Generation"** — Ji et al. (2023)
- Taxonomy: intrinsic hallucination (contradicts source) vs. extrinsic (unverifiable)
- Evaluation methods and mitigation strategies
- Maps to SPML Week 8 content on why LLMs hallucinate

---

## Week 10 — Machine Unlearning

### machine_unlearning_cao_2015.pdf
**"Towards Making Systems Forget with Machine Unlearning"** — Cao & Yang (2015)
- Original machine unlearning paper: how to make a trained model "forget" specific training samples
- Motivation: GDPR right to erasure
- Core challenge: retraining from scratch is too expensive

---

## Week 11 — Fairness

### fairness_definitions_verma_2018.pdf
**"Fairness Definitions Explained"** — Verma & Rubin (2018)
- Explains 20+ fairness definitions (demographic parity, equal opportunity, calibration, etc.)
- Shows that many definitions are mutually incompatible
- Essential background for SPML Week 11 and for framing any future fairness work

---

## Additional Privacy Attack Papers

### plgmi_model_inversion_yuan_2022.pdf
**"PLUG & PLAY Generative Model Inversion"** — Yuan et al. (2022)
- State-of-the-art GAN-based model inversion
- Bridges KEDMI and diffusion-based approaches
- Compare against DRAG (Chen's paper) — understand why DRAG improves on this

---

## Week 13 — Multi-Agent Security

### multi_agent_security_survey_2024.pdf
**Multi-agent system security survey**
- Covers threat models for multi-agent LLM systems
- Relevant as SPML Week 13 topic

---

## How these fit the SPML syllabus

| SPML Week | Papers in this folder | Papers in other folders |
|---|---|---|
| 4 (Backdoor) | BadNets + Spectral Signatures | — |
| 8 (Hallucination) | hallucination_survey | — |
| 9 (Privacy) | — | `03. Privacy Attacks/` all papers |
| 10 (Unlearning) | machine_unlearning | — |
| 11 (Fairness) | fairness_definitions | — |
| 12 (MIA) | — | `03. Privacy Attacks/lira_carlini_2022.pdf` |
| 13 (Multi-Agent) | multi_agent_security | — |
