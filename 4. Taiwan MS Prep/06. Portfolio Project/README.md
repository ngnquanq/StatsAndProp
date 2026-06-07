# Portfolio Project

**Title:** Privacy Attacks on Enterprise Access Control Models
**GitHub repo name:** `cert-privacy-attacks`
**Target completion:** October 2026 (before cold email)

---

## Dataset: CERT Insider Threat v6.2

**What it is:** Synthetic enterprise user activity logs from CMU SEI. Contains 5 CSV files simulating 1000 users over 18 months, with ~70 insider threat actors.

**How to get it:**
1. Go to: https://resources.sei.cmu.edu/library/asset-view.cfm?assetid=508099
2. Fill out the access request form (name, institution, intended use)
3. CMU usually approves within 1–3 business days
4. Download v6.2 (the most recent synthetic version)

**Files in the dataset:**
| File | Contents |
|---|---|
| logon.csv | Login/logout events with timestamp, PC, user |
| http.csv | Web browsing events |
| email.csv | Email send/receive events |
| file.csv | File access events |
| device.csv | USB plug/unplug events |
| LDAP/ | User metadata (department, role, manager) |

**Feature engineering (per user per day):**
```python
features = {
    'after_hours_logon_ratio': logons between 18:00–08:00 / total logons,
    'external_email_ratio': emails to external domains / total emails,
    'usb_event_count': count of device plug events,
    'large_file_transfers': file events with size > 1MB,
    'weekend_activity': activity on Sat/Sun (binary),
    'http_external_count': browsing to non-company domains,
}
label = 1 if user appears in insider threat scenario, else 0
```

---

## Repo Structure

```
cert-privacy-attacks/
├── README.md                    ← motivation, method, key results (what Chen reads)
├── requirements.txt
├── data/
│   ├── preprocess.py            ← raw CSVs → per-user-per-day feature matrix
│   └── dataset.py               ← PyTorch Dataset class
├── models/
│   ├── anomaly_detector.py      ← MLP + XGBoost baseline
│   └── train.py                 ← training loop with checkpoints
├── attacks/
│   ├── membership_inference.py  ← shadow model + LiRA implementation
│   └── model_inversion.py       ← gradient-based input optimization
├── defenses/
│   └── dp_training.py           ← Opacus DP-SGD wrapper
├── explainability/
│   └── shap_analysis.py         ← SHAP feature importance on attack surface
└── notebooks/
    └── results.ipynb            ← charts and tables for the README
```

---

## Python Environment

```txt
# requirements.txt
torch>=2.0.0
torchvision
opacus>=1.4.0
shap>=0.43.0
scikit-learn>=1.3.0
xgboost>=2.0.0
pandas>=2.0.0
numpy>=1.24.0
matplotlib>=3.7.0
wandb
```

Install: `pip install -r requirements.txt`

---

## Implementation Steps

### Week 1–2: Data + Baseline Model
```python
# preprocess.py — aggregate CSVs into feature matrix
df = pd.merge(logons, emails, on=['user', 'date'])
# ... engineer features per user per day
# train/test split: first 12 months train, last 6 months test

# anomaly_detector.py
class InsiderThreatDetector(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(6, 64), nn.ReLU(),
            nn.Linear(64, 32), nn.ReLU(),
            nn.Linear(32, 2)
        )
```

### Week 3: Membership Inference (Shadow Model)
```python
# membership_inference.py
# 1. Train N=64 shadow models on random 50% subsets
# 2. For each shadow model: label training samples as "in", test as "out"
# 3. Train meta-classifier (logistic regression) on (confidence_vector, in/out)
# 4. Evaluate on target model: attack_auc = roc_auc_score(true_labels, predicted_proba)
```

### Week 4: Model Inversion
```python
# model_inversion.py — gradient ascent on input space
x_inv = torch.randn(1, num_features, requires_grad=True)
optimizer = torch.optim.Adam([x_inv], lr=0.01)
for _ in range(1000):
    loss = -model(x_inv)[0, target_class]  # maximize target class confidence
    optimizer.zero_grad(); loss.backward(); optimizer.step()
# x_inv now approximates the "average malicious insider" feature profile
```

### Week 5: DP Defense
```python
# dp_training.py — 3 lines to add DP-SGD
from opacus import PrivacyEngine
privacy_engine = PrivacyEngine()
model, optimizer, train_loader = privacy_engine.make_private(
    module=model, optimizer=optimizer, data_loader=train_loader,
    noise_multiplier=1.1, max_grad_norm=1.0
)
# Then train normally — Opacus handles the rest
# Report: (epsilon, delta) privacy budget + attack AUC with/without DP
```

### Week 6: SHAP + README
```python
# shap_analysis.py
explainer = shap.TreeExplainer(xgb_model)  # or DeepExplainer for PyTorch
shap_values = explainer.shap_values(X_test)
# Key question: which features contribute most to high-confidence predictions?
# → These are the features most vulnerable to model inversion
```

---

## Key Results to Report in README

| Metric | Value |
|---|---|
| Baseline model AUC | (your result) |
| MIA attack AUC (no defense) | (your result) — should be > 0.60 |
| MIA attack AUC (DP-SGD, ε=2) | (your result) — should drop toward 0.50 |
| Model inversion MSE vs. random | (your result) |
| Top-3 vulnerable features (SHAP) | (your result) |

---

## Reference Implementations
- ML Privacy Meter: https://github.com/privacytrustlab/ml_privacy_meter — LiRA implementation
- Opacus tutorials: https://opacus.ai/tutorials/
- ART (attack implementations): https://github.com/Trusted-AI/adversarial-robustness-toolbox
