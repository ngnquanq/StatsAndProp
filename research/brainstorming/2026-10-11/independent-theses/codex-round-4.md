# Codex Round 4 — final evidence and feasibility audit

Read Claude Round 3, Codex Round 3, updated evidence and audit questions. Retain the IAM–Treasury pair, conditional on advisor/program acceptance of a substantial proof-and-replication contribution. No empirical result or validated novelty is claimed.

## Mathematics main and backup

**Main: finite-population IAM certification under imperfect review.** Freeze N grants and rubric-defined latent labels; public Amazon supplies structure, while violations and reviews are synthetic. Administrative grants/removals do not establish legitimacy or breach risk.

For replacement draws q_t(i)≥γ/N and fresh reviews, Z_t=R_t/[Nq_t(I_t)]≤1/γ. Under H₀:θ≥τ, the required condition is E[Z_t|past]≥sθ. Claude correctly notes that a lower bound on the average *conditional* sensitivity over all true violations suffices. My per-grant conditional bound is a stronger sufficient assumption, not logically necessary. Historical aggregate accuracy does not imply either condition.

With predictable 0≤λ_t≤γ, the factors 1+λ_t(sτ−Z_t) are nonnegative and their product is a null supermartingale. Crossing 1/α controls erroneous certification **ever in this fixed campaign** at α; multiple targets need separate family-wide accounting. Exhaustion is inconclusive. Clean-label weighted WoR results from [Shekhar et al.](https://arxiv.org/pdf/2305.06884) cannot simply be transferred to noisy replacement reviews. Report total draws, unique grants and repeats; repeatedly consulting a fixed erroneous label can violate conditional sensitivity.

**Reject the planted-item shortcut.** Exchangeability permits perfectly correlated outcomes, so it does not establish the iid/binomial model behind Clopper–Pearson. Planted-to-real difficulty transfer and stability across audit histories need independent justification; fixing s_L beforehand solves neither problem. Seeding belongs only in declared simulation scenarios here. Unknown reviewer sensitivity leaves latent populations observationally indistinguishable. [Huber-robust CS](https://arxiv.org/abs/2301.09573) is another methodological neighbor, not evidence that this noise model is already solved.

**Substance gate:** obtain advisor acceptance of reconstructed foundations, an identifiability/boundary analysis, and a bounded log-drift/overshoot proof. The expected-stopping result requires a positive conditional drift alternative, not θ<τ alone. Conservative s or false positives can prevent certification. The theoretical effort bound may be enormous; no practical efficiency follows from it. Compare noisy-review literature and the 2026 audit paper before naming any extension new.

**Backup: fixed-budget exact-label stratified IAM assurance**, with synthetic oracle labels, hypergeometric inversion and least-favorable allocation proofs. It removes reviewer-noise complexity; it does not survive an advisor rejecting synthetic-label applications. Do not automatically replace it with thin-theory KEV survival analysis.

First-month go/no-go: accepted proof package and simulation-based application, then a timed small pilot. At 2,000 replications and p=.05, SE≈.0049; use binomial uncertainty and multiplicity-aware diagnostics. Simulation checks cannot prove validity. Misspecified scenarios need not inflate error; retain conservative failures and null efficiency findings. Math remains scoped to 6–12 months.

## Financial Engineering main and backup

**Main: controlled Treasury-hedge replication with loading, nonlinear-valuation and curve-construction sensitivity.** The financial decision is hedge notionals for one hypothetical fixed cashflow book. Primary outcomes are residual RMS/standard deviation, stress loss, turnover and assumed-cost break-even levels, relative to the same unhedged book. Compare methods under common hedge definitions and gross-leverage limits.

Novelty is unresolved and the nearest work is unusually close: [regularized interest-rate hedging (2022)](https://doi.org/10.1080/0015198X.2022.2095193) and [Hedging Long-Term Liabilities](https://repub.eur.nl/pub/131883/RePub-131883-OA.pdf). I opened the latter's abstract/introduction: it already investigates estimation noise, multicollinearity and time-varying factor loadings. The former's publisher fetch failed; full-text comparison remains mandatory. Therefore loading-error attribution is a replication/specialization, not a demonstrated new gap.

Keep deterministic perturbation and cashflow Taylor bounds as analytic benchmarks. Positive ridge strength, bounded loading errors/shocks and finite absolute cashflow sums are required; hedge gross leverage enters the remainder. The ridge closed form applies only unconstrained; common convex leverage constraints need a separate strong-convexity argument. Estimated error radii and historical uncertainty need their own dependence assumptions.

GSW replay measures model-marked risk, not executable trading. A six-parameter smoother does not imply an almost-perfect three-factor hedge. A second public curve is optional sensitivity after validating access, vintage and zero/par conversion; it establishes no novelty automatically. Avoid 99% ES from a short monthly sample. Preserve unchanged rankings and negative results.

**Backup: fixed-dimensional covariance/turnover decision-risk replication** on constructed French portfolios, with known-covariance simulation and existing methods acknowledged.

FE follows approximately one year later. WQU 690 track/team eligibility remains conditional; no solo acceptance is assumed. Under 692, recast as critical review with permitted replication. Keep separate targets, data, proof claims, figures and manuscripts; transfer precision planning, diagnostics and reproducible tooling only. No experiments were run.
