# Privacy Attacks on ML

This is your thesis direction. Read every paper here carefully — not just for understanding but to find the gap you'll fill with IAM/behavioral data.

## Reading order

| # | File | What it covers | Time |
|---|---|---|---|
| 1 | membership_inference_shokri_2017.pdf | The original MIA. Shadow model approach: train N models on subsets → train meta-classifier. | 2 hrs |
| 2 | model_inversion_fredrikson_2015.pdf | Original model inversion. Gradient ascent on input space to recover training data features. Uses pharmacogenetics + face recognition as domains. | 2 hrs |
| 3 | kedmi_model_inversion_2021.pdf | Knowledge-Enriched Distributional Model Inversion. Uses a GAN — much more powerful than gradient-only inversion. | 3 hrs |
| 4 | extracting_training_data_carlini_2021.pdf | Shows LLMs memorize and regurgitate verbatim training data. Foundational for LLM privacy. | 2 hrs |
| 5 | lira_carlini_2022.pdf | LiRA: state-of-the-art MIA. Frames it as a likelihood ratio hypothesis test. More rigorous than shadow models. | 3 hrs |

## Key concepts

**Membership inference:** Does the model's output distribution differ for training vs. non-training samples?
- Shadow model approach (Shokri): train many shadow models → learn the difference empirically
- LiRA (Carlini): compute likelihood ratio P(model trained with x) / P(model trained without x) — more principled

**Model inversion:** Given model f and target class y, find input x* that maximizes f(x*) = y.
- Gradient-based (Fredrikson): x* = argmax_x f_y(x) via gradient ascent
- GAN-based (KEDMI): train a GAN generator constrained to match model output

**Why IAM data is novel:** Every published attack targets image classifiers (CIFAR, CelebA, ImageNet). Nobody has applied MIA + model inversion to tabular behavioral log data. That's your contribution.

## Your project: what the attack looks like on CERT data

```
Target model: anomaly detector trained on [logon, email, file, device] features
MIA question: Can I tell if user Alice was in the training set?
  → Matters because: confirms Alice was flagged as an insider threat
  → Privacy harm: exposes who was under surveillance

Model inversion question: Given the model, what behavioral profile does a "malicious insider" have?
  → Recovers: after-hours login ratio, USB frequency, large file transfer patterns
  → Privacy harm: exposes the detection logic, allows evasion
```

## Key metric to report

| Attack | Metric | Baseline | Target |
|---|---|---|---|
| MIA (LiRA) | Attack AUC | 0.50 (random) | > 0.65 = meaningful leakage |
| Model inversion | Feature reconstruction MSE | — | Compare to random baseline |
