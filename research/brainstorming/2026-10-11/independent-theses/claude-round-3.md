# Round 3 (Claude): one main topic and one backup per degree

I read `context.md`, `evidence.md`, Claude rounds 1–2 and Codex rounds 1–2. I checked nothing online, so citations marked [R] are from memory and unverified. No files were edited.

## What I withdraw

- **My EPSS one-sided test (round 2, M2′) is dead.** The CISA schema defines `dateAdded` as the date of entry into the catalog. My assumption A has no support. I drop the topic entirely, not just to backup.
- **Codex is right about the IAM target.** An inappropriate-grant rate judged by reviewers is a better target than mismatch against a mined policy. Weighted sampling with replacement or without (WoR), plus a probability floor, is already covered by ALPHA and Shekhar et al.

## Mathematics main topic

**Provisional title:** *Certifying access-recertification error rates with imperfect reviewers: weighted sequential audits with planted-item sensitivity bounds*

**Target.** θ = (1/N)·#{inappropriate grants} in a frozen population of N user–entitlement grants, under a declared review rubric.
- **Decision:** certify θ < τ and close the campaign, or escalate to a full review.
- **Scope:** this certifies the rate defined by the rubric. It says nothing about breach risk.

**Setup.**
- Draws are with replacement: I_t ~ q_t, where q_t is predictable and q_t(i) ≥ q_min.
- The review outcome is R_t ∈ {0,1}, and Z_t = R_t / (N·q_t(I_t)).

**Planned results (none claimed new):**
- **T1 (reconstruction).** With a known sensitivity bound s, the betting supermartingale ∏(1 + λ_t(sτ − Z_t)) plus Ville's inequality gives a level-α certification. This part is established.
- **T2 (where I disagree with Codex).** Codex's assumption that every inappropriate grant has sensitivity s_i ≥ s is stronger than needed.
  - Under importance weighting, E[Z_t | F_{t−1}] = θ·s̄ + (false-positive term ≥ 0). Here s̄ is the *average* sensitivity over the real inappropriate grants.
  - An average can be designed for. Plant K known-inappropriate grants, with reviewers blind to which ones; this is error seeding [R: Mills]. A Clopper–Pearson lower bound s_L at level α₂ estimates s̄. Then run T1 with s_Lτ at level α₁.
  - Claim: P(false certification) ≤ α₁ + α₂, provided two things hold. First, planted items are exchangeable with real inappropriate grants in how hard they are to detect. Second, s_L is fixed before the audit stream starts.
  - Proof route: union bound, then conditioning on s_L. Since s_Lτ ≤ s̄τ ≤ s̄θ under the null, the supermartingale property survives.
  - This replaces Codex's indistinguishable-reviewer construction, which shrinks to a one-paragraph remark.
- **T3 (bounded depth).** Bound the expected number of reviews to certify when θ < τ, using Wald's identity on log-wealth.
  - It would work under a two-class score model with parameters: score likelihood ratio, q_min, s̄ and K.
  - This gives the trade-off between planted items and audited grants.
  - If the proof stalls, fall back to a numerical characterization only.
- **Optional:** a WoR extension, only after reading Shekhar et al.'s proofs in full.

**Prerequisites.** Conditional expectation, discrete martingales and Ville's inequality. These sit inside the repo's stochastic-processes material. Optional stopping needs a short learning plan.

**Established methods vs proposed delta.**
- **Established:** betting confidence sequences (Waudby-Smith–Ramdas; Howard et al.), ALPHA, Shekhar et al. (weighted WoR with predictions), Kato–Nakagawa 2026 (sequential audit sampling), and error seeding / capture–recapture.
- **Delta:** the average-sensitivity condition, the α-split with planted items, and the budget bound.
- **Gate:** if the full texts of Shekhar et al. or Kato–Nakagawa already contain noisy-reviewer or expected-stopping-time results, the delta shrinks to synthesis plus application. That is still a legitimate master's thesis *if the advisor accepts it*.

**Pilot (public data plus synthetic labels).**
- **Grant frame and features:** UCI Amazon Access Samples.
- **Risk score (real):** how rare an entitlement is within the same manager or role family. It is computed from the real structure.
- **Labels (synthetic):** P(inappropriate) = logistic(a + b·score).
  - a is set so that θ ∈ {0.5, 1, 2, 4}% with τ = 2%.
  - b controls how well the score aligns with the labels.
  - One variant clusters violations by manager.
- **Reviewer sensitivity:** s̄ ∈ {0.6, 0.8, 0.95}.
- **Misspecified arm:** planted items are easier to detect than real ones.
- **Other settings:** K ∈ {25, 50, 100}, α₁ = α₂ = 0.025.

**Acceptance criteria.**
- **Validity:** 10,000 replications per cell at the boundary θ = τ. The false-certification rate must be ≤ 0.05 + 2·0.0022, where 0.0022 is the Monte Carlo SE.
- **Misspecified arms:** these must *show* the inflation. That documents a boundary of the method; it is not a failure.
- **Efficiency:** compare reviews needed to certify at θ = τ/2 against uniform sampling and fixed-n Clopper–Pearson, with Monte Carlo CIs. The T3 bound should sit within a stated slack of the simulated E[T].
- **Null results count:** weighting is not required to win.

**Milestones (month 0 = advisor approval):**
- **Months 1–2:** reconstruct the T1 proofs; write a nearest-paper memo on Shekhar et al. and Kato–Nakagawa; **advisor gate on the delta**.
- **Months 3–4:** prove T2; build the synthetic simulation harness.
- **Months 5–6:** Amazon frame and scores; validity grid. *A 6-month thesis can stop here, with T3 handled numerically.*
- **Months 7–9:** prove T3; optional WoR extension.
- **Months 10–12:** writing and buffer.

**Math backup.** *Time from CVE publication to KEV listing: cumulative incidence under administrative censoring as a lower bound on exploitation by time t.*
- If no CVE is listed without prior exploitation, then F_K(t) ≤ F_Y(t). This holds even for zero-days.
- Methods: Kaplan–Meier and Greenwood intervals on cohorts published after November 2021 (after the launch batch), stratified by publication year to handle drift.
- Decision reading: the share of eventually-listed CVEs that are listed within 15, 30 or 60 days, which bears on patching deadlines.
- EPSS appears only as descriptive strata, with no calibration claim.
- It uses real data but has thin theory. **It becomes the main topic if the advisor requires real outcome data.**

## FE main topic

**Provisional title:** *Does curve construction decide the hedge? Key-rate versus factor hedging of a bank-style fixed-rate book under alternative public yield curves*

**Decision.** Choose hedge notionals in 2/5/10/30-year par instruments for a hypothetical amortizing fixed-rate asset book funded short, rebalanced monthly. Candidate hedges: duration-only, key-rate, 3-factor PCA and dynamic Nelson–Siegel.

**Outcomes.**
- The distribution of residual economic-value change.
- Turnover, and break-even levels under assumed costs.
- Stress tests under the six standardized Basel IRRBB shocks [R]. These are illustrative only, not a compliance claim.

**Where I disagree with Codex.**
- **GSW curves are a 6-parameter Svensson fit each day.** The cross-section is low-dimensional by construction. A 3–4 instrument hedge priced off the same curve will look nearly perfect, so the ranking of hedges may reflect the smoother rather than the market.
- **My delta:** re-run everything on a second public curve built differently, such as Liu–Wu or Treasury par yields [R]. Then measure how stable the hedge ranking is across curves, i.e. the curve-construction model risk.
- **I demote Codex's spectral-perturbation theorem to an appendix proposition.** WQU 690 is code, report and presentation, and theorem depth belongs in the math thesis. Keeping it out of FE also keeps the two degrees distinct.

**Established methods vs proposed delta.**
- **Established:** Litterman–Scheinkman, Ho's key-rate durations, Diebold–Li, and the GSW and Liu–Wu curves.
- **Delta:** whether the hedge choice for a bank-style book is sensitive to the curve smoother, under assumed costs. This is an empirical question, not claimed novel; the literature on curve-fitting error needs a search.

**Pilot.**
- **Known truth:** simulate a 4-factor Gaussian curve (3 strong factors, 1 weak) plus maturity-specific noise. Fit both smoothers and check whether the oracle hedge ranking is recovered.
- **Real data:** GSW from 1990 onward, monthly (about 400 months).
- **Precision:** test paired loss differences with Newey–West or block-bootstrap CIs.
  - Pre-declare an equivalence margin of ±10% in residual SD; "indistinguishable" is a reportable result.
  - No 99% ES from monthly data.

**Milestones (the +1-year phase, starting after the math submission):**
- **Q1:** data and vintage log; replicate PCA and Diebold–Li.
- **Q2:** hedge engine and known-truth runs.
- **Q3:** second curve, costs and IRRBB shocks.
- **Q4:** report, code release, presentation.

**690 fit (conditional).**
- A group of up to three splits naturally: curves and data; hedge and P&L engine; known-truth runs, stress tests and report.
- Solo variant: one book, GSW plus one alternative curve.
- The repository, report and presentation map directly onto the 690 deliverables.

**692 adaptation.** A critical review of the literature on hedging and curve construction, with a bounded GSW replication as supporting evidence and no new empirical claim.

**FE backup.** Discrete delta-hedging of a hypothetical short 30-day ATM SPX put under misspecified volatility.
- Framed as replication and stress analysis relative to Fukasawa, not a new principle.
- Gated on finding an SPX history source with usable terms.
- Caveat: pricing at VIX ignores skew.

## Skills that transfer, without reusing conclusions

**What transfers:** designing known-truth simulations, accounting for Monte Carlo precision, freezing decisions before evaluation, and reporting how results depend on assumptions.

**What stays separate:**
- No martingale certification appears in the FE project, and no yield curve appears in the math thesis.
- Repositories, figures and manuscripts are separate.
- Reviewer sensitivity (math) and smoother model risk (FE) are analogous ideas. They must not be presented as one contribution.

## Facts that still matter

- **Advisor:**
  - Does a synthetic-label application satisfy the "application" requirement? If not, swap to the math backup.
  - Is synthesis plus a bounded specialization an acceptable contribution level?
  - Is the student comfortable with martingale arguments?
- **User:**
  - Realistically 6 or 12 months? That decides whether T3 gets proved.
  - Does any employer policy limit publishing IAM-audit research, even on public data? No identifiers are needed to answer this.
  - Python or R?
- **WQU:**
  - Which capstone and track: 690 or 692?
  - Will there be a team, and who?
  - When does the capstone start relative to the math defense?
