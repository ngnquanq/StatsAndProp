"""DBSCAN và LOF."""

from __future__ import annotations

import numpy as np
from sklearn.cluster import DBSCAN
from sklearn.neighbors import LocalOutlierFactor, NearestNeighbors


def _suggest_eps(X: np.ndarray, k: int) -> float:
    """Đề xuất ε bằng đồ thị k-distance: lấy điểm gãy (knee) đơn giản
    là phân vị thứ 95 của khoảng cách tới lân cận thứ k."""
    nn = NearestNeighbors(n_neighbors=k + 1).fit(X)
    distances, _ = nn.kneighbors(X)
    kth = distances[:, -1]
    return float(np.percentile(kth, 95))


def dbscan(
    X: np.ndarray,
    eps: float | None = None,
    min_samples: int = 5,
) -> tuple[np.ndarray, np.ndarray, dict]:
    if eps is None:
        eps = _suggest_eps(X, k=min_samples)
    model = DBSCAN(eps=eps, min_samples=min_samples)
    labels = model.fit_predict(X)
    pred = (labels == -1).astype(int)

    # Score: khoảng cách trung bình tới min_samples lân cận gần nhất.
    nn = NearestNeighbors(n_neighbors=min_samples + 1).fit(X)
    d, _ = nn.kneighbors(X)
    score = d[:, 1:].mean(axis=1)
    info = {"eps": float(eps), "min_samples": int(min_samples)}
    return pred, score, info


def lof(
    X: np.ndarray, n_neighbors: int = 20, contamination: float | str = "auto"
) -> tuple[np.ndarray, np.ndarray]:
    model = LocalOutlierFactor(
        n_neighbors=n_neighbors, contamination=contamination
    )
    pred_signed = model.fit_predict(X)  # 1 = inlier, -1 = outlier
    pred = (pred_signed == -1).astype(int)
    # negative_outlier_factor_: âm hơn = bất thường hơn
    score = -model.negative_outlier_factor_
    return pred, score


__all__ = ["dbscan", "lof"]
