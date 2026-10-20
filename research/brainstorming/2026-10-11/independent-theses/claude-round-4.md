# Round 4 audit (Claude): final pair, gates and corrections

I read the five files. I opened no sources online and edited nothing. My only checks were by hand, on algebra from the memos. **Publication-level novelty is unverified for every candidate.** Each is planned as a master's synthesis with a bounded specialization.

## Final rankings

| | Main | Backup |
|---|---|---|
| **Math** | IAM sequential assurance with noisy reviewers (Codex R3 framing) | KEV time-to-listing cumulative incidence, using the full CVE denominator |
| **FE** | Treasury hedge choice: loading error, nonlinear remainder, and sensitivity to how the curve is built | Ten-industry covariance/turnover replication on French portfolio data |

- **Exact stratified hypergeometric IAM:** this becomes the clean-label baseline chapter of the math main, not the backup. It fails the same way the main does: synthetic labels, and a contribution that is only synthesis.
- **Why KEV is the math backup:** it is the only option that survives an advisor who demands real outcome data.
- **SPX delta hedging:** dropped to reserve. Fukasawa already covers the discretization question, VIX is not an ATM put quote, and there is no licensed source for option history.

## Independence

The two topics differ in target, data and theory:

- **Math:** a finite-population rubric violation rate θ, Ville/martingale theory, and Amazon used only as a grant frame.
- **FE:** residual hedge risk of a hypothetical book, a ridge/Taylor perturbation analysis, and GSW curves.

No theorem, dataset or figure is shared. What transfers is method, with attribution: precision planning, freezing decisions before evaluation, and boundary reporting. Keep martingale arguments out of FE and yield curves out of the math thesis.

**The decorative-domain risk is real for the math main.** It is not decorative only if two things hold:
1. The thesis argues why legitimacy review is costly human judgment, as opposed to a computable policy mismatch.
2. The Amazon data is presented as structure only, never as validation.

## Source-supported, planned, or assumed

**Established in sources:**
- ALPHA and Shekhar et al. already cover weighted sampling, with or without replacement, including prediction-assisted audits.
- RCPS already covers finite-family risk control.
- The KEV schema defines `dateAdded` as catalog entry.
- GSW curves are revised fitted curves.
- 1709.06296 already links turnover to shrinkage.
- Regularized interest-rate hedging is published (Mantilla-Garcia 2022), but only its abstract/search text was seen.

**Planned proofs (reconstruction or specialization; I checked the algebra):**
- **T1 validity.** If q_t(i) ≥ γ/N, then Z_t ≤ 1/γ. Any λ_t ∈ [0, γ] keeps every factor nonnegative, because γ ≤ γ/(1 − γsτ). Under H₀, E[factor | past] ≤ 1, so Ville's inequality gives P(certification ever occurs) ≤ α. This bound does not cover daily alarm counts or several targets at once; multiple targets need a family-wide α budget.
- **Stopping bound (Codex).** The drift g = Δ²/(4B²) and the overshoot term log(1 + λsτ) check out. But the assumption E[Z | past] ≤ sτ − Δ also bounds false positives (reviewer specificity). State that.
- **Ridge perturbation.** Use ‖(AᵀA + ηI)⁻¹Aᵀ‖ ≤ 1/(2√η), which is sharper than 1/η alone. The ridge penalty is not unit-invariant, so hedge instruments must be standardized first.
- **Taylor remainder.** ½|C|t²e^{−ty+tr}r² is correct for each cashflow. Report it with gross hedge leverage Σ|h_k|·(instrument cashflows), not only with netted cashflows.

**Assumptions (not facts):**
- Conditional reviewer sensitivity ≥ s on each fresh review.
- KEV listing implies prior exploitation (the CISA inclusion criteria were not checked here).
- Hypothetical cashflows and costs.
- WQU 690 eligibility.

## Corrections carried forward

1. Claude R3 T2: an *average conditional* sensitivity over true violations is sufficient, and a per-grant bound is stronger than needed. However, planted-item Clopper–Pearson needs binomial assumptions plus transfer of detection difficulty. It is simulation-only and must not be used to estimate s.
2. Claude R3 T3 had no positive drift condition. Use Codex's version, and accept non-certification when θ < τ.
3. Monte Carlo frequency within 2 SE is a diagnostic, not an acceptance certificate. Use binomial CIs and account for multiplicity across cells.
4. Misspecified arms may turn out conservative. Report what happens; don't require inflation.
5. "Six-parameter fit ⇒ near-perfect hedge" does not follow logically. Treasury par yields need conversion to zero rates before use.
6. "Kato–Nakagawa" is an unverified author attribution. The evidence lists only the title of 2604.06116.
7. A historical GSW replay is a shock replay, not a self-financing backtest. Do not estimate ES99 from monthly data.

## Null findings to keep

- EPSS calibration from KEV labels is dead.
- ES overlap/scaling is replication only.
- Adding turnover is not a contribution.
- Noisy policy mining is not new.
- Adaptive discrete hedging is covered by Fukasawa.
- Weighting may not beat uniform sampling.
- An unchanged best baseline hedge, or an "indistinguishable within ±10%" result, is reportable.

## Unresolved gates (first month: go/no-go)

**Math:**
- Read the full texts of 2604.06116, Shekhar et al. beyond Sections 3–4, and Huber-robust CS (2301.09573).
- Search the imperfect-test prevalence literature (from memory, the Rogan–Gladen line).
- **Advisor:** is synthesis plus a synthetic-label application acceptable, and is martingale material in scope?
- **User:** does employer policy restrict publication?
- **No-go triggers:** a close source already handles noisy reviewers, or the advisor requires real outcomes. Either one switches to the KEV backup.

**FE:**
- Compare the full text of Quaedvlieg–Schotman (EUR PDF) and Mantilla-Garcia.
- Check the GSW download and schema, and whether an alternative curve is available.
- WQU: 690 or 692, team composition, and start date.

## Minimum viable deliverables

- **Math main (6-month floor):**
  1. A nearest-paper memo.
  2. Reconstructed T1 with the admissible λ range.
  3. An identifiability counterexample for unknown s, plus the average-sensitivity sufficient condition.
  4. A clean-label exact stratified chapter.
  5. Simulation: 4 scenarios, R = 2000, capped effort, reporting distinct grants and repeat reviews.
  6. An Amazon-frame application labeled as synthetic.
  7. The stopping bound proved if possible, otherwise analyzed numerically.
- **Math backup:**
  1. Cohorts published after November 2021 with the full CVE denominator, and exposure/censoring rules.
  2. Kaplan–Meier/Aalen–Johansen curves with Greenwood intervals.
  3. A one-line lower-bound proposition, labeled as trivial.
  4. Results by stratum, kept descriptive.
- **FE main:**
  1. A data and vintage log.
  2. Duration, key-rate and PCA hedges for one book.
  3. Known-truth recovery.
  4. GSW plus one alternative curve.
  5. Attribution into oracle, loading and nonlinear components.
  6. Paired Newey–West/block-bootstrap intervals and assumed-cost break-even levels.
  7. Code, report and presentation.
  8. The 692 adaptation: a critical review plus bounded replication.
- **FE backup:**
  1. Reproduce the 1709.06296 mechanism on 10 industries.
  2. Separate sampling error from regime error using a known covariance.
  3. Label the portfolios as constructed, not executable.
