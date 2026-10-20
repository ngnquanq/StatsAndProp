# Round 4 (Claude): evidence audit

I read `literature-check.md` (including the late round-3 section), `claude-round-3.md`, `codex-round-3.md`, `context.md` and `session-manifest.md`. I edited nothing and used no subagents. Tags: **[SRC]** means the coordinator checked the abstract. **[LIT]** means recalled and unchecked. **[HYP]** means hypothesis. Nothing here claims novelty.

## Ranking update

1. **I take back my round-3 argument for Pilot B.** I said overlap alone was textbook and that the real question was direct versus √h-scaled estimation. DNB WP 494 already compares scaling with overlapping-data estimation uncertainty [SRC]. Pitera–Schmidt–Stettner covers small-sample scaling for VaR/ES [SRC]. Gaspar may cover Gaussian overlap simulation, but we have only a search snippet. My "finite-sample reliability map" is therefore probably already done. **ES drops from contribution candidate to replication pilot.**
2. **Mortgage stays first on ceiling, but only by default.** Its literature has had less checking than ES, not been shown clear. A weaker ES does not make mortgage stronger.
3. **The monitoring reserve also has a likely close neighbor:** e-backtesting (Wang–Wang–Ziegel) [LIT]. It stays a reserve and needs checking.

## Two final tracks

**Track 1: replicate ES overlap and scaling (a learning pilot).**
- Reproduce one pre-chosen table or figure from DNB 494 or Pitera et al., but only after reading the full text.
- Use the iid Gaussian arm with analytic ES as the code check.
- Outputs: a simulation harness, Monte Carlo SE discipline, and a log of any discrepancies with the papers.
- No novelty is needed. A faithful replication, or a documented failure to replicate, counts as success.

**Track 2: immature mortgage cohorts (a scoping pilot; possible thesis only after the gates).**
- This is not automatically novel:
  - Chain-ladder and IBNR reserving is projecting immature cohorts.
  - Vintage analysis is standard IFRS 9/CECL practice.
  - Competing-risk mortgage default and prepayment models are long established [LIT].
  - Sensitivity and partial-identification frameworks for transport exist [LIT].
  - Truncating a cohort and comparing it with its matured outcome is a standard retrospective backtest.
- Freddie Mac data is widely used, and access is still unconfirmed.
- Learning step: reproduce Aalen–Johansen cumulative incidence and a chain-ladder-style projection on a permitted sample.

**Neither track may claim a contribution from:** a new dataset, extra failure mechanisms (GARCH, contamination, drift), or extra combinations of those.

## Contribution gates (revised after the coordinator's challenge)

I withdraw my round-3 go rule ("decision-loss difference greater than 2 Monte Carlo SE"). It confused being detectable with being important, and it treated a rigorous null as a failure.

- **G1, contribution.** Read at least three nearest papers in full, plus their references and the papers citing them. Verify the relevant claims. State one question they leave unanswered, in one sentence, and show why it matters for a decision. If no such question survives, the track stays a learning pilot. That is not a failure.
- **G2, validity.** The target is defined and the analytic or Gaussian check passes. For mortgage, the identifying or sensitivity assumption is written down before any results are seen.
- **G3, precision.** Before running, set a practical margin δ in decision units, for example budget breach as a percentage of B, or reserve error in basis points of balance. Every comparison is then reported in one of three classes:
  - the difference is larger than δ;
  - the difference is shown to lie within ±δ (an equivalence result, i.e. an informative null);
  - inconclusive: the interval crosses δ, so either add replications as pre-declared or report the precision limit.

  All three classes are results.
- **G4, practical informativeness.** The result either supports or limits a specific practice statement, such as "√h scaling is adequate within δ at 250-day windows." A baseline that works is logged as a finding, not hidden.
- **G5, advisor.** The advisor confirms that the stated question is at thesis level for the program.

All pre-declared cells are kept and reported, including nulls and baselines that work.

## Repo workflow

Keep the round-3 minimal artifacts, with these changes:
- `sources.csv`:
  - Add a `search-only` status below `abstract-checked`.
  - Gaspar is `search-only`.
  - DNB 494 and arXiv 2312.05655 are `abstract-checked`. Add a separate row for the 2026 journal version of 2312.05655.
- `research/decisions/2026-10-11-round4-es-demotion.md`: record the demotion and the reason for it.
- `research/candidates/contribution-matrix.md`: one row per neighbor, with what it answers, its assumptions, and the open question. Only `claim-verified` cells can support G1.
- `research/results/<pilot>/`: every pre-declared cell, with its G3 class.

No code beyond the replication until G1 is decided.

## Next week (12–18 Oct)

| Days | Work |
|---|---|
| Mon–Tue | Get full texts: DNB 494; Pitera et al. (arXiv and journal versions); Gaspar via the Emerald DOI or the author; e-backtesting. Trace references and citing papers. Start the mortgage reading: chain-ladder, IFRS 9 vintage, competing-risk mortgage. |
| Tue | Confirm Clarity registration and log its terms. |
| Wed | Pre-register the replication: the target table, δ, and the Monte Carlo budget. |
| Thu–Fri | Gaussian arm plus the replication, with Monte Carlo SE. |
| Sat | Fill the contribution matrix and log the G1 status for both tracks. |
| Sun | Advisor email: describe both tracks and ask directly, "Would a rigorous replication plus an informative null under declared margins be acceptable, or is an original methodological delta required?" |

**What could change this ranking:**
- If the Gaspar full text turns out narrower than the snippet suggests, part of the ES space may reopen. That would go through G1, not be assumed.
- If Clarity access fails, Track 2 becomes reading only.