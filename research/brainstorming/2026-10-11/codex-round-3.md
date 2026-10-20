# Codex round 3 — conditional convergence

Date: 2026-10-11. Latest Codex, high effort. Read both round-2 memos and shared context. Advisory plan only; no experiments. Novelty, advisor fit, degree assessment formats, and permission for shared work remain unresolved.

## Preferred theme and disagreement

Prefer **honest uncertainty for financial decisions made at a longer horizon than the observations support**. This connects two candidates without claiming a new universal method: holding-period market-risk inference and immature mortgage-cohort risk. The connection is useful for organizing learning; it is not itself a research contribution.

I retain ES as the first discovery candidate because data and known-truth benchmarks are accessible. Claude prefers mortgage maturity; its stronger operational story is real, but access, outcome definitions, rare events, and transport assumptions add uncertainty before we can even evaluate contribution. Confirmed access plus a supported methodological delta could reverse my ranking.

Claude's square-root-of-h scaling suggestion is a useful comparator, not sufficient novelty. Under zero-mean iid Gaussian daily returns, h-day marginal ES scales exactly by sqrt(h). This lets the initial benchmark compare efficient valid scaling with noisy direct estimation while isolating overlap. Introducing GARCH to make scaling fail would add another mechanism and another established literature. Defer it until the first pilot and nearest papers justify expansion; make no regulatory claim about scaling.

I also reject outcome-based kill rules such as “transport error smaller than sampling error” or “baselines work.” Reliable baselines and null differences can establish useful applicability boundaries. Stop when identification, precision, relevance, or contribution cannot meet the proposal's requirements—not because results fail to favor a new method.

## Two narrow pilots

**A. Dependence created by holding-period aggregation.** Target marginal alpha=0.975 ES of h-day losses under zero-mean iid Gaussian daily returns, initially h=1,5,20. These are losses for a fixed holding-period position, not continuously rebalanced trading or tomorrow's conditional ES.

Compare direct overlapping estimation with iid uncertainty, an established dependence-aware interval, nonoverlapping estimation, and sqrt(h)-scaled one-day estimation. Calculate the finite-lag influence-function variance benchmark. Only aggregation-induced dependence is varied; no contamination, regime drift, volatility clustering, or estimator tuning against favorable results.

Decision: allocate a constant through-cycle exposure w against a fixed marginal ES budget B using a positive upper confidence limit U, w=min(w_max,B/U). Report budget breach (w*ES-B)_+ and exposure foregone (w_oracle-w)_+ separately; a declared weighted sum gives scenario decision loss. This matches the marginal target. It does not establish daily capital adequacy. Simulations supply known ES; a French daily portfolio series supplies only an empirical illustration.

Start small, then increase outer replications according to Monte Carlo precision, not whether significance appears. At estimated 95% coverage, 100 replications have about 2.2 percentage points of Monte Carlo standard error. Bootstrap and simulation error both need documentation.

**B. Outcomes missing because a cohort is young.** Target precisely coded 12-month serious-delinquency cumulative incidence with contractual prepayment as a competing event. Artificially truncate a matured cohort at 3/6/9 months. The sole failure mechanism is outcome immaturity; do not simultaneously claim identification of prepayment-regime shifts.

Compare observed-to-date incidence, one established maturity adjustment, and identified/sensitivity envelopes. Any transport baseline must state whether it transports cumulative incidence or both default/prepayment hazards. Stable default hazard alone does not imply stable incidence when competing hazards differ. With no horizon support, independent administrative censoring does not identify 12-month risk. History-based sensitivity ranges remain assumptions about future transport, not validated coverage guarantees.

Decision: translate incidence into a declared fixed-loss scenario, choose reserve R, and report under-reserve (L_realized-R)_+ and excess-reserve (R-L_realized)_+ against matured finite-cohort outcomes. Combine them only with declared weights. This is neither validated mortgage LGD nor an accounting-compliance study. Bounds containing the finite cohort's eventual outcome by construction do not prove population confidence coverage.

Access requires a permitted Freddie Mac sample and verified codebook. Choose size from event counts and required precision, not a fixed 10,000-loan promise. Illustratively, 10,000 loans yield 50 events at incidence 0.5%, but only 10 at 0.1%; subgroup counts are smaller. Decide acceptable absolute/relative uncertainty in advance, using rare-event intervals and a sampling argument. Large loan counts do not create independent vintage replications.

## Reserve and conditional degree contributions

Reserve **synthetic-data inference for a specified financial validation decision**, using a planted population risk target and uncertainty over original sampling plus release generation. Existing noise-aware inference is a direct novelty blocker; postpone privacy attacks and multiple synthesizer comparisons until a delta is identified. Reject inference remains behind a harder provenance/schema gate.

If programs permit shared resources, the statistics submission could study estimand-specific uncertainty, identification, or a verified inference extension; the finance submission could separately evaluate a capital-allocation or cohort-risk decision under explicit loss assumptions. Require distinct primary questions, analyses, claims, figures, and assessed text. Shared datasets/code/background must be disclosed and permitted. Different titles alone do not resolve reuse restrictions.

## Four-week discovery plan

- **Week 1:** Fix estimands and decisions; obtain advisor expectations; review nearest full papers on ES dependence/scaling and mortgage vintage/reserving methods. Resolve data access/codebooks. Produce a contribution matrix with one proposed delta per candidate.
- **Week 2:** Implement only authorized small pilots, with fixed comparisons, simulation truth, event/precision budgets, and separate statistical versus financial metrics.
- **Week 3:** Diagnose discrepancies, reproduce null or positive results, examine computational/precision limits, and select one primary candidate. Add only one justified extension.
- **Week 4:** Assemble a proposal outline, evidence figures, limitations, resource plan, and fallback. Do not imply two completed theses or institutional permission.

Go/no-go evidence: usable authorized data; identifiable or honestly bounded target; precision sufficient for the declared question; a consequential decision; verified distinction from nearest work; advisor support. Publish all prespecified comparisons internally, including successful standard methods and inconclusive cells. Amendments need dated reasons. An informative negative pilot may support a proposal; a duplicated or unidentifiable question may require pivoting.

## First 72 hours and minimal artifacts

First 24 hours: write target/decision cards and a concise advisor/program question list. Next 24: verify access and schemas; read full nearest papers where abstracts leave essential assumptions unclear. Final 24: freeze two pilot specifications and estimate precision/computation needs. If access remains unresolved, keep mortgage empirical work conditional and prioritize the ES benchmark.

Add only research README, candidate matrix, source registry, assumptions/estimands note, pilot specifications, and decision log. Record source version/date, read depth (abstract/full methods/reproduced), verification status (verified claim/assumption/hypothesis/unverified novelty), and next evidence needed. Keep original course files and ignored finance material in place; track future code/configuration and aggregate outputs, with raw data governed by provider terms.
