# Taiwan MS Research Notes
*Compiled June 2026*

---

## 1. Career Direction

**Target role:** Applied Scientist at an AI safety or ML security company.
Not necessarily a PhD — evaluate after Master's whether a top-venue publication + MS + IAM background is sufficient.

**Best-fit companies:** Anthropic, Google DeepMind (responsible AI), Microsoft (AI Red Team), Meta (Trust & Safety), enterprise AI security startups.

**Your identity:** ML security researcher who comes from enterprise IAM. Not "ML researcher who pivoted." The IAM background (NAB, SailPoint, CyberArk, behavioral pipelines) is the differentiator — nobody at ICML has this combo.

**Causal inference:** Don't grow it during Master's, don't let it atrophy. Read one paper/month. It's your fallback if AI safety market consolidates.

---

## 2. The Plan (summary)

| Phase | When | Goal |
|---|---|---|
| Portfolio project | Now → Oct 2026 | Build privacy attacks on CERT dataset, publish on GitHub |
| Cold email | Oct 2026 | Email Shang-Tse Chen with portfolio project live |
| Applications | Jan–Mar 2027 | NTU MS + MOE scholarship + backups |
| Relocation | Apr–Aug 2027 | Student visa → ARC → Taipei |
| Master's Year 1 | Sep 2027–Aug 2028 | SPML course + lock thesis direction + submit workshop paper |
| Master's Year 2 | Sep 2028–Aug 2029 | Top-venue paper + PhD applications (or direct AS job search) |

**Immigration path:** Student visa → ARC → post-graduation ARC (2 years) → work permit. Or: Taiwan MS → US PhD → F-1 → OPT → H1B → Green Card.

---

## 3. Portfolio Project

**Title:** Privacy Attacks on Enterprise Access Control Models

**Dataset:** CERT Insider Threat v6.2 (CMU SEI)
- `logon.csv`, `http.csv`, `email.csv`, `file.csv`, `device.csv`
- Features: after-hours login ratio, external email count, USB events, large file transfers
- Label: insider threat (binary)

**What to build:**
1. Train user behavior anomaly detector (XGBoost + LSTM baseline)
2. Mount membership inference attack (shadow model / LiRA)
3. Mount model inversion attack (gradient-based input optimization)
4. Add SHAP explanations of model vulnerability
5. Add DP-SGD defense (Opacus, 3 lines)
6. Clean README + 2-page research framing write-up

**Repo structure:**
```
cert-privacy-attacks/
├── README.md
├── data/              ← CERT preprocessing scripts
├── models/
│   ├── anomaly_detector.py
│   └── train.py
├── attacks/
│   ├── membership_inference.py
│   └── model_inversion.py
├── defenses/
│   └── dp_training.py
├── explainability/
│   └── shap_analysis.py
└── notebooks/results.ipynb
```

**Libraries:** `torch`, `opacus`, `shap`, `scikit-learn`, `pandas`

---

## 4. Technical Skills to Build

### Tier 1 (build first)
- PyTorch custom training loops (Dataset, DataLoader, training loop, checkpoints, GPU)
- Membership inference — shadow model method (Shokri et al. 2017) then LiRA (current SOTA)
- CERT dataset preprocessing

### Tier 2
- Model inversion for tabular data (Fredrikson et al. 2015)
- DP-SGD via Opacus
- FGSM + PGD on CIFAR-10 (not for portfolio, for Chen meeting fluency)
- Reproduce one result from Trap-MID paper

### Keywords for solid foundation

**Math**
- Concentration inequalities (Hoeffding, Chernoff)
- Information theory — entropy, mutual information, KL divergence, Rényi divergence
- Convex optimization — duality, Lagrangian, minimax
- Statistical learning theory — PAC learning, Rademacher complexity, VC dimension
- Game theory — zero-sum games, Nash equilibrium

**ML Theory**
- Bias-variance-robustness tradeoff
- Empirical risk minimization vs. robust risk minimization
- Bayesian inference — posterior, likelihood ratio
- PAC-Bayes bounds

**Adversarial ML**
- Lp threat model (L∞, L2, L0)
- PGD (Projected Gradient Descent)
- TRADES loss
- Certified robustness vs. empirical robustness
- Randomized smoothing (Cohen et al. 2019)
- AutoAttack

**Privacy Attacks on ML**
- Differential privacy (ε-δ DP, Rényi DP)
- DP-SGD (composition theorem, sensitivity, clipping)
- Membership inference — shadow model, LiRA
- Model inversion — gradient-based, GAN-based (KEDMI, PLGMI)
- Privacy auditing
- Memorization in neural networks

**LLM Safety**
- RLHF, DPO (Direct Preference Optimization)
- Jailbreaking — GCG, AutoDAN, PAIR, many-shot
- Task vectors, model merging (TIES, DARE)
- Prompt injection
- Red teaming LLMs

**Security Domain (your differentiator)**
- Behavioral analytics / UEBA (User and Entity Behavior Analytics)
- Insider threat detection
- Zero trust architecture
- Threat modeling — STRIDE, MITRE ATT&CK
- AI red teaming

---

## 5. Target: Shang-Tse Chen (NTU AIS Lab)

**Email:** stchen@csie.ntu.edu.tw
**Lab:** https://ntuaislab.github.io/
**Homepage:** https://www.csie.ntu.edu.tw/~stchen/

**Research pillars:** Robustness · Privacy · Fairness

**Recent publications:**
- ICML 2025 ×2 (certified robustness, spotlight)
- NeurIPS 2024 (Trap-MID: model inversion defense)
- ICLR 2024 (adversarial training)
- EMNLP 2024 (model merging for alignment)

**Current lab members (as of 2025):**
- PhD: Bo-Han Kung, Hsuan Su
- MS: 9 students (Zhen-Ting Liu, Hung-Yeh Chien, Yu-Ling Hsu, Kuan-Hsun Li, Yu-Che Huang, Edward Lee, Bo-Han Lai, Yu-Cheng Cheng, Kin-Fong Chao)
- RA: Jun-Jie Wang

**Actively recruiting** MS students. Expects: proactive attitude, linear algebra + probability background, ideally ML coursework.

**Cold email timing:** October 2026
**Cold email structure (under 250 words):**
1. Hook: reference Trap-MID or DRAG — one sentence on what insight struck you
2. Bridge: NAB IAM background + XAI publications + GitHub project (privacy attacks on IAM data)
3. Ask: applying to NTU MS for September 2027, would welcome a short call

---

## 6. NTU CSIE MS Program — Official Requirements

**Source:** MS_Program_Requirements_2014.docx (official NTU CSIE document)

### Mandatory
| Requirement | Rule |
|---|---|
| Advisor | Must choose before end of Semester 2. Submit consent form every semester. |
| MS Thesis | Required in final semester. |
| Special Project | Required every semester except first. Must complete ≥ 2 semesters. |
| Seminar | Must complete ≥ 2 semesters. |

### Coursework
- **24 credits** of actual courses (thesis / special project / seminar do NOT count toward these 24)
- At least **15 of 24 credits** must be from Information Sciences departments (course codes starting with 902, 922, or 944)
- No mandatory specific courses (for 2014+ entry)

### Dismissal rule
- If you don't have an advisor by start of Semester 3, you're out.

---

## 7. NTU CSIE Graduate Courses (confirmed)

### Core for Chen's lab direction

| Course | Professor | Area |
|---|---|---|
| Security & Privacy of ML (SPML) | Shang-Tse Chen | Adversarial attacks, privacy attacks, LLM safety, fairness |
| Machine Learning | Hsuan-Tien Lin | VC theory, SVM, ensembles, neural nets |
| Deep Learning Algorithms & Implementations | Chih-Jen Lin | SGD theory, backprop, CUDA, transformers, autograd from scratch |
| Cryptography and Network Security (CSIE 7190) | Hsu-Chun Hsiao | Crypto, authentication, TLS, DDoS, anonymity |

### Other available courses (by research area)

**AI / ML**
- Foundations of AI
- Natural Language Processing / Dialogue Systems (Yun-Nung Chen)
- Computer Vision (Chu-Song Chen, Winston Hsu, Tsung-Wei Ke)
- Optimization Methods / High-Dimensional Statistics (Yen-Huan Li)
- Trustworthy AI (Shao-Yuan Lo)

**Theory & Systems**
- Algorithm Design and Analysis (Kun-Mao Chao, Shang-En Huang)
- Theory of Computation (Yuh-Dauh Lyuu)
- Operating Systems / Security (Shih-Wei Li)
- Parallel Computing (Pangfeng Liu)
- Advanced Engineering Mathematics

**Networks & Systems**
- Computer Networks / 5G (Ai-Chun Pang, Phone Lin)
- Distributed ML Systems (Cheng-Fu Chou)

### SPML Full Syllabus (Fall 2025)

| Week | Topic |
|---|---|
| 1 | Course Intro |
| 2 | Adversarial Attacks & Defenses (PGD, TRADES, ASDR, robustness scaling) |
| 3 | Certified Defenses + Theory (randomized smoothing, orthogonal layers) |
| 4 | Poisoning & Backdoor Attacks (student presentations) |
| 5 | Jailbreaking LLMs |
| 6 | LLM/VLM Adversarial Attacks (student presentations) |
| 7 | Prompt Injection + RAG Security (student presentations) |
| 8 | Hallucination + project proposals due |
| 9 | Model & Data Privacy |
| 10 | Machine Unlearning + Model Immunization |
| 11 | Fairness in ML |
| 12 | Membership Inference + Federated Learning |
| 13 | LLM Memorization + Multi-Agent Security |
| 14 | Guest Lecture |
| 15–16 | Final Project Presentations |

**Grading:** 50% final project (6-page ICML-format paper), 20% presentations, 20% reading critiques, 10% participation.

### Recommended 24-credit plan for Chen's lab

| Semester | Courses | Credits |
|---|---|---|
| 1 | SPML + Machine Learning + Deep Learning Algorithms | ~9 |
| 2 | Cryptography & Network Security + 1 elective (NLP or Optimization) | ~6–9 |
| 3 | 1–2 electives + thesis prep | ~3–6 |
| 4 | Thesis only | 0 coursework |

Special Project runs every semester in parallel — this is Chen supervising your research directly.

---

## 8. Financial Planning (Taiwan)

| Source | Monthly (NT$) | Monthly (USD) |
|---|---|---|
| MOE Scholarship | 20,000 | ~620 |
| Lab RA stipend | 8,000–15,000 | ~250–470 |
| Total estimate | 28,000–35,000 | ~870–1,090 |

Taipei living costs: ~NT$20,000–25,000/month (rent NT$8,000–12,000 + food + transport).

**MOE Taiwan Scholarship:** Application window February–March 2027. Award: NT$20,000/month + NT$40,000/semester tuition. 2-year cap for Master's. Apply via TECRO Vietnam (Ho Chi Minh City).

---

## 9. Backup Options

**NYCU — Shiuhpyng Shieh (DSNS Lab)**
- Email: ssp@nycu.edu.tw
- Area: network security, intrusion detection
- Note: alumni go to Taiwan industry (TSMC, MediaTek), not international PhD — weaker stepping stone

**NCKU — Cheng-Te Li (NetAI Lab)**
- Email: chengte@ncku.edu.tw
- Area: network AI, data mining
- Actively recruiting

**Singapore (if Taiwan doesn't work out)**
- NUS / NTU Singapore — world-class, English-medium, Employment Pass → PR after 2–3 years of work
- Stronger immigration pathway than Taiwan

---

## 10. Key Links

- Chen's lab: https://ntuaislab.github.io/
- SPML syllabus: https://www.csie.ntu.edu.tw/~stchen/teaching/spml25/
- NTU admissions: https://admissions.ntu.edu.tw/apply/degree-students/international-students/
- MOE scholarship: https://taiwanscholarship.moe.gov.tw
- CERT dataset: https://resources.sei.cmu.edu/library/asset-view.cfm?assetid=508099
- Adversarial Robustness Toolbox: https://github.com/Trusted-AI/adversarial-robustness-toolbox
- RobustBench: https://robustbench.github.io/
- Opacus (DP-SGD): https://opacus.ai/
- ML Privacy Meter: https://github.com/privacytrustlab/ml_privacy_meter
- Learning from Data (textbook): https://work.caltech.edu/textbook.html
