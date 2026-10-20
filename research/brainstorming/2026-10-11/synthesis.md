# Coordinator synthesis: what survives four rounds

Date: 2026-10-11. Four rounds per model, eight memos total. This synthesis incorporates the late evidence audit and takes precedence over the initial rankings. The useful outcome is a research discovery process and conditional shortlist, not a settled thesis title.

## The organizing idea

**When does available data justify a financial risk decision?**

The program connects statistical estimation, uncertainty, identification, and financial decision costs. A narrower branch is risk decisions whose horizon exceeds the observation horizon: loan outcomes have not matured, or daily market observations must support a longer holding-period estimate.

This theme can organize the knowledge repository. It is not a claim that all topics share one method, and it is not itself a novel contribution. NLP, cybersecurity, and every course do not need to appear in the thesis.

## The recommendation changed with evidence

| Earlier idea | Final assessment | Reason |
|---|---|---|
| Generic dependence-aware ES bootstrap | Established methodology | Existing bootstrap results already cover dependence under stated conditions |
| Overlapping holding-period ES / scaling versus direct estimation | Strong replication exercise; thesis contribution unresolved | Close existing work directly compares scaling, overlap, estimation uncertainty, and conservative risk reserves |
| Mortgage risk from immature cohorts | Conditional lead for contribution discovery | A consequential horizon/identification question, but data access, rare-event precision, and nearest literature remain open |
| Mortgage threshold RD | Deferred | Sorting, rounding, acquisition selection, and bundled treatment changes weaken identification; density tests and donut exclusions do not repair this automatically |
| Reject inference | Deferred behind provenance and identification gates | Rejected borrowers' outcomes under a specified new contract are unobserved; matching populations and usable features are unresolved |
| Synthetic financial-data inference | Reserve investigation | Reproducible and connected to privacy, but noise-aware synthetic inference is established and a finance-specific delta is needed |
| Sequential backtest restarts | Alternate reserve | Feasible known-truth simulations, but broad e-backtesting is already established |
| Option-implied crash risk | Deferred | Strong neighboring literature and historical quote-access/preparation requirements |

The decisive ES neighbors include [DNB's Why risk is so hard to measure](https://www.dnb.nl/publicaties/publicaties-onderzoek/working-paper-2016/494-why-risk-is-so-hard-to-measure/) and [Pitera–Schmidt–Stettner's scaling paper](https://arxiv.org/abs/2312.05655). Their official abstracts were opened. A [Gaspar overlap paper](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=6094327) is a particularly close search lead, but the fetch failed: its claims are not full-text verified. See literature-check.md for exact evidence depth.

Both models demoted ES as a default thesis commitment. Mortgage does not become novel simply because ES is crowded; its neighboring reserving/vintage literature has received less review.

## Two different kinds of work to pursue

### A. Contribution discovery: immature loan cohorts

Working question:

> When is a loan cohort mature enough to support a specified 12-month credit-risk decision, under explicit assumptions about its unobserved future outcomes?

Define the target as cumulative incidence of a precisely coded event, such as first serious delinquency within 12 months. Contractual prepayment competes with default; it is not merely missing data. With no observation support through 12 months, administrative censoring alone does not identify that risk.

Start with a matured cohort and artificially truncate its follow-up at 3, 6, and 9 months. Compare one established maturation approach with explicit identification/sensitivity envelopes. The pilot varies immaturity only. Any transport model must say whether it transports incidence or the competing default/prepayment hazards. Calibration on past cohorts is not a guarantee for future cohorts.

Candidate statistical contribution: a verified decision-specific result linking follow-up length, event information, and an uncertainty/identification envelope to whether a risk trigger can be resolved. This must be checked against vintage analysis, reserving, competing-risk methods, and existing sensitivity work.

Candidate financial contribution: evaluate under-reserving versus excess-reserving, or a defined exposure trigger. A fixed LGD/EAD scenario is illustrative; it is not a fitted monetary-loss model or accounting-compliance result.

First gates: permitted data access, interpretable event codes, sufficient event counts, a supported population/sampling argument, a distinction from nearest work, and advisor fit. Choose sample size from desired precision and event rates; a fixed loan count does not assure adequacy. Many loans also do not create many independent vintage observations.

### B. Replication and skill building: holding-period market risk

Reproduce a specific published ES overlap/scaling comparison after reading its methods. Use zero-mean iid Gaussian daily returns as a known-truth check; overlapping h-day returns create dependence even though daily returns are independent.

Distinguish marginal holding-period ES from tomorrow's conditional ES. Match the financial decision to the target: a through-cycle exposure budget can use marginal risk; daily dynamic allocation needs a different target/model. Report budget breach and foregone exposure separately before introducing a declared weighted decision loss.

This builds a reusable simulation harness and uncertainty discipline. It can reopen as a thesis candidate only if full-paper comparison identifies a consequential unanswered question. Adding GARCH, drift, heavy tails, or a new dataset does not automatically establish novelty.

## What the models still disagree on

Codex favors synthetic financial-validation inference as the reserve; Claude favors sequential monitoring. Neither reserve has cleared its contribution gate. Codex prefers isolating overlap in an initial ES experiment; Claude sees scaling-versus-direct as the more financial comparison. The final audit makes both comparisons replication tasks first.

There is no reason to force agreement or merge all mechanisms into one oversized thesis. Decide reserves after advisor expectations and data access become known.

## How to manage knowledge

Keep course folders and ignored source material in place. Add a small research layer as needed:

- Source registry: local path or URL/DOI, version/access date, source provenance, read depth, and exact claim supported.
- Candidate cards: question, estimand, assumptions, financial decision, nearest paper, proposed difference, data status, and next gate.
- Literature/contribution matrix: what each nearest paper actually answers and what remains open.
- Pilot specifications: fixed comparisons, sampling model, truth/benchmark, precision budget, metrics, and amendment history.
- Results and decision log: every planned comparison, uncertainty, limitations, and reasons for continuing or pivoting.

Keep **read depth** separate from **claim verification**. Useful read depths are inventoried, search-only, abstract-read, methods-read, and full-read. Claims can separately be source-supported, reproduced, assumption, hypothesis, or unresolved. Reading a full paper does not validate every claim; reproducing a simulation does not prove its theorem.

Create synthesis notes around a target and assumption, not summaries of every PDF. Each useful note should connect definition → assumptions → failure mode → verification → financial consequence. Local ignored books/slides remain local; reference them without copying source text into tracked notes.

Foundations: probability, statistical theory, computational statistics, nonparametric inference, regression assumptions, and stochastic processes. Direct additions for mortgage work: survival/competing risks, outcome coding, maturation and sensitivity analysis. Security/privacy is an optional reserve connection. Authored multivariate notes are classical fixed-dimensional iid material; high-dimensional extensions require additional preparation.

## Four-week discovery plan

| Week | Deliverable | Decision |
|---|---|---|
| 1 | Two candidate cards, nearest-paper matrix, data/requirements checklist | Is there an accessible, meaningful question with a plausible contribution? |
| 2 | Small replication plus access-gated mortgage scoping pilot | Are targets, code, event information, and precision credible? |
| 3 | Full comparison with nearest methods; one justified extension if warranted | Choose a primary direction or pivot for a documented reason |
| 4 | Proposal, preliminary evidence, limitations, and contribution matrix | Advisor reviews a concrete thesis scope |

The first 72 hours should produce the two cards, a nearest-paper reading list, exact access/schema questions, and precision estimates. Reading and small known-method scoping pilots can proceed together; a blanket ban on code until novelty is proved would unnecessarily block learning.

Do not choose a thesis because one method wins significantly. Set practical margins and enough precision to distinguish consequential differences, informative equivalence, and inconclusive results. Sampling uncertainty and Monte Carlo error are different. Preserve nulls and successful baselines. Stop for duplicated contribution, inaccessible data, unsupported identification, insufficient precision, or weak relevance—not merely an inconvenient result.

## Two degrees and unresolved facts

If permitted, a statistics submission could focus on identification/inference, while a financial-engineering submission evaluates a distinct financial decision. Write a contribution matrix specifying separate primary questions, analyses, figures, and assessed text, along with any proposed shared data/code. Program rules determine whether sharing is allowed; the current brainstorm establishes no permission.

The two facts most likely to change the shortlist are the statistics advisor's expected field/contribution depth and the financial program's final assessment format/data access. The source collection suggests preparation, not program requirements. The immediate deliverable is one coherent proposal with preliminary evidence, not two completed theses.
