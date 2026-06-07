# Adversarial ML

Core adversarial attack and defense papers. This is Chen's foundational area — you need to speak this language fluently in a meeting with him, even though your thesis will focus on privacy attacks.

## Reading order

Read in this exact order. Each paper builds on the previous.

| # | File | What it covers | Time |
|---|---|---|---|
| 1 | fgsm_goodfellow_2015.pdf | The first practical attack. Single gradient step. Introduces the threat model (Lp norm). | 1 hr |
| 2 | pgd_madry_2018.pdf | Extends FGSM to multi-step. Defines the standard PGD attack. Still the benchmark. | 2 hrs |
| 3 | obfuscated_gradients_athalye_2018.pdf | Shows most early defenses were broken because they obscured gradients. Critical for understanding what a real defense must do. | 2 hrs |
| 4 | cw_attack_2017.pdf | The C&W attack — more powerful than PGD, used to break certified defenses. | 2 hrs |
| 5 | trades_zhang_2019.pdf | The training loss Chen's lab builds on. Formalizes robustness-accuracy tradeoff. Read sections 1–4 carefully. | 3 hrs |
| 6 | randomized_smoothing_cohen_2019.pdf | The main certified defense. Adds Gaussian noise → certifies a radius. Foundation for Chen's AAAI 2024 and ICML 2025 papers. | 3 hrs |
| 7 | autoattack_croce_2020.pdf | The standard evaluation benchmark. If your defense doesn't survive AutoAttack it doesn't count. | 1 hr |
| 8 | adv_examples_features_ilyas_2019.pdf | Theoretical argument: adversarial examples exist because non-robust features are predictive. Changes how you think about the problem. | 2 hrs |

## Key takeaways

- **Threat model:** always defined as Lp ball of radius ε around input x. L∞ is most common.
- **Standard evaluation:** accuracy on clean examples + robust accuracy under AutoAttack at ε=8/255 (CIFAR-10)
- **The core tension:** adversarial training improves robustness but hurts clean accuracy. TRADES quantifies this via a hyperparameter β.
- **Certified vs empirical robustness:** randomized smoothing gives a *provable* guarantee; PGD-AT only gives empirical evidence.

## What to implement (for portfolio fluency)

```python
# FGSM — 10 lines
delta = epsilon * x.grad.sign()

# PGD — 20 lines, loop of FGSM steps with projection
for _ in range(num_steps):
    loss.backward()
    delta = (delta + alpha * x.grad.sign()).clamp(-epsilon, epsilon)
```

Do this on CIFAR-10. You don't need perfect results — you need to have run it.
