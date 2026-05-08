"""Bốn phương pháp phát hiện ngoại lai đơn biến.

Mỗi hàm nhận `x: np.ndarray` (1D) và trả về `(pred, score)`:
- `pred`: vector 0/1 cùng kích thước, 1 = ngoại lai.
- `score`: vector float; giá trị càng lớn càng đáng nghi ngoại lai.
  Dùng cho ROC-AUC.
"""

from __future__ import annotations

import numpy as np
from scipy import stats


def zscore(x: np.ndarray, tau: float = 3.0) -> tuple[np.ndarray, np.ndarray]:
    mean = float(np.mean(x))
    std = float(np.std(x, ddof=1))
    score = np.abs((x - mean) / std)
    pred = (score > tau).astype(int)
    return pred, score


def modified_zscore(x: np.ndarray, tau: float = 3.5) -> tuple[np.ndarray, np.ndarray]:
    median = float(np.median(x))
    mad = float(np.median(np.abs(x - median)))
    if mad == 0.0:
        # Trường hợp suy biến — fallback về độ lệch tuyệt đối trung bình
        mad = float(np.mean(np.abs(x - median))) or 1.0
    score = np.abs(0.6745 * (x - median) / mad)
    pred = (score > tau).astype(int)
    return pred, score


def iqr(x: np.ndarray, k: float = 1.5) -> tuple[np.ndarray, np.ndarray]:
    q1, q3 = np.percentile(x, [25, 75])
    iqr_value = q3 - q1
    lower = q1 - k * iqr_value
    upper = q3 + k * iqr_value
    # Khoảng cách (chuẩn hóa theo IQR) tới biên gần nhất
    score = np.maximum(lower - x, x - upper) / max(iqr_value, 1e-12)
    pred = ((x < lower) | (x > upper)).astype(int)
    return pred, score


def _grubbs_critical(n: int, alpha: float) -> float:
    """Giá trị tới hạn Grubbs hai phía cho mẫu kích thước n."""
    if n < 3:
        return np.inf
    t = stats.t.ppf(1 - alpha / (2 * n), df=n - 2)
    return (n - 1) / np.sqrt(n) * np.sqrt(t**2 / (n - 2 + t**2))


def grubbs_esd(
    x: np.ndarray, alpha: float = 0.05, max_outliers: int = 15
) -> tuple[np.ndarray, np.ndarray]:
    """Generalized ESD: lặp Grubbs, đánh dấu điểm cực trị nhất mỗi vòng.

    Số ngoại lai cuối cùng là chỉ số `r` lớn nhất mà thống kê G_r vượt giá
    trị tới hạn λ_r (theo Rosner 1983). Score là khoảng cách chuẩn hóa
    tại vòng phát hiện, hoặc giá trị nhỏ nếu chưa được đánh dấu.
    """
    n = x.size
    remaining_idx = list(range(n))
    flagged: list[int] = []
    discovery_g: list[float] = []  # thống kê G tại vòng tìm thấy

    g_stats = []
    g_crits = []
    candidates: list[int] = []

    work = x.astype(float).copy()

    for r in range(min(max_outliers, n - 2)):
        sub = work[remaining_idx]
        mean = sub.mean()
        std = sub.std(ddof=1)
        if std == 0:
            break
        residuals = np.abs(sub - mean)
        local_max = int(np.argmax(residuals))
        g = float(residuals[local_max] / std)
        g_crit = _grubbs_critical(len(sub), alpha)
        g_stats.append(g)
        g_crits.append(g_crit)
        global_idx = remaining_idx[local_max]
        candidates.append(global_idx)
        discovery_g.append(g)
        remaining_idx.pop(local_max)

    # r* = chỉ số lớn nhất mà G_r > λ_r
    r_star = -1
    for r, (g, g_crit) in enumerate(zip(g_stats, g_crits)):
        if g > g_crit:
            r_star = r
    flagged = candidates[: r_star + 1] if r_star >= 0 else []

    pred = np.zeros(n, dtype=int)
    pred[flagged] = 1

    # Score: với điểm i, ta lấy thống kê G tại vòng nó được "ứng cử".
    # Điểm chưa bao giờ là cực trị nhận một điểm nền nhỏ tỉ lệ với
    # |x - median| / MAD để bảng AUC vẫn có ý nghĩa.
    score = np.zeros(n, dtype=float)
    for cand_idx, g_val in zip(candidates, discovery_g):
        score[cand_idx] = g_val
    median = float(np.median(x))
    mad = float(np.median(np.abs(x - median))) or 1.0
    base = np.abs(x - median) / mad
    mask_assigned = score > 0
    # Bảo đảm score điểm "ứng cử" >= score điểm chưa ứng cử
    if mask_assigned.any():
        floor = score[mask_assigned].min()
    else:
        floor = base.max() + 1.0
    score = np.where(mask_assigned, score, np.minimum(base, floor * 0.99))
    return pred, score


__all__ = ["zscore", "modified_zscore", "iqr", "grubbs_esd"]
