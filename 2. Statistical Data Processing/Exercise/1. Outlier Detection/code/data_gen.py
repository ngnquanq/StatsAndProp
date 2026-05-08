"""Sinh 3 dataset mô phỏng cho các thí nghiệm phát hiện ngoại lai.

Tất cả nguồn ngẫu nhiên đều seed = 42 để bảo đảm tái lập.
"""

from __future__ import annotations

from pathlib import Path

import numpy as np
from sklearn.datasets import make_moons

SEED = 42
DATA_PATH = Path(__file__).resolve().parent / "data.npz"


def _univariate(rng: np.random.Generator) -> tuple[np.ndarray, np.ndarray]:
    """Dataset UD: 200 N(50, 25) + 10 ngoại lai (5 cao, 5 thấp)."""
    n_inlier = 200
    inliers = rng.normal(loc=50.0, scale=5.0, size=n_inlier)
    high = rng.normal(loc=80.0, scale=2.0, size=5)
    low = rng.normal(loc=20.0, scale=2.0, size=5)
    outliers = np.concatenate([high, low])
    x = np.concatenate([inliers, outliers])
    y = np.concatenate([np.zeros(n_inlier, dtype=int), np.ones(10, dtype=int)])
    perm = rng.permutation(x.size)
    return x[perm], y[perm]


def _multivariate_gaussian(rng: np.random.Generator) -> tuple[np.ndarray, np.ndarray]:
    """Dataset MD2: 200 Gaussian 2D có tương quan + 15 ngoại lai uniform."""
    mean = np.array([0.0, 0.0])
    cov = np.array([[2.0, 1.5], [1.5, 2.0]])
    inliers = rng.multivariate_normal(mean, cov, size=200)

    cov_inv = np.linalg.inv(cov)
    outliers = []
    while len(outliers) < 15:
        cand = rng.uniform(-8.0, 8.0, size=2)
        diff = cand - mean
        d2 = float(diff @ cov_inv @ diff)
        if d2 > 25.0:  # Mahalanobis > 5
            outliers.append(cand)
    outliers_arr = np.asarray(outliers)

    x = np.vstack([inliers, outliers_arr])
    y = np.concatenate([np.zeros(200, dtype=int), np.ones(15, dtype=int)])
    perm = rng.permutation(x.shape[0])
    return x[perm], y[perm]


def _multivariate_nonlinear(rng: np.random.Generator) -> tuple[np.ndarray, np.ndarray]:
    """Dataset MD-NL: 300 điểm two-moons + 15 ngoại lai uniform."""
    inliers, _ = make_moons(n_samples=300, noise=0.05, random_state=SEED)

    x_min, x_max = inliers[:, 0].min() - 0.5, inliers[:, 0].max() + 0.5
    y_min, y_max = inliers[:, 1].min() - 0.5, inliers[:, 1].max() + 0.5
    outliers = np.column_stack(
        [
            rng.uniform(x_min, x_max, size=15),
            rng.uniform(y_min, y_max, size=15),
        ]
    )

    # Đẩy các ngoại lai ra xa hai cụm để tránh trùng vùng dày
    from sklearn.metrics import pairwise_distances

    d = pairwise_distances(outliers, inliers).min(axis=1)
    keep = d > 0.25
    while keep.sum() < 15:
        extra = np.column_stack(
            [
                rng.uniform(x_min, x_max, size=30),
                rng.uniform(y_min, y_max, size=30),
            ]
        )
        d_extra = pairwise_distances(extra, inliers).min(axis=1)
        good = extra[d_extra > 0.25]
        outliers = np.vstack([outliers[keep], good])
        keep = np.ones(outliers.shape[0], dtype=bool)
    outliers = outliers[keep][:15]

    x = np.vstack([inliers, outliers])
    y = np.concatenate([np.zeros(300, dtype=int), np.ones(15, dtype=int)])
    perm = rng.permutation(x.shape[0])
    return x[perm], y[perm]


def generate(save: bool = True) -> dict[str, np.ndarray]:
    """Sinh tất cả dataset và (tùy chọn) lưu .npz."""
    rng = np.random.default_rng(SEED)
    ud_x, ud_y = _univariate(rng)
    md2_x, md2_y = _multivariate_gaussian(rng)
    mdnl_x, mdnl_y = _multivariate_nonlinear(rng)

    bundle = {
        "ud_x": ud_x,
        "ud_y": ud_y,
        "md2_x": md2_x,
        "md2_y": md2_y,
        "mdnl_x": mdnl_x,
        "mdnl_y": mdnl_y,
    }
    if save:
        np.savez(DATA_PATH, **bundle)
    return bundle


def load() -> dict[str, np.ndarray]:
    if not DATA_PATH.exists():
        return generate(save=True)
    with np.load(DATA_PATH) as f:
        return {k: f[k] for k in f.files}


if __name__ == "__main__":
    data = generate(save=True)
    for k, v in data.items():
        print(f"{k:<8} shape={v.shape} dtype={v.dtype}")
    print(f"Saved -> {DATA_PATH}")
