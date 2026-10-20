# Round 1 (Claude, independent): 3 math topics, 3 FE topics, 3 pathways

**What I read:** `independent-theses/context.md` and the coordinator's `literature-check.md`. I did not open Codex round 1, the old shortlist memos, or any personal or application files.

**Source labels:** No web tools were available. "Verified" applies only to the WQU pages listed in context.md and the items in `literature-check.md`. Every other citation or dataset below is **[R] = recalled, unverified**. Existence, access terms and coverage all need checking in Round 2. None of the theorems below is claimed to be new.

---

## Math/statistics topics

### M1 (IAM): Anytime-valid audits of access-certification error rates with risk-score-guided sampling
- **Target:** θ = the share of N user–entitlement grants that a reviewer would judge inappropriate (a finite-population mean). Decision: stop the recertification campaign once "θ ≤ θ₀" is certified, or escalate to a full review.
- **Planned result:** Sample without replacement, with probability proportional to a risk score but floored at π_min. Build a time-uniform (1−α) confidence sequence for θ from Horvitz–Thompson-style increments.
  - Proof sketch: under H₀, a nonnegative supermartingale built from bounded increments (the floor makes them bounded), then Ville's inequality.
  - Add a width bound that depends on how well the score aligns with the true labels.
  - The established ingredients are Ville's inequality, betting confidence sequences, and confidence sequences for sampling without replacement (Waudby-Smith & Ramdas [R]).
- **Nearest methods:** Stark's ALPHA risk-limiting audit martingales [R] (very close), Zrnic–Candès active inference [R], and classical PPS audit sampling.
- **Data:** The UCI "Amazon Access Samples" or the Kaggle Amazon Employee Access data [R] supply a realistic user × entitlement structure. The inappropriate labels and the scores are simulated with controlled AUC.
  - Limitation: no real ground truth exists, so this is mostly a structured simulation.
- **Laptop pilot:** N = 50k, θ ∈ {0.5%, 2%}, score AUC ∈ {0.5, 0.7, 0.9}, 2,000 replications. Compare the sample size needed to certify under uniform vs. score-guided sampling. Runtime is minutes.
- **Fatal weakness:** ALPHA/risk-limiting-audit theory may already cover this, which would reduce the contribution to a domain transfer. Read Stark's papers first.
- **Timeline:** 6–9 months. The theory is moderate and tractable.

### M2 (Vulnerability risk): Calibration of EPSS forecasts when exploitation outcomes are only partly observed
- **Target:** c(p) = P(exploited within 30 days | EPSS = p). We only observe Y* = "added to CISA KEV within 30 days".
- **Key assumption:** a KEV listing implies exploitation, so Y* ≤ Y always. That gives c*(p) ≤ c(p) whatever the detection mechanism, even if detection depends on p.
- **Planned results:**
  1. A test of the one-sided null H₀: c(p) ≤ p (no under-forecasting) can be run validly on Y*. Under-forecasting can be detected; over-forecasting cannot be identified.
  2. Sensitivity bounds: if detection probability is at least r, then c(p) ∈ [c*(p), c*(p)/r].
  3. A one-sided uniform band from kernel regression with cluster dependence (shared vendor or campaign, overlapping daily windows), using a cluster/block bootstrap with many clusters.
  - The ingredients are established: Manski-style partial identification [R] and CORP reliability diagrams (Dimitriadis–Gneiting–Jordan [R]).
- **Data:** the FIRST EPSS daily score archive, the KEV JSON (`dateAdded`) and NVD [R, all three].
- **Limitations:**
  - EPSS's outcome comes from proprietary sensors, not KEV, so the two measure different things.
  - KEV's inclusion policy requires remediation guidance.
  - EPSS changes model version over time [R].
  - KEV may be an EPSS input, which would make the test circular.
  - Descriptive exposure is not the same as real harm.
- **Laptop pilot:** simulate forecasts with a known c(p), detection r(p) and clustered outcomes, and check size and power. Then run one snapshot month of real data.
- **Fatal weakness:** KEV covers only a small share of CVEs [R], so the one-sided test may have little power. The circularity problem is a second risk.
- **Timeline:** 6–10 months. This reuses the repo's KDE, regression and bootstrap work directly.

### M3 (SOC): Change detection in authentication behaviour with a guaranteed false-alarm rate
- **Target:** for each user, the first hour at which the count of new destination hosts per hour shifts away from its normal pattern. Decision: whether to raise an alert, within a fleet-wide daily alarm budget.
- **Planned result:** Build conformal p-values from each user's own history, stratified by hour of week, and feed them into a conformal test martingale or e-detector.
  - A: under within-stratum exchangeability, average run length to a false alarm is at least 1/α.
  - B: a bound on detection delay for a Poisson rate shift δ.
  - C: allocate α across users so the fleet stays within its alarm budget.
- **Nearest methods:** Vovk conformal martingales and Volkhonskiy et al. [R], Shin–Ramdas–Rinaldo e-detectors [R], CUSUM, and Turcotte/Heard work on LANL data [R].
- **Data:** LANL "Comprehensive, Multi-Source Cyber-Security Events" (Kent 2015) with red-team labels [R]. Registration terms and size are unverified.
  - Limitations: a 2015 on-premises Active Directory environment, few and coarse red-team labels, about a billion events (needs user subsampling).
- **Laptop pilot:** simulated negative-binomial counts with diurnal and weekly cycles, plus injected shifts. Compare empirical average run length and delay against the bounds.
- **Fatal weakness:** holidays and drift break exchangeability, so the guarantee may hold only nominally. Real-data detection estimates will be imprecise.
- **Timeline:** 8–12 months. This is the riskiest of the three.

---

## Financial-engineering topics (provisionally designed for the WQU 690 Research Track; adapting to 692 or group work is still open)

### F1: Hedging interest-rate risk on a stylised bank-style book (Treasury curve)
- **Decision:** hedge notionals in 2/5/10/30-year instruments for an amortising fixed-rate asset funded short. Compare duration, key-rate, 3-factor PCA, and dynamic Nelson–Siegel with shrunk loadings.
- **Outcome:** out-of-sample variance and 99% expected shortfall of hedged monthly P&L, net of turnover costs.
- **Theory (planned, standard):** split hedge error into model residual and estimation error, and use a delta-method expansion of the error in estimated hedge ratios.
- **Data:** the Fed GSW zero curve and Treasury par yields [R].
- **Limitation:** prices implied from the curve are not tradable quotes. Futures cheapest-to-deliver effects are ignored.
- **Nearest methods:** Litterman–Scheinkman, Diebold–Li, Ho's key-rate durations [R].
- **WQU map:** Financial Markets, Financial Econometrics, Stochastic Modeling, Risk Management, ML in Finance.
- **Fatal weakness:** a well-worn area, so the likely ceiling is a careful replication.

### F2: Pricing an aggregate cyber-loss layer when losses are under-reported
- **Decision:** premium and capital for an excess-of-loss layer, or buy/don't-buy protection at a given spread.
- **Model:** Cox/Hawkes event frequency with GPD severity. Theory is subexponential asymptotics for compound sums (established) plus profile-likelihood intervals for the layer price.
- **Data:** the HHS OCR breach portal and SEC 8-K Item 1.05 filings [R].
- **Limitations:**
  - Records exposed are not dollar losses. Any cost-per-record mapping is weak.
  - There are no market prices, so "pricing" here means an actuarial premium principle, not arbitrage pricing.
- **Nearest methods:** Eling–Wirfs and Bessy-Roland et al. [R].
- **Fatal weakness:** severity is not identified from public data.

### F3: Allocating to a put-writing strategy under jump/crash risk
- **Decision:** the fraction of a portfolio held in SPX put-writing vs. equity vs. T-bills, under CRRA utility or an expected-shortfall constraint, using tradable ETFs where they exist.
- **Theory:** decompose put-writing P&L into the variance risk premium and gamma. Derive the optimal static allocation under jump-diffusion, in the style of Liu–Pan [R]. Use a block-bootstrap interval for the certainty-equivalent gain.
- **Data:** CBOE PUT/BXM index histories, VIX and FRED T-bills [R]. ETF histories are short.
- **Nearest methods:** Coval–Shumway, Israelov–Nielsen [R].
- **WQU map:** Derivative Pricing, Stochastic Modeling, Portfolio Management, Risk Management, Financial Econometrics.
- **Fatal weakness:** few crashes in the sample means jump parameters are weakly identified, so the uncertainty may swamp any conclusion. Index returns are not tradable-asset returns.

---

## Pathways

| Pathway | Different question / data / contribution | Concrete skill transfer | Main risk |
|---|---|---|---|
| **P1: M2 → F2** | Is a forecast valid? (EPSS/KEV) vs. what price should a risk transfer carry? (breach portals) | Partial identification under under-reporting, rare-event tails, clustered dependence | Both are "cyber", which reviewers may read as overlap; F2's data is the weakest |
| **P2: M1 → F3** | Certifying an audit vs. sizing an allocation | Betting martingales (the betting fraction in M1 is a Kelly-type fraction), bounded-increment concentration, planning precision before deciding | M1 may sit too close to ALPHA; F3 is crowded |
| **P3: M3 → F1** | Detecting an alert vs. choosing a hedge | Seasonal/state-space time series, out-of-sample discipline, residual monitoring, block bootstrap | Weak thematic link; F1 may end as replication |

**Recommendation:**
- **Math:** M2 is the strongest. The data is authentic and public, the identification result is clean, and it reuses KDE and bootstrap skills from the repo. M1 is the backup.
- **FE:** F3 is the strongest, because it has the richest derivatives content. F1 is the backup because it is the safest.
- **Pairing:** M2 + F3 gives the clearest independence between the two topics, at the cost of a thinner skill-transfer story.

**Checks for Round 2:**
- Does the EPSS model use KEV as an input?
- How close is ALPHA to M1?
- Are the CBOE index and LANL access terms workable?
- Is HHS data usable for F2?
