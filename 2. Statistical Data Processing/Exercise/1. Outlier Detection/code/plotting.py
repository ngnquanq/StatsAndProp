"""Sinh hình minh họa cho từng phương pháp + bảng so sánh F1.

Lưu PDF vào ../figs/ để XeLaTeX dùng (graphicspath đã trỏ tới đó).
"""

from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

from evaluate import METHOD_LABELS, METHOD_ORDER, Result

FIGS_DIR = Path(__file__).resolve().parents[1] / "figs"
FIGS_DIR.mkdir(exist_ok=True)

# Tone trung tính, in đẹp đen-trắng
plt.rcParams.update(
    {
        "figure.dpi": 120,
        "savefig.bbox": "tight",
        "font.size": 10,
        "axes.titlesize": 11,
        "axes.labelsize": 10,
        # Ổn định bit-level cho PDF (gỡ timestamp trong metadata).
        "pdf.compression": 9,
    }
)

# Metadata cố định để md5(PDF) tái lập giữa các lần chạy
PDF_METADATA = {
    "CreationDate": None,
    "ModDate": None,
    "Producer": "matplotlib",
    "Creator": "matplotlib",
}


def _save(fig, path):
    fig.savefig(path, metadata=PDF_METADATA)

INLIER_KW = dict(s=18, c="#5b8def", alpha=0.55, edgecolor="none", label="Bình thường")
OUTLIER_TRUE_KW = dict(s=55, c="#222222", marker="x", linewidths=1.4, label="Ngoại lai thực")
PRED_RING_KW = dict(s=120, facecolor="none", edgecolor="#d62728", linewidth=1.4, label="Dự đoán ngoại lai")


# ---------------------------------------------------------------- overview
def dataset_overview(data: dict, path: Path = FIGS_DIR / "dataset_overview.pdf") -> Path:
    fig, axes = plt.subplots(1, 3, figsize=(11, 3.4))

    # UD: histogram + rug
    ax = axes[0]
    x = data["ud_x"]
    y = data["ud_y"]
    ax.hist(x[y == 0], bins=30, color="#5b8def", alpha=0.7, label="Bình thường")
    ax.hist(x[y == 1], bins=12, color="#d62728", alpha=0.85, label="Ngoại lai")
    ax.set_title("UD — đơn biến (n=210)")
    ax.set_xlabel("x")
    ax.set_ylabel("Tần suất")
    ax.legend(loc="upper right", fontsize=8)

    # MD2 và MD-NL: scatter
    for ax, key, title in [
        (axes[1], "md2", "MD2 — Gaussian 2D (n=215)"),
        (axes[2], "mdnl", "MD-NL — phi tuyến (n=315)"),
    ]:
        X = data[f"{key}_x"]
        y = data[f"{key}_y"]
        ax.scatter(X[y == 0, 0], X[y == 0, 1], **INLIER_KW)
        ax.scatter(X[y == 1, 0], X[y == 1, 1], **OUTLIER_TRUE_KW)
        ax.set_title(title)
        ax.set_xlabel(r"$x_1$")
        ax.set_ylabel(r"$x_2$")
        ax.legend(loc="best", fontsize=8)
        ax.set_aspect("equal", adjustable="datalim")

    fig.tight_layout()
    _save(fig, path)
    plt.close(fig)
    return path


# ---------------------------------------------------------------- univariate
def plot_univariate_method(
    method_key: str,
    x: np.ndarray,
    y_true: np.ndarray,
    pred: np.ndarray,
    path: Path,
    title_extra: str = "",
) -> Path:
    fig, ax = plt.subplots(figsize=(6.2, 2.6))
    inlier_mask = y_true == 0
    outlier_mask = y_true == 1
    pred_mask = pred == 1

    # Trục x cố định, trục y giả lập jitter để dễ nhìn
    rng = np.random.default_rng(0)
    jitter = rng.uniform(-1, 1, size=x.size) * 0.3

    ax.scatter(x[inlier_mask], jitter[inlier_mask], **INLIER_KW)
    ax.scatter(x[outlier_mask], jitter[outlier_mask], **OUTLIER_TRUE_KW)
    if pred_mask.any():
        ax.scatter(x[pred_mask], jitter[pred_mask], **PRED_RING_KW)
    ax.set_yticks([])
    ax.set_xlabel("x")
    title = METHOD_LABELS[method_key]
    if title_extra:
        title = f"{title} — {title_extra}"
    ax.set_title(title)
    ax.legend(loc="upper center", fontsize=8, ncol=3, frameon=False)
    fig.tight_layout()
    _save(fig, path)
    plt.close(fig)
    return path


# ---------------------------------------------------------------- 2D scatter
def plot_2d_method(
    method_key: str,
    X: np.ndarray,
    y_true: np.ndarray,
    pred: np.ndarray,
    path: Path,
    title_extra: str = "",
) -> Path:
    fig, ax = plt.subplots(figsize=(4.6, 4.0))
    inlier_mask = y_true == 0
    outlier_mask = y_true == 1
    pred_mask = pred == 1
    ax.scatter(X[inlier_mask, 0], X[inlier_mask, 1], **INLIER_KW)
    ax.scatter(X[outlier_mask, 0], X[outlier_mask, 1], **OUTLIER_TRUE_KW)
    if pred_mask.any():
        ax.scatter(X[pred_mask, 0], X[pred_mask, 1], **PRED_RING_KW)
    ax.set_xlabel(r"$x_1$")
    ax.set_ylabel(r"$x_2$")
    title = METHOD_LABELS[method_key]
    if title_extra:
        title = f"{title} — {title_extra}"
    ax.set_title(title)
    ax.legend(loc="best", fontsize=8, frameon=True)
    ax.set_aspect("equal", adjustable="datalim")
    fig.tight_layout()
    _save(fig, path)
    plt.close(fig)
    return path


# ---------------------------------------------------------------- comparison
def score_comparison(results: list[Result], path: Path = FIGS_DIR / "score_comparison.pdf") -> Path:
    by_key = {r.method: r for r in results}
    methods = [m for m in METHOD_ORDER if m in by_key]
    f1 = [by_key[m].f1 for m in methods]
    auc = [by_key[m].auc if by_key[m].auc is not None else 0.0 for m in methods]
    labels = [METHOD_LABELS[m] for m in methods]

    x = np.arange(len(methods))
    width = 0.4
    fig, ax = plt.subplots(figsize=(8.5, 3.6))
    ax.bar(x - width / 2, f1, width, label="F1", color="#5b8def")
    ax.bar(x + width / 2, auc, width, label="ROC-AUC", color="#d62728")
    ax.set_xticks(x)
    ax.set_xticklabels(labels, rotation=30, ha="right")
    ax.set_ylim(0, 1.05)
    ax.set_ylabel("Điểm số")
    ax.set_title("So sánh F1 và ROC-AUC của 11 phương pháp")
    ax.grid(axis="y", linestyle=":", linewidth=0.5)
    ax.legend(loc="lower left")
    fig.tight_layout()
    _save(fig, path)
    plt.close(fig)
    return path


__all__ = [
    "FIGS_DIR",
    "dataset_overview",
    "plot_univariate_method",
    "plot_2d_method",
    "score_comparison",
]
