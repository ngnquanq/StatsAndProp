# Round 2 (Claude): cross-critique and revision

**Source status:** I had no web access, so nothing here was checked online.
- **Verified by the coordinator:** the WQU pages, the FIRST EPSS methodology page (PU learning, 30-day horizon), the UCI Amazon page, the RCPS abstract, the GSW page, arXiv 1709.06296 and 1910.11840, and Stoller's bibliography.
- **Opened by Codex only:** Elkan–Noto Lemma 1, CRC Theorem 1, Howard et al., Diebold–Li, Fukasawa and the LANL page.
- **[R]:** anything else is from my memory and unverified.

## 1. Codex's math candidates

**Codex M1 (exploitation prevalence under incomplete reporting).**
- **Depth:** the theorem p(K)/b ≤ p(Y) ≤ p(K)/a is one line of algebra. "Sharpness by observationally equivalent laws" is standard Manski reasoning. Elkan–Noto already covers constant reporting. Codex admits all this, so the result is a benchmark, not a thesis.
- **Fatal flaw (Codex states it):** a and b cannot be learned from KEV, so the bounds come entirely from assumptions.
- **Overlooked dating problem:** "ever exploited by date T" is right-censored, and each CVE has a different exposure time. A prevalence over CVEs with unequal follow-up is not well-defined. It needs a time-to-event framing: the cumulative incidence F_K(t) of catalog confirmation t days after publication. If no confirmation precedes its exploitation, then F_K(t) ≤ F_Y(t) pointwise. That one-sided bound needs no a or b, and it is the narrow mechanism worth keeping.
- **Left-heaping [R]:** KEV's launch batch in November 2021 shares one dateAdded. Any window has to start after it.

**Codex M2 (auditing a mined access policy).**
- **Is the target real?** Mismatch between a mined policy and recorded entitlements can be computed for every user. Nothing needs to be sampled or certified. And mismatch is neither illegitimate access nor breach risk (coordinator challenges 2 and 3).
- **Depth:** Hoeffding plus a finite union bound is RCPS/CRC territory, and the coordinator verified the RCPS abstract.
- **Dependence and leakage:** Amazon users share managers, role families and resources, so splitting by user does not make the folds independent. Leakage through manager and role attributes is likely.
- **One more authentic variant:** train on the snapshot, then predict the grants in the change history. But that turns the topic into prediction, and the theorem disappears.
- **Verdict:** drop it as the primary.

**Codex M3 (authentication monitoring).** The product martingale ∏(1+λ_t(X_t−q_t)) with Ville's inequality is the textbook betting construction (Howard et al.; Waudby-Smith–Ramdas [R]), and the α+δ accounting adds nothing new.
- LANL is 7.2 GB compressed (Codex-only).
- Its red-team labels do not certify the rest of the traffic as benign.
- Failed logons appear only for users with some successful authentication, which is a selection effect.

My own M3 has the same problems plus more complexity. Drop both.

## 2. Revising my candidates

**My M2 (EPSS calibration against KEV) has a dating error.** I claimed Y* ≤ Y. For the 30-day horizon EPSS actually forecasts, that is false. A CVE exploited in 2019 but added to KEV inside the window gives Y* = 1 even if there was no exploitation activity in the window. Codex's warning that "addition dates lag exploitation" applies directly.

**Narrowed revision, M2′: a one-sided test of whether EPSS under-forecasts.**
- **Anchor:** take one EPSS score per CVE at a fixed anchor, for example 7 days after NVD publication. Exclude CVEs already in KEV at the anchor. This removes the pseudo-replication from daily repeated scores (the "repeated user" problem here) and keeps the score dated before the outcome.
- **Assumption A (stated, not proved):** for CVEs anchored near publication, exploitation behind a KEV listing in (anchor, anchor+30] is active within that window. Zero-days exploited only before disclosure violate A. The cumulative target Y_≤anchor+30 needs no such assumption but is not what EPSS forecasts. Report both.
- **Null:** H₀: c(p) ≤ p for all p.
- **Statistic:** S = max over intervals [s,t] of Σ(Y*_i − p_i)·1{p_i ∈ [s,t]}. It is a cumulative-calibration statistic.
- **Planned proof (moderate depth, within classical probability):**
  1. S is nondecreasing in each Y*_i.
  2. A coupling argument then shows that, among independent laws under H₀, Y*_i ~ Bernoulli(p_i) is least favourable.
  3. So a Monte Carlo test that conditions on the observed p_i has exact finite-sample level.
  4. Under-reporting only makes the test more conservative, so a rejection means under-forecasting even with incomplete catalogs.
  5. Open limitation: KEV adds CVEs in campaign batches, so outcomes are positively dependent. Under that dependence, the independent-Bernoulli null is anti-conservative. Handle it with a vendor-month cluster version (a sensitivity analysis, not a theorem).
- **Nearest work:**
  - Bröcker–Smith consistency resampling [R].
  - Tygert and Arrieta-Ibarra cumulative calibration [R].
  - Dimitriadis–Gneiting–Jordan CORP [R].
  - The EPSS papers' own calibration plots against their own sensor outcomes [R].
  - Vendor blogs comparing EPSS scores for KEV-listed CVEs (descriptive) [R].
  - Contribution: a synthesis with a least-favourable proof and an external one-sided check. It is not a new method.
- **Circularity [R, must check]:** I believe EPSS v3 uses KEV as an input feature. That makes the pre-addition anchor mandatory, and the scores of interest are the ones before listing.
- **Model versions [R]:** v3 ran from roughly March 2023 to early 2025, then v4. Analyse within one version.
- **Rare-event precision (a gate before committing):**
  - In a low-score bin with 20,000 CVEs at mean p = 0.002, the expected count is 40 with SD ≈ 6.3.
  - Detection needs about 52 or more KEV additions inside the window.
  - High-score bins can essentially never reject, because KEV under-covers.
  - So the test only has power where under-forecasting is the realistic risk, which is useful.
- **A useful null:** "no evidence of under-forecasting at the detectable effect size δ" is a valid result if reported with a power curve.

**My M1 (anytime-valid audit of access certification).** It still collides with ALPHA and Waudby-Smith–Ramdas sampling without replacement [R], and its labels are fully synthetic. Keep it only as the second backup. Its value is that it survives if the KEV data turns out unusable.

## 3. The FE candidates

- **Codex F1 (portfolio stability):** it collides with the two abstracts the coordinator opened. A Lipschitz bound for a strongly convex QP is textbook. French industry portfolios are not tradable; sector ETFs from about 1998 would be [R]. Drop.
- **Codex F2 + my F1 (bond risk and hedging):** the monotone price bracket is trivial, and Diebold–Li, Litterman–Scheinkman and key-rate durations are all well established. GSW curves are fitted and revised. Merge them into one **backup** with a hedge decision: key-rate vs. PCA hedge notionals for a hypothetical ladder, measured by hedged P&L tail loss. Record the data vintage.
- **Codex F3 (discrete hedging under misspecified volatility):** the most authentic finance, but simulation-heavy. Its analytic benchmarks are established:
  - El Karoui–Jeanblanc–Shreve [R]: hedging P&L = ½∫Γ S²(σ_hedge² − σ_real²) dt.
  - Bertsimas–Kogan–Lo and Fukasawa: discretization error.
- **My F3 (put-writing allocation):** too few crashes to identify jump parameters. However, the same EKJS term is exactly the variance risk premium that put-writing harvests.

**Merged FE primary, F′: choosing a rebalancing rule and a hedging volatility for a hypothetical short 30-day ATM SPX put book.**
- **Decision:** fixed-time vs. delta-band rebalancing, and hedge volatility = VIX, a realized-vol forecast (HAR), or a blend.
- **Outcome:** 99% expected shortfall of hedged P&L at matched assumed cost.
- **Theory:** the EKJS identity plus an O(√Δt) discretization term, both established. The planned proof is a bound on their sum under bounded Γ away from expiry. It is a benchmark proposition, not a novelty claim.
- **Known-truth pilot:** GBM with exact Greeks, then Heston.
- **Historical replay (SPX + VIX, labelled synthetic):**
  - Pricing at VIX overstates ATM implied vol because of skew.
  - These are not tradable quotes.
  - FRED's SP500 series covers only about 10 years [R]. Longer SPX history needs a source whose terms are checked. VIXCLS is on FRED (Codex-only).
- **WQU fit:** Derivative Pricing, Stochastic Modeling, Risk Management, Financial Econometrics (HAR), and Financial Data.
  - A group of up to three under 690 splits naturally: theory and simulation, replay, vol forecasting.
  - Under 692, it becomes a critical review plus replication of the discrete-hedging literature.
- **A useful null:** "adaptive bands do not beat fixed-time rebalancing at matched cost once vol is misspecified."

## 4. Surviving pair and backups

| | Primary | Backup | What the backup survives |
|---|---|---|---|
| **Math** | M2′ one-sided EPSS test | Cumulative incidence F_K(t) ≤ F_Y(t): Kaplan–Meier / Aalen–Johansen of time to KEV listing from NVD+KEV, with a delay-sensitivity analysis | Losing the EPSS archive, circularity, or version breaks |
| **Math (2nd)** | | M1 design-based IAM audit, synthetic labels | A KEV sparsity failure |
| **FE** | F′ discrete hedging under misspecified vol | Rates hedge on GSW | Option-replay data problems |

**Independence:** the two theses differ in question (is a forecast calibrated vs. which hedge rule to use), data (CVE catalogs vs. SPX/VIX), and theorem (least favourable by coupling vs. decomposition of hedging error).

**Skills that transfer without repeating a contribution:**
- stochastic dominance and coupling;
- exact Monte Carlo tests;
- tail-risk precision;
- the "score/price dated before outcome" discipline.

**Round 3 must verify:**
1. The EPSS v3/v4 feature lists, including whether KEV is an input.
2. The location and terms of the EPSS archive.
3. KEV dateAdded heaping.
4. The length of FRED's SP500 history.
5. The EKJS and Bertsimas–Kogan–Lo statements, against the primary sources.
6. Whether a full-text EPSS calibration paper already runs a KEV one-sided test. If so, M2′ becomes a replication and the cumulative-incidence backup moves up.
