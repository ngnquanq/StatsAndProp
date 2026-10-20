# Round 3 (Claude): convergence

I read `context.md`, both Codex memos, both Claude memos, `literature-check.md` and `session-manifest.md`. I did not open the JSON or prompt files, and I edited nothing.

Tags: **[OBS]** seen locally, **[SRC]** abstract checked by the coordinator, **[LIT]** recalled and unchecked, **[ASM]** assumption, **[HYP]** hypothesis. Nothing here is a claim of novelty.

## Broad theme

**Decision-relevant uncertainty when the data cover a shorter horizon than the decision needs.**
- In credit, outcomes are censored before the decision horizon.
- In market risk, the horizon is built by aggregating short-horizon data, which creates dependence and leaves few tail observations.

Both strands use the same skills but have different estimands, data and decisions. That is not evidence that two degree submissions are permitted.

## Pilots

**Pilot B: horizon ES, direct versus √h-scaled (run first, no access gate).**
- **Estimand:** marginal h-day ES at α = 0.975, explicitly not conditional ES.
- **Two separate arms:**
  1. iid Gaussian, where overlap is the only source of dependence. Scaling is exact here, so this arm only checks the code and the influence-function benchmark.
  2. One stationary volatility-clustering process, where scaling is biased and direct estimation is noisy [HYP].
- **Data:** French daily industry portfolios [SRC: public], used for illustration only.
- **Statistics contribution [HYP]:** a finite-sample reliability map of the bias–variance trade-off at regulatory window sizes.
- **Financial engineering contribution [HYP]:** the exposure rule w = min(w_max, B/U), scored against the oracle exposure on budget-breach and foregone-exposure terms, reported separately. This is Codex's round-2 loss.

**Pilot A: immature mortgage cohorts (higher ceiling, access-gated).**
- **Estimand:** the cohort's 12-month cumulative incidence of serious delinquency, with prepayment as a competing risk.
- **Mechanism:** truncate matured cohorts at 3, 6 and 9 months. Compare naive estimation, hazard transport, incidence transport and a sensitivity envelope.
- **Statistics contribution [HYP]:** partial identification with a transport-sensitivity parameter, checked against how far transport actually failed across past cohorts.
- **Financial engineering contribution [HYP]:** a provision decision under asymmetric loss with declared, illustrative LGD and EAD.
- **Closest prior work to beat:** loss reserving and IFRS 9/CECL vintage practice [LIT], not only competing-hazard papers.

**Reserve: anytime-valid backtest monitoring with refit restarts** (Codex #4).
- It runs on a laptop with known truth and extends Pilot B as model-risk monitoring. Its estimand (conditional exceedance) is kept separate from B's.
- Its only honest security link is false-alarm control in alerting.

## Disagreements with Codex

1. **Order.** Codex ranks ES first on merit. I rank A higher on ceiling but schedule B first only because it needs no data access.
2. **What B compares.** Codex keeps only the overlap mechanism. I think that alone is textbook and asymptotically covered by Sun–Cheng block-bootstrap theory [SRC + inference]. The comparison that could matter for a decision is direct versus scaled estimation. I keep Codex's "one mechanism per arm" rule.
3. **Sample size for A.** Codex suggests 5,000–10,000 loans. At default rates possibly below 1% [ASM], that gives only dozens of events. Size the sample by event count instead.
4. **What A transports.** "Transport hazards" must name its object: cause-specific hazard or cumulative incidence. The worst-case bounds are close to [0, 1], so all the content sits in the sensitivity parameter.
5. **Fallback.** Codex promotes synthetic-data inference. Noise-aware DP-synthetic inference already exists [SRC], so I prefer the monitoring reserve.

## Four-week discovery plan

Before any code runs, write a dated pre-registration file per pilot. It fixes the methods, metrics, scenario grid, Monte Carlo sizes and gates. Every method and scenario gets reported, whichever method wins or loses.

| Week | Work | Gate |
|---|---|---|
| 1 | Targeted collision searches; Clarity registration and terms; candidate cards; pre-registration | **Literature:** no-go if a located paper already answers the pre-registered question at comparable windows or vintages |
| 2 | Pilot B: Gaussian arm (code check), then the clustering arm at small scale (100 replications) | **Validity:** no-go if the Gaussian arm misses the analytic ES beyond Monte Carlo error |
| 3 | Pilot A on real data if access is granted; otherwise labeled simulation, which tests only the mechanics; scope the reserve | **Access:** no data by day 18, or terms forbid thesis use → A is suspended |
| 4 | Run all gates; one-page advisor memo (not manuscript prose) | **Informativeness** (below) |

**Informativeness gate:**
- **Go** if, across the full pre-declared grid, the decision-loss difference between methods exceeds twice its Monte Carlo standard error in at least the pre-declared share of scenarios.
- **No-go** if every method implies the same decision, or if noise dominates. For B that means tail sparsity swamps both effects; for A that means transport error is below sampling error.
- A clear null is logged as a result, not discarded.

## Minimal knowledge artifacts

- `research/README.md`: one status row per direction, with next action and gate.
- `research/candidates/*.md`: estimand, nearest paper, proposed difference from it, access status, kill criterion. Every claim tagged.
- `research/sources.csv` with columns: `id, title, url/doi or local path, version/date accessed, provenance (OBS/SRC/LIT), read depth, review status, reuse flag`.
  - **Review statuses:** `recalled-unchecked` → `abstract-checked` → `skimmed` → `read-full` → `claim-verified`. Only `claim-verified` may support a proposal sentence.
- `research/decisions/YYYY-MM-DD-*.md`: pre-registrations and gate outcomes.

**Handling local and ignored sources:**
- `99. For fun/financial-engineering/` stays ignored and in place. The registry stores its path and a one-line summary, never copied text.
- Raw provider data goes in a gitignored `data/` folder under the provider's terms.
- The syllabus integrity clause [OBS] is logged as an open question for the program, not interpreted.

## Course materials

- **Foundational:** probability and asymptotics; EDF and influence-function material in the nonparametric guide [OBS]; sandwich/HAC notes under autocorrelation [OBS]; bootstrap [OBS, iid only].
- **Directly useful:**
  - Pilot B: computational statistics and regression time-dependence notes.
  - Pilot A: the sensitivity-analysis slides (file names only seen), plus the introductory credit-risk lesson and syllabus Module 5 on LTV [OBS] as context.
  - Survival and competing-risk material was not seen in the notes reviewed. That is a gap to study.
- **Optional:** KDE and projection estimators, the fixed-dimension multivariate lecture, ML, NLP/OCR, LaLonde, options, and the ML-security reviews. The security reviews become relevant only if the reserve runs.

## First 72 hours (no code)

1. Submit Clarity registration and record the exact terms in `sources.csv`.
2. Run two collision searches:
   - "square-root-of-time ES scaling versus direct overlapping estimation, finite sample"
   - "IFRS 9/CECL immature vintages, competing-risk cumulative incidence"
3. Draft both candidate cards and the B pre-registration.
4. Send the advisor and program the two questions below, plus the reuse question.

## Two facts most likely to change the ranking

1. **What the advisor expects as a contribution, and in which field.**
   - If an original theorem is required, both pilots weaken and B's influence-function benchmark would need real theoretical depth.
   - If the advisor works in credit, A rises; if in market risk, B and the reserve rise.
2. **Which data access you can actually use for a thesis.** Clarity terms that allow thesis use keep A alive; refusal or delay suspends it. Institutional WRDS or OptionMetrics access would reopen the options directions, which both models dropped.

The rule on reusing work across two submissions is a hard gate on any shared program, not a ranking factor.