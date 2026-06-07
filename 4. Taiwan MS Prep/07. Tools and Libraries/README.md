# Tools and Libraries

Everything you need installed for the portfolio project and Chen's lab work.

---

## Install all at once

```bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
pip install opacus shap scikit-learn xgboost pandas numpy matplotlib
pip install adversarial-robustness-toolbox[pytorch]
pip install robustbench
pip install privacy-meter
pip install wandb
```

---

## Tool Reference

### PyTorch
- **What:** Core deep learning framework. Everything in Chen's lab uses this.
- **Docs:** https://pytorch.org/docs/stable/
- **Key tutorials:**
  - https://pytorch.org/tutorials/beginner/basics/intro.html (start here)
  - https://pytorch.org/tutorials/beginner/blitz/cifar10_tutorial.html (CIFAR-10 training loop)

### Opacus (Differential Privacy)
- **What:** Facebook's DP-SGD library. Wraps PyTorch optimizers to add calibrated noise.
- **Install:** `pip install opacus`
- **Docs:** https://opacus.ai/
- **Key concept:** `make_private(module, optimizer, data_loader, noise_multiplier, max_grad_norm)`
- **Quick start:** https://opacus.ai/tutorials/

### SHAP
- **What:** SHapley Additive exPlanations. You already know this.
- **Install:** `pip install shap`
- **Docs:** https://shap.readthedocs.io/
- **For tabular models:** `shap.TreeExplainer` (XGBoost) or `shap.DeepExplainer` (PyTorch)

### ML Privacy Meter
- **What:** LiRA implementation + privacy auditing toolkit (Carlini et al.)
- **Install:** `pip install privacy-meter`
- **GitHub:** https://github.com/privacytrustlab/ml_privacy_meter
- **Use for:** Running LiRA membership inference attack on your trained model

### Adversarial Robustness Toolbox (ART)
- **What:** IBM's library with 40+ attack implementations (FGSM, PGD, CW, etc.)
- **Install:** `pip install adversarial-robustness-toolbox[pytorch]`
- **GitHub:** https://github.com/Trusted-AI/adversarial-robustness-toolbox
- **Use for:** Reference implementations to verify your own FGSM/PGD code

### RobustBench
- **What:** Standardized benchmark for adversarial robustness. Leaderboard of all defenses.
- **Install:** `pip install robustbench`
- **Website:** https://robustbench.github.io/
- **Use for:** Compare your model's clean/robust accuracy against published baselines

### WandB (Weights & Biases)
- **What:** Experiment tracking. Logs training curves, hyperparameters, artifacts.
- **Install:** `pip install wandb`
- **Docs:** https://docs.wandb.ai/
- **Setup:** `wandb login` then add 3 lines to your training loop
- **Why:** Chen's lab uses this (standard in ML research). Shows up in your GitHub commits.

---

## GPU Setup (Google Colab — free option)

If you don't have a local GPU:
1. Go to https://colab.research.google.com
2. Runtime → Change runtime type → GPU (T4)
3. Mount Google Drive to persist checkpoints
4. Free tier gives ~12 hrs/day GPU time — enough for CERT experiments

For longer runs: use Kaggle notebooks (also free, 30 hrs/week GPU).
