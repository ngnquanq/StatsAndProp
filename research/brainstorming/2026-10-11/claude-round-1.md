# Round 1: independent research advisory (Claude)

## What I inspected

**Read:**
- `research/brainstorming/2026-10-11/context.md`.
- The README of the multivariate lecture (`3. High Dimensional Statistics/Lecture/README.md`). It limits scope to one-sample, fixed-dimension, iid inference and explicitly refuses to extend to dependent or high-dimensional data. This confirms the caveat in the context file.
- The first 80 lines of `3. Master Thesis/Lab/lalonde_causal_inference.py`: naive ATE, a balance table, and imports for propensity scores and nearest-neighbour matching.
- The opening of the EDF chapter in the nonparametric study guide (iid EDF variance and covariance), and the chapter list (histogram, KDE, projection, regression).
- `2. Statistical Modeling/.../sec4_autocorrelation/03_consequences.tex` (sandwich variance under autocorrelation).
- The "advantages" slide of the bootstrap presentation. It actually contains mean-shift clustering content, which looks like a copy slip.
- Two tabular ML-security reviews in full (CAPGD/CAA, Simonetto 2024; coherence and class-specific anomaly detection, Itzhakev et al.) and part of a third (DP-TLDM). The CAPGD review notes that its benchmark includes a Lending Club credit dataset.
- Ignored finance files: the lesson note `M1-CounterpartiesAndCreditRisk.pdf` (introductory: default, collateral, deposit insurance, bonds) and the MScFE 560 syllabus. Module 5 of the syllabus covers LTV, DTI and securitization. Its integrity section lists **self-plagiarism** and **"republishing or redistributing any course materials, student's own work"** as violations. Whether that applies to a thesis at another institution is **unverified**; it needs a direct question to the program, not my reading of it.

**Only file names seen:** the causal-inference slide sets (including chapters on RDD, DiD, sensitivity analysis and IV) and the HDS exercises.

**Deliberately not opened:**
- `PhD_Applications/`, CVs and credentials (privacy).
- `claude-round-1.json` and `claude-round-1-prompt.txt`, to keep this round independent.
- The ML, NLP and Book PDFs, the WQU AI-policy PDF and the other `docs/` guides.

I saved nothing because you said not to edit files, even though the context file asks for saved notes.

**Labels used below:** [OBS] means seen locally. [LIT] means literature I recall but have not checked in this session. [ASM] means an assumption. [HYP] means a testable hypothesis. **Nothing here is claimed as novel; that needs a literature search.**

## Five directions (deliberately outside the four starting topics)

### 1. Underwriting thresholds under bunching: regression discontinuity with a manipulated running variable
- **Question:** In agency mortgage data, what is the local effect of crossing LTV = 80% (where mortgage insurance is required) or a FICO pricing-grid cutoff on 24-month serious delinquency, once bunching just below the cutoff is accounted for?
- **Statistics contribution:** Identification and inference when the running variable is manipulated and heaped. Compare donut RD, density tests and partial-identification bounds under manipulation, and report how informative the bounds are.
- **Finance contribution:** Do threshold-based insurance and pricing rules reduce default risk or just move it around? This bears on how pricing grids are designed.
- **Data:** Freddie Mac Single-Family Loan-Level Dataset, free with registration [LIT; terms and sample-file sizes need checking]. Fannie Mae's equivalent can serve as a replication sample.
- **Laptop pilot:** One vintage sample file. Histograms at 80/90/95 LTV, `rddensity`, then naive versus donut `rdrobust` on delinquency. About one day.
- **Closest methods:** Calonico–Cattaneo–Titiunik; Cattaneo–Jansson–Ma density test; Kleven's bunching estimators; Gerard–Rokkanen–Rothe bounds [LIT].
- **Fatal weaknesses:** Several treatments change at the cutoff at once (insurance, price, lender overlays), so the estimand is a bundle. Heavy bunching may make the bounds uninformative. Heaping at round LTVs is partly mechanical.
- **Extension:** Heterogeneity across the regime change around 2008. This also links to the syllabus's LTV/DTI module [OBS].

### 2. Reject inference as partial identification
- **Question:** Using accepted loans (with outcomes) plus rejected applications (no outcomes, few covariates), what are sharp bounds on default among all applicants and on the profit of relaxing the cutoff? Do common heuristics (augmentation, parceling) fall outside those bounds?
- **Statistics contribution:** Outcomes missing not at random. Manski worst-case bounds tightened by monotonicity assumptions, plus a sensitivity parameter. This is weak overlap in its extreme form (zero overlap), so it relates to the starting causal topic without copying it.
- **Finance contribution:** Credit-expansion decisions and expected loss for segments the lender has never approved.
- **Data:** Lending Club accepted and rejected files. The official release appears discontinued; mirrors exist [ASM: provenance, licence and the rejected-file schema all need checking].
- **Laptop pilot:** Bounds on default by score bin; compare with an augmentation estimate. A few hours.
- **Closest methods:** Manski; Hand & Henley on reject inference; Heckman selection; policy learning under unobserved confounding (Kallus–Zhou) [LIT].
- **Fatal weaknesses:** The rejected file may share only a handful of features, so the bounds could be trivially wide. Integrity of the mirrored data is a risk.
- **Extension:** Choosing the cutoff with a minimax-regret criterion under the bounds.

### 3. Synthetic credit data: does inference survive, and at what membership-inference risk?
- **Question:** For a logistic probability-of-default (PD) model, do confidence intervals computed from synthetic data (synthpop CART, Gaussian copula, one differentially private synthesizer) reach nominal coverage of the real-data coefficients? How does coverage trade off against measured membership-inference (MIA) advantage?
- **Statistics contribution:** Make coverage under combining rules the main metric instead of generic "utility" scores, and include noise-aware DP inference.
- **Finance contribution:** Can an external validator or regulator recover the drivers of a PD model from shared synthetic data?
- **Data:** UCI Taiwan default (30k rows), German credit, Home Credit (check the Kaggle terms).
- **Laptop pilot:** 3 synthesizers × 5 releases × 200 replications, plus a distance-to-closest-record MIA. Hours of CPU.
- **Closest methods:** Raghunathan–Reiter–Rubin; synthpop; Räisä et al.; Anonymeter; the local DP-TLDM review [OBS].
- **Fatal weaknesses:** The area is crowded. The finance angle can become decorative. Public datasets are not representative of bank portfolios.
- **Extension:** Leakage concentrated among default-class (minority) records.

### 4. Feasible-manipulation robustness of credit scorecards (security link)
- **Question:** If applicants can make domain-valid changes to mutable features (utilization, inquiries) at assumed costs, what fraction of rejected applicants can cross the approval threshold? What does that do to portfolio expected loss if the lender does not adapt?
- **Statistics contribution:** Estimate the distribution of minimum cost to flip a decision, with bootstrap uncertainty. Separate gaming from genuine improvement using an explicit causal graph.
- **Finance contribution:** How robust approval policies are, and expected loss when applicants behave strategically.
- **Data:** Lending Club (the same source as the benchmark in the local CAPGD review [OBS]); Taiwan default.
- **Laptop pilot:** Logistic and GBM models, with a greedy or integer-program search for minimal flips.
- **Closest methods:** Strategic classification (Hardt et al.); performative prediction (Perdomo et al.); actionable recourse (Ustun et al.); CAPGD/CAA [LIT/OBS].
- **Fatal weaknesses:** There is no ground truth on real manipulation, and the costs are assumptions. Without real outcome data this risks becoming a thesis built only on simulation.
- **Extension:** Use the bunching from Direction 1 as observed evidence of manipulation.

### 5. Shape-constrained risk-neutral densities with honest uncertainty bands
- **Question:** Do shape-constrained nonparametric estimates of the risk-neutral density, with bootstrap bands, give left-tail probabilities that differ from SVI fits by more than estimation error?
- **Statistics contribution:** Constrained local-polynomial estimation of second derivatives, and inference at slow convergence rates. This builds on the local KDE and regression notes [OBS].
- **Finance contribution:** Pricing of tail risk and valuation of protective puts.
- **Data:** Historical option chains need OptionMetrics through WRDS (access unverified). The fallback is to collect daily snapshots going forward (check the provider's terms of service).
- **Laptop pilot:** One date's chain; resample within the bid-ask spread.
- **Closest methods:** Aït-Sahalia & Lo; Aït-Sahalia & Duarte; SVI [LIT].
- **Fatal weaknesses:** Data access; the literature is mature; bid-ask noise may dominate the signal.
- **Extension:** Does the width of the band predict realized tail events? (Statistical power would be low.)

## Ranking

1. **Direction 1.** Free loan-level data, a consequential pricing decision, and a statistical problem (identification under manipulation) that matches the RDD and sensitivity material in the local causal slide sets [OBS file names]. [HYP] Bunching at 80% LTV is large enough to bias naive RD estimates materially.
2. **Direction 2.** A clean identification question with a direct lending decision. Its viability depends on the rejected-file schema, which is the first thing to check.
3. **Direction 3.** The most feasible on a laptop and the most direct use of the security reading. Its contribution is weaker unless coverage is tied to a validation decision.

Directions 1 and 2 could share data-handling infrastructure while asking different questions. Treat that only as an option until both programs confirm their rules on reuse and self-plagiarism.

## Minimal knowledge-management system (proposal only, nothing created)

```
research/
  README.md            index: each direction's status, next action, kill criterion
  questions/Qnn-*.md   one file per direction; every claim tagged OBS/LIT/ASM/HYP
  literature/refs.bib  + one note per paper: claim, method, data, what it does NOT do
  decisions/YYYY-MM-DD-*.md   short dated decision log (what was chosen, why, what was rejected)
  pilots/Pnn-*/        README (data source, licence, SHA256, access date), script, raw output
  sources.md           map of local course material: path, licence/reuse flag; links only, no copied text
  brainstorming/       as now; one subfolder per session
```

**Rules:**
- Raw data stays in a gitignored `data/` folder, and the ignored finance folder stays ignored.
- Interpretation in a pilot's notes is written only after the code has run, and only from its actual output.
- Each question file states one falsifiable kill criterion.
- A weekly 30-minute review updates `README.md`.
- The existing paper reviews (which still carry source paths from another machine [OBS]) can be linked from `literature/`, not moved.

## Still unverified

- Novelty of every direction.
- Data terms and schemas: Freddie Mac, the Lending Club mirrors, WRDS access.
- The figures recalled from the literature.
- Whether the WQU integrity clauses apply outside WQU.
- Advisor and program fit, and whether one research program can support two submissions.