# Codex round 2 — cross-critique and repair

Date: 2026-10-11. Latest Codex, high effort. Read both round-1 memos, shared context, and literature-check.md. No experiments or changes outside this memo. Claims below are methodological reasoning or explicit hypotheses; novelty remains unverified.

## Critique of Claude's strongest directions

**Mortgage threshold RD:** This has a compelling finance question, but the proposed “one-day histogram plus donut RD” is a diagnostic, not an identification strategy. LTV is affected by down-payment choice, appraisal, underwriting, rounding, and acquisition selection. A discontinuity among agency-acquired loans need not represent the population eligible for the policy. Multiple policies changing at 80% identifies at most a treatment bundle, and only if continuity/exclusion assumptions hold. Insurance may primarily change lender loss rather than borrower delinquency, so the chosen outcome may also miss the economic mechanism.

A density test failing to reject manipulation does not establish continuity of potential outcomes. Detecting bunching does not prove strategic manipulation rather than heaping. Removing a donut neither recovers the missing local counterfactual nor guarantees smooth extrapolation across the excluded region. [Gerard–Rokkanen–Rothe](https://www.nber.org/papers/w22892) establishes manipulation bounds under a model, not permission to treat arbitrary sorting as solved. Before ranking this first, require a documented cutoff/treatment, observable treatment take-up, running-variable precision, acquisition-selection argument, and explicit assumptions supporting a particular bound. Retain as a later identification audit, not the immediate causal flagship.

**Reject inference:** Its question is sharper than an ordinary default-prediction contest, but access and target are not yet adequate. An archived accepted-loan table plus a reject mirror does not establish matching applicant populations, comparable scores, time coverage, or authorized use. Accepted records may be funded loans rather than all approved applications. Rejected borrowers have no observed outcome under newly granted credit; “default” is a potential outcome conditional on contract terms, not automatically an existing missing column. Worst-case bounds need an explicit lending intervention and consistent target. A heuristic cannot be called impossible merely because it lies outside bounds whose assumptions or populations differ. Move this behind an access/schema gate; synthetic masking of accepted outcomes can test mechanics, but cannot validate real reject-inference assumptions.

**Synthetic credit inference:** This is more reproducible than either access-dependent idea, but its coverage target needs repair. An interval containing the coefficient fitted to one original public dataset is not population coverage. Use a planted population coefficient or probability; vary original samples, fitted synthesizer/release randomness, and synthetic sampling. More synthetic rows cannot erase uncertainty in the original sample. [Räisä et al.](https://arxiv.org/abs/2205.14485) already explicitly shows naive DP-synthetic inference becoming too narrow and supplies noise-aware generation with multiple-imputation analysis. Combining rules must match fully/partially synthetic release design and congeniality assumptions. Add a genuine finance decision before expanding synthesizers. Five releases of one dataset do not substitute for independent outer samples. Distance-based MIA is an attack diagnostic, not a DP guarantee or a complete privacy assessment; defer it rather than bundle two failure mechanisms.

**Strategic manipulation:** A causal graph states assumptions but cannot identify whether changing utilization improves true repayment capacity. Report-only corruption can keep outcomes fixed; genuine financial behavior changes cannot. Bunching from a mortgage threshold cannot calibrate manipulation costs for an unrelated credit dataset. Our two robustness proposals should be split into these targets, not merged.

**Options:** Perturbing quotes uniformly inside spreads does not define a repeated-sampling law. Risk-neutral tails cannot directly predict physical crash frequencies without a pricing-kernel relationship. The recent crash-frontier work cited in my first memo further reduces the case for immediate commitment.

## Revisions to my shortlist

I keep ES overlap first, but narrow it to aggregation-induced dependence only. No GARCH, contamination, drift, portfolio optimization, or sequential alarms in the first pilot. Current ES bootstrap results are established; any contribution must be a verified holding-period-specific benchmark or a decision-relevant reliability result.

Mortgage maturity remains second conditionally on sample access. It studies observability, not a causal insurance effect, and it avoids pretending future-horizon risk is identified without follow-up support. Synthetic inference rises above input-integrity attacks as the fallback because it permits known-truth simulation. Security corruption falls: treating observed outcome labels as unchanged is appropriate only for declared report corruption, not actual borrower improvement. Genuine market crises likewise belong in the target loss distribution; they are not “contamination” to remove for better-looking ES.

## Two complementary pilot plans

### A. Overlap creates false precision

**Single mechanism:** Daily returns are iid Gaussian; only overlapping h-day aggregation creates dependence. Fix alpha=0.975 and h=1,5,20. Population marginal ES is analytically known.

**Comparison:** iid interval, an established horizon-preserving dependence-aware interval, and nonoverlapping estimation. Derive/evaluate the finite-lag ES influence-function covariance benchmark. Preserve dependence on the daily time scale or justify aggregation-level block choices.

**Financial decision:** With declared capital budget B, choose exposure w=min(w_max,B/U), where U is a positive ES upper bound. Measure scenario loss a(w*ES-B)_+ + b(w_oracle-w)_+, with w_oracle=min(w_max,B/ES). First term measures budget breach; second measures foregone exposure. Declare a/b scenarios and report terms separately.

**Scale/gate:** Initially 100 outer replications and 199 bootstrap draws, then increase only if promising; 100 replications cannot distinguish tiny coverage differences. Stop if the nearest literature already answers the holding-period question or no decision benefit survives the width/exposure tradeoff.

### B. Immature outcomes mimic cohort improvement

**Single mechanism:** Artificially truncate one fully matured mortgage cohort at 3/6/9 months; do not introduce cohort drift, hidden confounding, or corrupted records.

**Target/comparison:** A precisely coded 12-month serious-delinquency incidence, with contractual prepayment handled as competing. Compare observed-to-date incidence, an established maturation forecast, and explicit identified/sensitivity envelopes. Finite-cohort bounds should contain later-observed finite-cohort incidence by construction; that is not evidence of population confidence coverage.

**Financial decision:** Translate incidence into a declared constant-loss scenario and choose reserve R. Measure realized cohort cost a(L_realized-R)_+ + b(R-L_realized)_+, reporting under-reserve and excess-reserve components separately. This is a scenario evaluation, not estimated mortgage LGD or accounting compliance.

**Access/gate:** Obtain permitted Freddie Mac sample access before coding. Start with 5,000–10,000 loans. If access fails, use a labeled simulation for mechanics only. Stop if horizon envelopes remain decision-useless or all benefits merely reproduce a standard maturation adjustment. Public-data inference still needs a population sampling argument.

These pilots complement dependence-induced uncertainty with incomplete-outcome identification; neither combines failure mechanisms to manufacture novelty.

## Opposing case and recommendation changes

The strongest objection to ES is that a Gaussian overlap calculation plus bootstrap comparisons may be educational replication, and unconditional ES may poorly match a desk's time-varying capital decision. Synthetic inference could offer better advisor fit and reproducibility; mortgage RD could offer greater economic originality if its policy design is genuinely identified.

I would switch from ES if full neighboring papers already contain the same horizon benchmark/decision study, the advisor rejects empirical-methodological novelty, or capital decisions remain unchanged. Mortgage work rises with confirmed data and an informative maturity/transport contribution. RD rises only with defensible treatment and selection identification. Synthetic inference rises with a narrow finance-validation target and a demonstrable delta beyond existing noise-aware inference. Agreement across models is not evidence that these gates have passed.
