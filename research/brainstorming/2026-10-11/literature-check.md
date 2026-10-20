# Targeted literature check by coordinator

Checked official abstracts on 2026-10-11; this is a targeted check, not a systematic review.

- Sun and Cheng, *Bootstrapping the Expected Shortfall* (2018): blocking bootstrap theory for stationary processes under strong mixing is already established. https://research.wright.edu/en/publications/bootstrapping-the-expected-shortfall/
- Heinemann and Telg, *A Residual Bootstrap for Conditional Expected Shortfall* (2018): a fixed-design residual bootstrap for a two-step conditional ES estimator, asymptotic validity under stated volatility-model conditions, and simulation coverage comparisons. https://arxiv.org/abs/1811.11557
- Bartl and Eckstein, *Optimal Nonparametric Estimation of the Expected Shortfall Risk*: robust finite-sample estimation under iid data, including heavy tails and adversarial contamination. The abstract explicitly specifies iid observations. https://epubs.siam.org/doi/10.1137/24M1704518

Implications for brainstorming: dependence-aware bootstrap and robust ES estimation are not themselves novel. Distinguish unconditional marginal ES from time-varying conditional ES. An iid robustness result does not establish validity under dependence. A promising extension must be reviewed against neighboring literature and supported by a precisely defined target and decision loss. Do not label a conjunction of heavy tails, dependence, contamination, and drift as a contribution merely because it adds complexity.

## Checks relevant to fresh alternatives

- *Noise-Aware Statistical Inference with Differentially Private Synthetic Data* already addresses inference from DP synthetic data; preservation of confidence intervals is not by itself a new topic. https://arxiv.org/abs/2205.14485
- Freddie Mac's old download page announces that the loan-level dataset moved to Clarity. Access is an unresolved prerequisite; do not assume the data has been obtained. https://freddiemac.embs.com/FLoan/menu.php

Coordinator critique: mortgage threshold RD has a particularly important identification gate. Bunching, rounding, acquisition selection, and simultaneous policy changes can defeat a simple treatment interpretation. A density test or donut exclusion alone does not restore identification. Bid-ask perturbations alone do not define a repeated-sampling bootstrap. Synthetic-data coefficient coverage requires a population or simulation target and uncertainty over original sampling and release generation, not merely agreement with one original fitted coefficient.

## Late round-3 evidence: closer ES overlap/scaling neighbors

- Danielsson et al., *Why risk is so hard to measure*, DNB working paper 494 (2016): official abstract explicitly compares risk estimation uncertainty and longer-horizon time scaling with overlapping-data estimation. This is much closer than generic bootstrap theory. https://www.dnb.nl/publicaties/publicaties-onderzoek/working-paper-2016/494-why-risk-is-so-hard-to-measure/
- Pitera, Schmidt, Stettner, *A novel scaling approach for unbiased adjustment of risk estimators*, arXiv 2312.05655: official abstract discusses conservative reserve estimation, small samples, time scaling beyond the square-root rule, and VaR/ES examples. A 2026 journal result was discovered, but only the arXiv abstract was opened. https://arxiv.org/abs/2312.05655
- Search-only lead, not a full-text verification: Gaspar, *Finite Samples, Overlapping Returns, and the Illusion of Precision in Risk Management*, SSRN 6094327 / DOI 10.1108/JRF-02-2026-0104. The search result describes controlled geometric-Brownian-motion simulations and overlap effects on tail-risk estimation; SSRN fetch returned 403. https://papers.ssrn.com/sol3/papers.cfm?abstract_id=6094327

Consequence: both Gaussian overlap and scaling-versus-direct formulations have very close existing neighbors. ES should now be a literature-replication gate or conditional fallback, not a default novel thesis commitment. Full papers and reference chains are needed before specifying an incremental contribution. This new evidence does not automatically establish novelty of the mortgage candidate.
