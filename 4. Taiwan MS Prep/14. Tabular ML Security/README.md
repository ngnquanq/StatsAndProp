# 14. Tabular ML Security

Security and privacy papers scoped specifically to **tabular data / traditional ML** (XGBoost, GBDTs, random forests, synthetic data generators like CTGAN). Organized by sub-topic with reading order recommendation.

> Shokri 2017 (MIA) and LiRA 2022 are in `03. Privacy Attacks/` — not duplicated here.

---

## Adversarial Attacks on Tabular Data

| File | Venue | Notes |
|------|-------|-------|
| `constrained_adaptive_attack_simonetto_2024.pdf` | **NeurIPS 2024** | CAPGD + CAA — strongest gradient attack on tabular, drops accuracy up to 96% |
| `tabularbench_simonetto_2024.pdf` | **NeurIPS 2024** (D&B) | 200+ model robustness benchmark, real-world use cases |
| `tabular_fm_robustness_djilani_2025.pdf` | **SaTML 2025** | Tests TabPFN / TabICL under attack; in-context adversarial training defense |
| `adversarial_attacks_tabular_survey_2025.pdf` | arXiv 2025 | First systematic survey of tabular adversarial attacks |
| `tabular_attack_challenges_ghamizi_2024.pdf` | arXiv 2024 | Coherence & consistency issues unique to tabular attacks |

---

## Membership Inference Attacks

| File | Venue | Notes |
|------|-------|-------|
| `mia_tabular_generative_ward_2025.pdf` | **AISec @ CCS 2025** | Ensemble MIAs against CTGAN/VAE/diffusion synthetic data |
| `mia_diffusion_synthetic_tabular_2025.pdf` | arXiv 2025 | MIA specifically on diffusion-based tabular generators |

---

## Model Stealing / Extraction

| File | Venue | Notes |
|------|-------|-------|
| `model_stealing_tramer_2016.pdf` | **USENIX Security 2016** | Foundational paper — covers decision trees, linear models, shallow NNs |
| `barkbeetle_tree_stealing_2025.pdf` | arXiv 2025 | Fault injection to steal decision tree structure |
| `model_extraction_survey_2025.pdf` | arXiv 2025 | Survey of extraction attacks in distributed/cloud settings |

---

## Synthetic Tabular Data Privacy

| File | Venue | Notes |
|------|-------|-------|
| `synthetic_tabular_data_cormode_2025.pdf` | **KDD 2025 + VLDB** | Definitive survey: methods, attacks, defenses for synthetic tabular data |
| `privacy_risks_tabular_generative_2024.pdf` | arXiv 2024 | Benchmarks CTGAN, CopulaGAN, TabDDPM against 8 privacy attacks |
| `rethinking_anonymity_synthetic_ganev_2026.pdf` | arXiv 2026 | Challenges the "synthetic data = private" assumption |

---

## Data Poisoning

| File | Venue | Notes |
|------|-------|-------|
| `machine_unlearning_poisoning_pawelczyk_2025.pdf` | **ICLR 2025** | Unlearning methods fail to remove poisoning across all attack types |
| `safety_efficacy_poisoning_2025.pdf` | arXiv 2025 | Safety-efficacy trade-off under data poisoning |

---

## Recommended Reading Order

```
1. model_stealing_tramer_2016           — model extraction from scratch (USENIX)
2. constrained_adaptive_attack_2024     — adversarial attacks on tabular (NeurIPS)
3. tabularbench_2024                    — benchmark context (NeurIPS)
4. synthetic_tabular_data_cormode_2025  — synthetic data panorama (KDD) ← most relevant day-to-day
5. mia_tabular_generative_ward_2025     — MIA on YOUR synthetic pipelines (CCS)
6. machine_unlearning_poisoning_2025    — poisoning + unlearning (ICLR)
7. tabular_fm_robustness_2025           — if using TabPFN/modern tabular FMs (SaTML)
8. adversarial_attacks_tabular_survey   — fill in the gaps (survey)
```
