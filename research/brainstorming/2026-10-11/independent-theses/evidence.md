# Coordinator source checks and questions

Checked 2026-10-11. This is a bounded literature screen, not exhaustive novelty verification. Sources opened by coordinator unless explicitly labeled agent-only.

| Source | Read depth | Supports / limits |
|---|---|---|
| WQU curriculum https://www.wqu.edu/programs/mscfe | Course descriptions | Map FE candidates to econometrics, stochastic modeling, pricing, portfolio/risk; capstone is 690 or 692, user's assignment unknown |
| WQU catalog https://www.wqu.edu/documents/wqu-catalog.pdf | Relevant capstone sections, current amendment header | 690 research/practical tracks have code/report/presentation and group requirements; no solo-thesis assumption |
| Amazon Access Samples https://archive.ics.uci.edu/dataset/216/amazon | Dataset page and schema | Anonymized entitlement snapshot and change history; not the Kaggle approval challenge. Actual grants/removals are not valid/invalid access truth. Schemas don't establish timestamp consistency or statistical independence |
| FIRST EPSS https://www.first.org/epss/how-it-works.html | Methodology sections | PU learning is established in EPSS; score predicts exploitation in a 30-day horizon. KEV catalog confirmation/date is not true exploitation label/date |
| RCPS https://arxiv.org/abs/2101.02703 | Abstract | Risk-controlling prediction sets already control risk with high probability; basic finite-family confidence certification is not new |
| Fed GSW https://www.federalreserve.gov/data/nominal-yield-curve.htm | Dataset description | Fitted yield curves, revised data; not raw executable bond prices. Quote/revision/vintage assumptions need care |

## Coordinator challenges for the next rounds

1. A Hoeffding bound plus finite union bound, total-variation sensitivity correction, or monotone price bracket alone is a mathematical benchmark, not verified original theory. Precisely state what master's-level contribution remains: proof scope, synthesis, sharpness or a meaningful boundary result. Do not imply novelty without nearest-paper comparison.
2. For IAM, distinguish user clusters from higher-level dependence among colleagues/resources/managers. Do not treat a public corporate census as an iid population merely because train/test split is by user. Certify a clearly specified risk and population under explicit sampling assumptions; resource mismatch is not actual violation or breach probability.
3. Policy candidates must be frozen before independent calibration/audit. Reusing audit data to search policies invalidates a naive fixed-family claim unless explicitly covered. Rare-role losses, averaging and audit-budget allocation are substantive choices.
4. Vulnerability catalogs are positive reports, not complete ground truth; EPSS's horizon differs from ever-exploited-by-date prevalence. Unidentified reporting-rate bounds cannot be learned from the same catalog without assumptions or external data.
5. Mathematical preparation is classical probability/statistics and fixed-dimension multivariate inference; don't silently require advanced dependence, semiparametric or stochastic-calculus results without a learning plan.
6. FE must have a decision and economically meaningful outcome. Comparing generic models on RMSE/AUC alone is inadequate. Financial costs on constructed portfolios or hypothetical bonds must be labeled assumptions; public illustrative datasets don't establish executable returns.
7. Keep two theses distinct in primary claims, targets, datasets, figures and manuscripts. Skills can transfer; don't force the same theorem to appear as a new contribution twice.
8. Null results and successful baselines are retained. Contribution gates concern worthwhile questions, identifiable targets and adequate precision, not a requirement to produce a winning new algorithm.

## Agent-only source findings from Codex round 1

Codex inspected selected sections of Unicorn policy mining, Elkan–Noto PU learning, CRC, Howard time-uniform inference, Diebold–Li, Fukasawa hedging, and LANL data documentation. Their URLs/read claims are in codex-round-1.md. Coordinator verification pending for the final shortlisted nearest neighbors. No dataset was downloaded or experiment run in this session.

## Further nearest-source checks before round 2

- https://arxiv.org/abs/1709.06296 — *Large-Scale Portfolio Allocation Under Transaction Costs and Model Uncertainty*, abstract opened: explicitly connects turnover penalization to covariance shrinkage and parameter uncertainty. Generic F1 covariance/shrinkage/turnover comparison has a close established neighbor.
- https://arxiv.org/abs/1910.11840 — *Sparsity and Stability for Minimum-Variance Portfolios*, abstract opened: combines covariance choices, sparse allocation and turnover constraints. An added turnover measure alone is not a contribution.
- https://www3.cs.stonybrook.edu/~stoller/policy-mining/ — author bibliography opened: lists policy mining under incomplete/noisy/unknown values. Further full-paper comparison needed; don't claim incomplete/noisy IAM mining is new.

Alternative IAM sampling argument to evaluate: design-based auditing of a fixed workforce can avoid an iid-user superpopulation assumption. However, mismatch to recorded entitlements is automatically computable and is not a costly expert review of entitlement legitimacy. State why sampling/assurance has operational meaning and what is actually being certified. Simulated genuine policy labels can establish mathematical behavior, not prove real bank security benefit.

Require differentiation between a valid, bounded master's synthesis/analysis and original publishable methodology. If the intended theory is only a union bound or monotone valuation proposition, state that openly and offer a narrowly justified deeper result; don't rename known mathematics as novelty.

## Critical corrections to Claude round 1

- KEV `dateAdded` in the next 30 days is NOT sufficient to establish exploitation inside that next-30-day prediction window: catalog addition can report an earlier event. Therefore Y*=future catalog addition does not automatically satisfy Y*<=Y for true future exploitation. Claude's lower-bound calibration theorem is invalid with that proxy. Change target to by-date confirmed/ever exploited, bound reporting delay under declared assumptions, or drop real 30-day calibration claims. Official CISA catalog fetch failed; Codex is checking primary metadata independently.
- ALPHA https://arxiv.org/abs/2201.02707 already accommodates replacement/no replacement, stratification, adaptive sampling and weighted/batched audits. Risk-limiting Financial Audits via Weighted Sampling without Replacement https://arxiv.org/abs/2305.06884 is an especially close financial-audit neighbor. Coordinator opened abstracts; proposed IAM martingale sampling is not new by application alone.
- New neighboring lead https://arxiv.org/abs/2604.06116 *Sequential Audit Sampling with Statistical Guarantees* (2026) must be compared before naming a sequential audit extension novel.
- Distinguish ever-crossing probability, average run length, fleet daily alarm count and false-discovery rate. One guarantee does not imply the others. Seasonal stratification doesn't by itself justify exchangeability or conditional validity.
- Public option-strategy indices are constructed strategies with licensing/history constraints; don't treat index returns as a self-financing executable strategy without specifying frictions and instruments.
# Coordinator checks before Round 3

- CISA's [official schema](https://github.com/cisagov/kev-data/blob/develop/known_exploited_vulnerabilities_schema.json), opened by coordinator, explicitly defines dateAdded as entry into the catalog. Near-publication anchoring does not establish exploitation during a future 30-day window. Claude R2's assumption A is unsupported; no real-data EPSS calibration conclusion is permitted from these labels.
- FIRST's [June 2026 update announcement](https://www.first.org/newsroom/releases/202606-036), published July 15 2026, describes EPSS v5 and added VulnCheck KEV data. Earlier remembered v3/v4 timelines are insufficient for current research design. [EPSS homepage](https://www.first.org/epss/) links the current data page; the old /data_stats URL returned 404. Actual historical downloads/terms are not validated in this session.
- [Fukasawa 2012](https://arxiv.org/abs/1204.0637), abstract opened by coordinator, already studies sharp asymptotic discretization bounds and efficient cost-sensitive hedging schemes. An adaptive-versus-fixed hedge comparison must be framed as replication/stress analysis, not a new principle.
- [Shekhar et al. 2023](https://arxiv.org/abs/2305.06884), abstract opened by coordinator and Sections 3–4/theorems read by Codex, already covers arbitrary weighted WoR sampling with prediction-assisted audits. Reviewer-noise sensitivity may be a bounded specialization but is not verified new. Exact sensitivity assumptions and replacement/WoR distinctions must be explicit.
- Main selection need not maximize publication novelty: a master's project can have value through substantial independently reconstructed proofs, an honest application, reproducible boundary analysis and a consequential decision. Advisor acceptance of this level is unknown; one-line inequalities alone are insufficient.

## New leads and Round 3 corrections for final audit

- Primary publisher search text exposes extremely close FE work: [Mantilla-Garcia et al. 2022, Improving Interest Rate Risk Hedging Strategies through Regularization](https://doi.org/10.1080/0015198X.2022.2095193) and [Quaedvlieg–Schotman, Hedging Long-Term Liabilities](https://doi.org/10.1093/jjfinec/nbaa027). Publisher full-page opens failed (403/500); institutional author PDF identified at https://repub.eur.nl/pub/131883/RePub-131883-OA.pdf . Treat as mandatory nearest-full-text comparisons, not proof a new gap exists. Regularized factor hedging itself is established; FE can proceed as controlled replication plus curve-construction/stress sensitivity if accepted.
- [Huber-Robust Confidence Sequences](https://arxiv.org/abs/2301.09573), coordinator opened abstract: robust sequential inference under contamination already exists. Does not establish identity with conditional reviewer sensitivity, but must enter noise-method comparison.
- Claude R3: average *conditional* sensitivity over all true-positive grants suffices for importance-weighted expectation; per-grant conditional lower bound is a stronger sufficient assumption, not logically necessary. A historical aggregate average does not automatically provide that condition.
- Claude R3 planted-item Clopper–Pearson claim requires actual binomial/iid or suitably justified assumptions; exchangeability alone allows dependence and is not sufficient. Moreover planted-to-real difficulty transfer and conditional reviewer stability are unverified. Do NOT make that an empirical route to learning s from Amazon records. Keep seeding optional controlled simulation only.
- Expected stopping analysis requires a positive conditional log drift (or a proved sufficient alternative), not merely theta<tau. Conservative s/false positives may yield no certification even under theta<tau. Bounded-budget inconclusive cases are legitimate outcomes.
- A misspecified arm need not demonstrably inflate error; it can fail conservatively. Show what happens, not require a positive result. A Monte Carlo frequency within two SE is not a proof/acceptance certificate, and across many cells requires multiplicity-aware diagnostics.
- Claude R3 backup time-to-KEV incidence must define the FULL published CVE denominator, exposure windows, launch batch, pre-publication exploitation and administrative censoring. Conditioning on eventually-listed CVEs cannot identify the exploited share of all CVEs. Thin-theory backup is not automatically suitable if advisor requires real outcomes.
- FE alternative-curve comparison is a useful scoped sensitivity, not validated novelty. Par yields are not zero curves; conversion assumptions/data provenance are necessary. A six-parameter GSW fit does not logically imply an almost-perfect three-factor hedge. Do not assume solo 690 allowed; actual WQU group rules govern.

- Coordinator subsequently opened the institutional PDF of Quaedvlieg–Schotman (34 pages) and read abstract/introduction and relevant hedge construction discussion. It explicitly addresses loading estimation error, changing factors and bias/variance trade-offs in long-liability hedges. FE must be presented as replication and a scoped attribution/sensitivity application; these themes are not a newly discovered gap. Its euro-swap/long-liability setup differs from the planned hypothetical Treasury book, but changing dataset alone is not method novelty.

