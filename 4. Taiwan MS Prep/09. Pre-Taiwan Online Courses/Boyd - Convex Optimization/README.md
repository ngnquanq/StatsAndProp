# Convex Optimization — Boyd & Vandenberghe (Stanford)
**Authors:** Stephen Boyd, Lieven Vandenberghe
**Free PDF:** https://web.stanford.edu/~boyd/cvxbook/
**Course (video):** https://www.youtube.com/playlist?list=PL3940DD956CDF0622

The standard graduate textbook for optimization. Freely available. Relevant because adversarial training, certified defenses, and privacy attacks all involve constrained optimization problems.

---

## File downloaded

| File | Contents |
|---|---|
| convex_optimization_boyd_vandenberghe.pdf | Full textbook (~700 pages) |

---

## What to actually read (not the whole book)

| Chapter | Topic | Why it matters |
|---|---|---|
| Ch 1 | Introduction — what is convex optimization? | 30 min orientation |
| Ch 2 | Convex sets | Foundation for understanding Lp ball threat models |
| Ch 3 | Convex functions | Foundation for loss function analysis |
| Ch 4 | Convex optimization problems | PGD is projection onto a convex set |
| Ch 5 | Duality (Lagrangian) | SVM dual, adversarial training Lagrangian |
| Ch 9 | Unconstrained minimization | Gradient descent convergence proofs |

**Skip:** Ch 6 (approximation), Ch 7 (statistical estimation), Ch 10–11 (interior point methods) — too specialized.

---

## Connection to your direction

| Your work | Optimization concept |
|---|---|
| PGD attack | Projected gradient descent onto L∞ ball |
| TRADES loss | Minimax optimization (inner max = PGD, outer min = model weights) |
| Randomized smoothing certification | Convex relaxation of the certified radius |
| DP-SGD | Constrained optimization with privacy budget |
| LiRA membership inference | Maximum likelihood / hypothesis testing |
