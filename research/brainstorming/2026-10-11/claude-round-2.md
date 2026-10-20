# Round 2: cross-critique (Claude)

**What I read:** `context.md`, `claude-round-1.md`, `codex-round-1.md` and `literature-check.md`. I did not open `claude-round-2.json` or any prompt files. Nothing was saved. Tags: [OBS] seen locally, [LIT] from memory and unchecked, [SRC] from the coordinator's check, [ASM] assumption, [HYP] testable hypothesis. No literature gap below is verified.

## Critique of Codex's strongest proposals

**Codex #2, mortgage outcomes that haven't matured yet. I think it's the strongest idea in either round, but it needs repair.**
- **Possible estimand confusion.** The decision-relevant target is the cohort's 12-month **cumulative incidence** of default, with prepayment as a competing risk. It is a physical probability, averaged over the cohort. "Transporting older cohorts' hazards" is ambiguous:
  - A stable cause-specific default hazard does not give a stable cumulative incidence when prepayment changes. After 2022, low refinancing incentive means fewer loans exit by prepayment, so more stay exposed to default [HYP].
  - So the proposal must say which object it transports. That choice is the core of the question, not a detail.
- **The basic bounds carry almost no information.** At 6 months nearly every loan is still unresolved, so [observed defaults, observed + unresolved] is close to [0, 1]. All the content comes from the transport sensitivity parameter. The thesis has to own that and calibrate the parameter from how much transport failed across matured cohorts.
- **Hidden data requirements:**
  - Clarity registration and terms [SRC: access unresolved].
  - Mapping zero-balance and disposition codes to default versus prepayment.
  - How 2020 forbearance was coded.
  - **Event counts.** In good vintages the 12-month serious-delinquency rate may be well under 1% [ASM]. Codex's 5–10k loans could then produce only dozens of events, so the pilot probably needs more than 100k loans.
- **Novelty blocker:** actuarial loss reserving (chain-ladder, IBNR) and IFRS 9/CECL vintage analysis already address "outcomes not yet observed" [LIT]. The proposed contribution must be stated against that literature, not only against competing-hazard papers.
- **Is the finance substantive?** Yes, if the decision is a provision or an exposure limit. One caveat: CECL uses lifetime loss with macro forecasts [LIT], so a 12-month horizon needs justification, for example as an early-warning or risk-appetite trigger.

**Codex #1, ES with overlapping holding periods. The statistics are sound, but the novelty is thin.**
- Overlapping h-day sums of a mixing process are still mixing. The block-bootstrap validity in Sun–Cheng therefore probably already covers this asymptotically [SRC + my inference]. What remains is finite-sample guidance. The Gaussian overlap benchmark is a textbook calculation.
- **Estimand risk.** Codex correctly targets marginal ES. But "sizing exposure against an ES budget" is usually a decision about tomorrow, which calls for conditional ES. The marginal target is only justified for a long-run, through-the-cycle allocation, and the proposal must say so.
- **Repair: change the comparison.** Compare direct overlapping h-day ES with √h-scaled 1-day ES, the regulatory-style scaling [LIT, e.g. the time-scaling-of-risk literature; check it].
  - Scaling is biased under volatility clustering and heavy tails.
  - Direct estimation has high variance: a 250-day window at α = 0.975 leaves about 6 tail points [arithmetic].
  - That bias–variance trade-off attaches to a real decision. Tail sparsity, not overlap, may be what dominates [HYP].

**Codex #3, corrupted credit-model inputs. This is the security bridge, with limits.**
- In UCI Taiwan, the repayment-history fields are recorded by the bank. So the threat is pipeline or insider corruption, not applicants gaming the model. Codex says this.
- Everything is a **simulated intervention** with outcomes held fixed. It is a valid stress test, but it identifies no real causal effect and observes no real attacker. The finance side reduces to an assumed cost table. Keep it as a possible extension, not a core candidate.

**Codex #4 (e-backtest restarts):** clean, but small. Its target is conditional exceedance, which is a different object from #1's marginal ES; don't merge the two. **Codex #5:** the novelty blocker it cites [SRC via Codex] also hits my Direction 5. Risk-neutral crash probabilities are pricing objects, so neither candidate gets to say anything about physical crash frequency. Drop both.

## Revising my round-1 ranking

- **D1, RD at the 80% LTV threshold: demoted.** The coordinator is right that a density test or donut exclusion does not restore identification. Bunching is the phenomenon itself, not a nuisance. Who chooses to borrow at 80% LTV is selection, and mortgage insurance, price and lender overlays all change at once. At best the estimand is a local effect of a bundle on a manipulated population. Keep it only as a descriptive bunching appendix if the Freddie Mac data is obtained anyway.
- **D2, reject inference: kept as a conditional third choice.** As I recall, the Lending Club reject file has only a few fields [LIT]. With zero outcomes among rejects, the bounds are [0, 1] unless monotonicity assumptions do all the work. Check the schema first. The provenance of the mirrors is a real risk.
- **D3, synthetic-data coverage: dropped.** Noise-aware DP inference exists [SRC]. My target was also wrong: coverage needs a simulation or population truth, not one fitted coefficient [SRC critique].
- **D4: folded into Codex #3.** **D5: dropped.**

**Revised ranking:** (1) Codex #2 repaired; (2) Codex #1 reframed as scaling versus direct estimation; (3) D2 if the schema allows, otherwise Codex #3.

## Two complementary pilots

Both are horizon-mismatch problems: data observed over a shorter horizon than the decision needs. One is credit with censoring, the other market risk with dependence. They share skills but have different estimands, data and decisions. That complementarity is **not** evidence that two degree submissions would be allowed.

**Pilot A: immature mortgage cohorts.**
- **Estimand:** the cohort's 12-month cumulative incidence of default, with prepayment as a competing risk (a physical probability).
- **Failure mechanism:** prepayment-regime shift. A default hazard transported from older cohorts gives the wrong cumulative incidence when prepayment rates differ.
- **Decision loss:**
  - Take matured cohorts and artificially truncate them at 3, 6 and 9 months.
  - Set a provision from each method's estimate times a fixed, declared LGD and EAD (illustrative, not validated).
  - Score it against the realized 12-month outcome with an asymmetric loss: under-provisioning costs k times as much as over-provisioning.
  - Compare naive Kaplan–Meier style estimation, hazard transport, incidence transport, and the sensitivity envelope.
- **Kill criterion:** cross-cohort transport error is either smaller than sampling error, or so large that every envelope implies the same decision.

**Pilot B: horizon ES (French industry portfolios plus simulation).**
- **Estimand:** marginal h-day ES at α = 0.975 of a stationary process, explicitly not conditional ES.
- **Failure mechanism:** under GARCH-type clustering, √h scaling is biased while direct overlapping estimation is very noisy.
- **Decision loss:** with known truth in simulation, measure capital shortfall (and excess capital at a declared cost of capital) when a budget is set from each estimator or its upper confidence limit.
- **Kill criterion:** in realistic windows, tail sparsity swamps both effects. Then neither estimator changes the decision, and the topic reduces to "use more data."

**Security bridge:** for A and B, it's not useful and I wouldn't force it. One honest link exists. Anytime-valid sequential monitoring (Codex #4) is the same problem as controlling false alarms in security operations alerting. It could become a later extension of Pilot B as model-risk monitoring, with its own conditional-coverage estimand.

## Opposing view to my favorite (Pilot A)

- "This is chain-ladder with competing risks wearing a statistics coat."
- Banks already handle immature vintages with roll-rate and vintage curves plus management overlays.
- The only new object is a sensitivity parameter that nobody can estimate. Calibrating it from past cohorts assumes the past range of transport failure bounds the future, which is the same transport assumption one level up.
- The data may not arrive in time.
- Events are rare, so sampling noise may dominate.

**Evidence that would change my recommendation:**
1. Clarity access isn't obtained within about two weeks, or the terms forbid the intended use. B moves to first.
2. A targeted search finds IFRS 9/CECL work that already calibrates transport sensitivity on immature vintages with competing risks.
3. The pilot hits the kill criterion above.
4. An advisor values market-risk methodology more.

Conversely, if a quick search shows that horizon scaling versus direct ES estimation has already been settled at regulatory window sizes, B drops, and D2 or Codex #3 becomes the second pilot.