# What Class of Problem is SPML?

## The analogy to regression

**Regression objective** — minimize expected loss over the data distribution:

$$\min_\theta \; \mathbb{E}_{(x,y) \sim P} \left[ \mathcal{L}(f_\theta(x),\, y) \right]$$

The "opponent" is randomness. You optimize against typical data drawn from $P$.

---

**SPML objective** — minimize worst-case loss over all adversary moves within a budget:

$$\min_\theta \; \max_{\delta \in \mathcal{S}} \; \mathcal{L}(f_\theta(x + \delta),\, y)$$

The opponent is a **strategic adversary** who actively tries to maximize your loss.
$\mathcal{S}$ is the constraint set — the adversary's budget (e.g., $\|\delta\|_p \leq \varepsilon$).

---

## What changes

| | Regression | SPML |
|---|---|---|
| Opponent | Random data from $P$ | Strategic adversary |
| Objective | Minimize $\mathbb{E}[\mathcal{L}]$ | Minimize $\max_{\delta \in \mathcal{S}} \mathcal{L}$ |
| Performance metric | RMSE, MAE | Robust accuracy, certified radius, MI advantage |
| "Good enough" | Low test error | No adversary within budget $\mathcal{S}$ can cause failure |

---

## The three instantiations in Chen's lab

All three are the same class — a **min-max game** between two players with opposing objectives.

### 1. Robustness (ASDR, BRONet, Quasiconcave)

$$\min_\theta \; \mathbb{E}_{(x,y)} \left[ \max_{\|\delta\|_p \leq \varepsilon} \mathcal{L}(f_\theta(x+\delta),\, y) \right]$$

Attacker perturbs input $x$ by at most $\varepsilon$ in $L_p$ norm.
Defender must classify correctly for **every** $\delta$ in that ball.

The certified radius $r$ is the largest $\varepsilon$ for which the defender can provably guarantee correctness:

$$r = \arg\max \; \{ \varepsilon : \forall \|\delta\|_2 \leq \varepsilon, \; f_\theta(x+\delta) = y \}$$

Chen's work (BRONet, Quasiconcave) tries to make $r$ as large as possible without sacrificing clean accuracy.

---

### 2. Membership Inference (Trap-MID)

Attacker observes model outputs and tries to determine whether a specific point $z$ was in the training set $D$:

$$\max_{\mathcal{A}} \; \Pr[\mathcal{A}(f_\theta, z) = \mathbf{1}[z \in D]]$$

Performance is measured by **MI advantage**:

$$\text{Adv} = \Pr[\mathcal{A} \text{ correct}] - 0.5$$

An advantage of 0 means the attacker does no better than random guessing — perfect privacy.
Trap-MID's goal: keep $\text{Adv} \approx 0$ while keeping model accuracy high.

---

### 3. Model Inversion (DRAG, Trap-MID as defense)

Attacker has query/gradient access to $f_\theta$ and tries to reconstruct a training sample $x^*$:

$$\hat{x} = \arg\min_{x} \; d(f_\theta(x),\, f_\theta(x^*))$$

where $d$ is some distance in output space (logit distance, feature distance).

DRAG improves this attack by using a diffusion model as a learned prior:

$$\hat{x} = \arg\min_{x} \; d(f_\theta(x),\, f_\theta(x^*)) + \lambda \cdot \mathcal{E}_{\text{diffusion}}(x)$$

The diffusion term $\mathcal{E}_{\text{diffusion}}(x)$ constrains $\hat{x}$ to lie on the natural image manifold,
which is why DRAG reconstructions are sharper than GAN-based methods (KEDMI).

---

## Chen's unifying research question

> Can we achieve the defender's security guarantee without paying the usual utility cost?

Every paper in his lab is asking: is there a smarter mechanism than brute force?

| Brute force defense | Cost | Chen's smarter alternative | Cost |
|---|---|---|---|
| DP-SGD (add noise to gradients) | −5–15% accuracy | Trap-MID (plant trap samples) | ~0% accuracy loss |
| Adversarial training alone | −5–10% clean accuracy | ASDR (self-distillation to fix boundary) | Smaller drop |
| Loose randomized smoothing | Small certified radius | BRONet (orthogonal weights tighten the bound) | Better radius |

This is the intellectual pattern. When you read a new paper, ask:
**what is the brute force defense, what does it cost, and what is this paper's smarter alternative?**
