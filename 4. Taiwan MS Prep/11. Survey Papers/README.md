# Survey Papers

Read these before diving into the primary papers. Each survey gives you a 10,000-foot view of an entire research area so you know the landscape before going deep.

---

## Files and reading order

### 1. adversarial_ml_survey_papernot_2016.pdf
**"Towards the Science of Security and Privacy in Machine Learning"** — Papernot et al.
- Taxonomizes attack surfaces: training time (poisoning) vs. inference time (adversarial examples)
- Maps threat models: white-box vs. black-box, targeted vs. untargeted
- **Read this first** — gives you the vocabulary for everything in `02. Adversarial ML/`
- ~30 pages, 2 hrs

### 2. privacy_ml_survey_mireshghallah_2020.pdf
**"A Survey of Privacy Attacks in Machine Learning"** — Mireshghallah et al.
- Covers: membership inference, model inversion, attribute inference, model stealing
- Organized by what information is leaked and what the attacker needs
- **Your thesis area** — read before `03. Privacy Attacks/`
- ~40 pages, 3 hrs

### 3. trustworthy_ml_survey_2023.pdf
**"Trustworthy Machine Learning"** — comprehensive survey
- Covers all three pillars of Chen's lab: robustness + privacy + fairness
- Shows how these three areas interact and conflict
- Read before your first meeting with Chen — gives you the big picture of where his lab sits
- ~50 pages, 3 hrs

### 4. llm_safety_survey_2023.pdf
**"A Survey of Large Language Model Safety"** — 2023
- Covers: jailbreaking, prompt injection, backdoors in LLMs, alignment failures
- Maps to SPML weeks 5–7
- Read before Week 5 of SPML
- ~35 pages, 2 hrs

### 5. federated_learning_survey_2019.pdf
**"Communication-Efficient Learning of Deep Networks from Decentralized Data"** (McMahan et al.)
- The original federated learning paper — not a survey per se, but the foundational reference
- Relevant to SPML Week 12 (privacy in federated learning)
- ~11 pages, 1 hr

---

## Recommended reading order

```
Week 1 of prep:
  adversarial_ml_survey → trustworthy_ml_survey
  (get the full landscape before touching primary papers)

Week 2:
  privacy_ml_survey
  (before diving into 03. Privacy Attacks/)

Before SPML Week 5:
  llm_safety_survey

Before SPML Week 12:
  federated_learning_survey
```
