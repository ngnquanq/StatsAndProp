# Textbooks

Three free, legally available textbooks that cover the mathematical and engineering foundations for Chen's lab.

---

## Files

### mathematics_for_machine_learning_deisenroth.pdf
**Authors:** Marc Peter Deisenroth, A. Aldo Faisal, Cheng Soon Ong (Cambridge University Press)
**Free at:** https://mml-book.github.io/

The best single book for the math you need. Unlike most ML textbooks that assume the math, this *teaches* the math in the context of ML.

**Read these chapters (before adversarial ML papers):**

| Chapter | Topic | Why |
|---|---|---|
| Ch 2 | Linear Algebra | Matrix operations, eigendecomposition — needed for understanding model weights |
| Ch 3 | Analytic Geometry | Vector spaces, orthogonality — needed for Lp ball geometry |
| Ch 4 | Matrix Decompositions | SVD, PCA — needed for understanding model structure |
| Ch 5 | Vector Calculus | Gradients, Jacobians, chain rule — needed for backprop and attacks |
| Ch 6 | Probability & Distributions | Foundation for everything probabilistic |
| Ch 7 | Continuous Optimization | Gradient descent, convexity — needed for adversarial training |

---

### dive_into_deep_learning_d2l.pdf
**Authors:** Aston Zhang, Zachary Lipton, Mu Li, Alexander Smola (Amazon team)
**Free at:** https://d2l.ai/

Code-first deep learning textbook with PyTorch implementations of everything. More practical than Goodfellow's DL book.

**Most useful chapters:**

| Chapter | Topic |
|---|---|
| Ch 3–4 | Linear/MLP from scratch in PyTorch |
| Ch 6–7 | CNNs, ResNet |
| Ch 9–11 | RNNs, attention, transformers |
| Ch 13 | Computer vision (transfer learning) |
| Ch 15 | Natural language processing |

Use this alongside `08. NTU Courses/DL - Deep Learning Algorithms/` — similar content but with runnable code.

---

### algorithmic_foundations_dp_dwork_roth.pdf
**Authors:** Cynthia Dwork, Aaron Roth
**Free at:** https://www.cis.upenn.edu/~aaroth/Papers/privacybook.pdf

*The* reference for differential privacy theory. Cynthia Dwork invented DP. This is her textbook.

**Read these sections:**

| Section | Topic | Why |
|---|---|---|
| Ch 1–2 | The Definition of Differential Privacy | Formal ε-δ DP definition — needed to understand Opacus |
| Ch 3 | Basic Techniques (Laplace, Gaussian mechanisms) | Noise calibration in DP-SGD |
| Ch 5 | Composition Theorems | Why DP budget accumulates across training steps |

**Don't read:** Ch 6+ (advanced algorithmic topics, not needed for ML privacy work)

---

## What's NOT here (by choice)

**Goodfellow, Bengio, Courville — Deep Learning:** The HTML version at deeplearningbook.org is free but PDF requires purchase. D2l.ai covers the same ground with better code examples. Skip it.

**Cover & Thomas — Elements of Information Theory:** Copyrighted, no free PDF. Read Ch 1–2 as lecture notes instead — search "CMU 15-859 information theory lecture notes" or "Stanford EE376A notes."
