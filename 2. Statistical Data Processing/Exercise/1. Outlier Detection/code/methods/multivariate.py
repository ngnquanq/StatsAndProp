"""Hai phương pháp phát hiện ngoại lai đa biến tuyến tính."""

from __future__ import annotations

import numpy as np
from scipy import stats


def mahalanobis(
    X: np.ndarray, alpha: float = 0.05
) -> tuple[np.ndarray, np.ndarray]:
    """Khoảng cách Mahalanobis cổ điển.

    Score = D^2; ngưỡng = phân vị (1-α) của χ²(p).
    """
    p = X.shape[1]
    mu = X.mean(axis=0)
    S = np.cov(X, rowvar=False, ddof=1)
    S_inv = np.linalg.pinv(S)
    diff = X - mu
    d2 = np.einsum("ni,ij,nj->n", diff, S_inv, diff)
    crit = stats.chi2.ppf(1 - alpha, df=p)
    pred = (d2 > crit).astype(int)
    return pred, d2


def _q_critical(eigvals_residual: np.ndarray, alpha: float) -> float:
    """Ngưỡng Q theo công thức Jackson--Mudholkar (1979)."""
    theta1 = float(np.sum(eigvals_residual))
    theta2 = float(np.sum(eigvals_residual**2))
    theta3 = float(np.sum(eigvals_residual**3))
    if theta1 == 0:
        return np.inf
    h0 = 1 - 2 * theta1 * theta3 / (3 * theta2**2) if theta2 > 0 else 1.0
    if h0 == 0:
        h0 = 1e-6
    c_alpha = stats.norm.ppf(1 - alpha)
    term1 = c_alpha * np.sqrt(2 * theta2 * h0**2) / theta1
    term2 = theta2 * h0 * (h0 - 1) / (theta1**2)
    return theta1 * (term1 + 1 + term2) ** (1 / h0)


def pca_t2_q(
    X: np.ndarray, var_ratio: float = 0.95, alpha: float = 0.05
) -> tuple[np.ndarray, np.ndarray, dict]:
    """T² và Q (SPE) theo PCA. Một quan sát là ngoại lai nếu T² hoặc Q vượt
    ngưỡng. Score xuất ra là max thống kê được chuẩn hóa về [0, 1]."""
    n, p = X.shape
    mu = X.mean(axis=0)
    Xc = X - mu
    # SVD trên dữ liệu đã căn (tương đương EVD trên (n-1)*S)
    U, sv, Vt = np.linalg.svd(Xc, full_matrices=False)
    eigvals = sv**2 / (n - 1)
    cum_ratio = np.cumsum(eigvals) / np.sum(eigvals)
    k = int(np.searchsorted(cum_ratio, var_ratio) + 1)
    k = max(1, min(k, p - 1))  # giữ ít nhất 1 PC residual
    P_k = Vt[:k].T  # (p, k)
    Lambda_k = eigvals[:k]

    scores = Xc @ P_k  # (n, k)
    t2 = np.sum(scores**2 / Lambda_k, axis=1)

    recon = scores @ P_k.T
    residual = Xc - recon
    q = np.sum(residual**2, axis=1)

    t2_crit = (
        k * (n - 1) * (n + 1) / (n * (n - k)) * stats.f.ppf(1 - alpha, k, n - k)
    )
    q_crit = _q_critical(eigvals[k:], alpha)

    pred = ((t2 > t2_crit) | (q > q_crit)).astype(int)

    # Hợp nhất hai thống kê thành một score liên tục bằng cách lấy
    # max(tỉ số/ngưỡng) — tương đương với lựa chọn or-rule.
    score = np.maximum(t2 / max(t2_crit, 1e-12), q / max(q_crit, 1e-12))
    info = {
        "k": k,
        "t2": t2,
        "q": q,
        "t2_crit": t2_crit,
        "q_crit": q_crit,
        "var_explained": float(cum_ratio[k - 1]),
    }
    return pred, score, info


__all__ = ["mahalanobis", "pca_t2_q"]
