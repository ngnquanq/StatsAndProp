# Codex round 1 — independent exploration

Date: 2026-10-11. Latest Codex, high effort. Advisory notes only. Novelty and permission for shared degree work remain unverified.

## Local evidence and assumptions

The authored EDF/KDE study guide supports plug-in inference, pointwise versus simultaneous uncertainty, and derivative estimation. The bootstrap implementation resamples individual observations; it does not establish validity for dependent returns. Regression notes cover autocorrelation diagnostics. The LaLonde demonstration supports introductory causal-method familiarity. The multivariate lecture explicitly restricts itself to fixed dimension and iid observations. Tabular-security reviews supply familiarity with immutability and relational constraints, but their paper-specific judgments require original-source checking.

Assume laptop-scale Python/R computation and that an advisor may accept a carefully justified methodological or empirical contribution. Neither an original-theorem requirement nor the financial-engineering assessment format is established.

## Five questions

### 1. Holding-period overlap in Expected Shortfall uncertainty

**Question:** How does estimating 5/20-day marginal ES from overlapping returns distort confidence intervals, and can horizon-aware inference improve coverage without discarding most observations?

**Statistical contribution hypothesis:** Derive an overlap benchmark for iid Gaussian daily returns. Standardized h-day sums have lag-k correlation (h-k)/h for k<h. With ES influence function psi(x)=q+(x-q)_+/(1-alpha)-ES, variance includes Var(psi)+2 times the sum of lagged covariances. Compare this benchmark with iid inference, established HAC/block-bootstrap methods, and nonoverlapping estimation. A finite-sample reliability map tied to holding period could be useful; neither overlap theory nor block bootstrap is intrinsically new.

**Financial contribution hypothesis:** Evaluate exposure sizing against an ES budget using an upper confidence limit. Measure capital-budget shortfall against known population ES in simulation. Realized financial loss and statistical interval coverage are separate outcomes.

**Pilot:** One [French daily industry portfolio series](https://mba.tuck.dartmouth.edu/pages/Faculty/ken.french/data_library.html), plus Gaussian simulation with h=1,5,20, alpha=0.975, approximately 1,000 daily observations, 100 replications, and 199 bootstrap resamples. These counts detect gross failure, not precise coverage. Add stationary volatility only after the benchmark. Target marginal holding-period ES, not tomorrow's conditional ES; regime shifts violate the stationary theorem.

**Closest literature:** [Sun–Cheng ES block bootstrap](https://research.wright.edu/en/publications/bootstrapping-the-expected-shortfall/), [Heinemann–Telg conditional ES residual bootstrap](https://arxiv.org/abs/1811.11557), and [recent self-normalized ES regression inference](https://arxiv.org/abs/2502.10065).

**Weakness:** Possibly replication rather than original research. Search overlapping-return tail-risk inference specifically. Effective tail information at long horizons may be too small for useful intervals.

### 2. Mortgage risk when outcomes have not matured

**Question:** What part of recent-cohort 12-month default risk is identified after only 3–9 months, and what part depends on transporting older cohorts' hazards?

**Statistical contribution hypothesis:** Define default, administrative immaturity, prepayment, and loss to follow-up separately. Treat repayment as competing with default on the same contract. Missing horizon support prevents nonparametric identification even with independent administrative censoring. Basic incidence bounds run from observed default proportion to observed defaults plus unresolved loans. Add sampling uncertainty separately; investigate a narrow sensitivity multiplier on unseen recent-cohort hazards relative to matured reference cohorts. Generic partial identification is established; the useful delta needs verification.

**Financial contribution hypothesis:** Test whether an apparent cohort improvement is merely incomplete observation and whether sensitivity envelopes change a provision/exposure decision. Constant LGD/EAD converts incidence into an illustrative scenario, not an empirically validated expected-loss model.

**Pilot:** [Freddie Mac](https://www.freddiemac.com/research/datasets/sf-loanlevel-dataset) provides origination/monthly performance records but currently requires Clarity registration/sign-in and applicable terms. Once access is established, use 5,000–10,000 loans; truncate a matured cohort at 3/6/9 months and retain its realized 12-month outcome for evaluation. No completed download is assumed.

**Closest literature:** [Competing default/prepayment hazards](https://scholars.duke.edu/publication/1559211) and [loan profitability with competing risks](https://www.sciencedirect.com/science/article/pii/S0377221722006567) already cover the generic modeling/finance connection.

**Weakness:** Access and code interpretation need work; cohort transport remains an assumption. Kill or repair if envelopes cannot support a meaningful decision.

### 3. Financial decisions under corruption of credit-model inputs

**Question:** At equal clean-data calibration, can protecting selected writable fields reduce financial decision loss more than changing the model?

**Statistical contribution hypothesis:** Fix a score and finite threshold/protected-field families. Estimate paired clean-versus-corrupted decision loss on an independent audit split, with simultaneous uncertainty to protect policy selection. Derive exact attainable score envelopes for logistic models where possible. Search attacks demonstrate achieved vulnerability; they do not certify worst-case protection.

**Financial contribution hypothesis:** Compare protected-field controls versus thresholds/model changes across declared loss/margin scenarios. Costs must be observed or explicitly hypothetical.

**Pilot:** [UCI credit-card default](https://archive.ics.uci.edu/dataset/350/default+of+credit+card+clients) supplies 30,000 observations, 23 features, and one outcome cohort. Use logistic/tree models and two corruption permissions. This is a hypothetical inference-time data-integrity threat: true behavior/outcome remain fixed while reported fields change. It is not evidence borrowers can alter bank-controlled repayment histories, natural temporal validation, or causal evaluation of newly offered credit.

**Closest literature:** [Constrained Adaptive Attack](https://arxiv.org/abs/2406.00775), [Strategic Classification](https://arxiv.org/abs/1506.06980), and [financial-model robustness/economic-impact evaluation](https://arxiv.org/abs/2512.15780) block generic novelty claims.

**Weakness:** Easy computation but weaker financial identification and theoretical originality. Drop if permissions are contrived or the contribution is only attack/AUC plots.

### 4. Sequential risk alarms after monitor restarts

**Question:** Can repeated VaR-monitor restarts after refits preserve global false-alarm control while limiting unnecessary financial interventions?

**Statistics:** Existing e-processes test conditional exceedance constraints, stronger than average unconditional coverage. Repeated 5% resets do not imply 5% control over ever producing a false alarm. Alpha spending/mixtures can repair this; these are established principles.

**Finance/pilot:** Simulate planned refits and one underestimation change; compare continuous monitoring, naive resets, and budgeted restarts on alarms, detection delay, and declared review costs. Laptop feasible.

**Closest literature:** [E-backtesting](https://arxiv.org/abs/2209.00991) and [Comparative e-backtests](https://arxiv.org/abs/2511.05840), revised March 2026.

**Weakness:** May reduce to elementary accounting without a thesis-sized contribution.

### 5. Selecting option quotes to reduce crash-risk identification width

**Question:** Which additional strike quote most reduces uncertainty about a specified risk-neutral crash event?

**Statistics:** Distinguish identification width from sampling uncertainty; bid–ask intervals are not automatically confidence intervals. Investigate strike selection under a declared noisy observation model.

**Finance/pilot:** Allocate a quote budget for a crash-insurance/hedging decision. Simulate 10–30 European-option strikes from a known distribution and solve small linear programs. Historical bid–ask access may require payment. Risk-neutral probabilities are pricing objects, not physical crash frequencies.

**Major novelty blocker:** [Shape-constrained option estimation](https://www.nber.org/papers/w8944) is established; [The Risk-Neutral Crash Frontier](https://arxiv.org/abs/2607.25353), revised October 2, 2026, already gives sharp joint probability/depth bounds from bid–ask quotes. Only the information-design pivot remains a candidate.

**Weakness:** Strong literature collision, preparation burden, and data-access risk.

## Ranking and repository

1. Holding-period ES overlap: strongest statistical preparation/data fit; novelty uncertain.
2. Mortgage maturity/transport: sharp identification problem; access and assumptions uncertain.
3. Credit-input integrity: distinctive security connection; finance target and theory weaker.

If an original substantial theorem is mandatory, reconsider after advisor review. A shared program requires distinct questions, estimands, experiments, and assessed deliverables plus explicit program permission; different titles alone are insufficient.

Keep course materials and ignored finance files in place. Add only a research README, candidate matrix, source registry with version/read-depth, assumptions/estimands note, and later an experiment log. Each candidate card records nearest paper, proposed delta, access status, and kill criterion. Tag claims observed-local/source-supported/assumption/hypothesis. Track reproducible scripts later; govern raw data by provider terms. Close one weekly gate: topic, access, benchmark, or contribution. No implementation in this round.
