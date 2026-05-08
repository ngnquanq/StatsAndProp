"""Isolation Forest, One-Class SVM và Autoencoder MLP."""

from __future__ import annotations

import numpy as np
from sklearn.ensemble import IsolationForest
from sklearn.neural_network import MLPRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.svm import OneClassSVM


def iforest(
    X: np.ndarray,
    n_estimators: int = 100,
    contamination: float = 0.05,
    random_state: int = 42,
) -> tuple[np.ndarray, np.ndarray]:
    model = IsolationForest(
        n_estimators=n_estimators,
        contamination=contamination,
        random_state=random_state,
    )
    pred_signed = model.fit_predict(X)
    pred = (pred_signed == -1).astype(int)
    score = -model.score_samples(X)  # cao hơn = bất thường hơn
    return pred, score


def ocsvm(
    X: np.ndarray, nu: float = 0.05, gamma: str | float = "scale"
) -> tuple[np.ndarray, np.ndarray]:
    scaler = StandardScaler().fit(X)
    Xs = scaler.transform(X)
    model = OneClassSVM(kernel="rbf", nu=nu, gamma=gamma)
    pred_signed = model.fit_predict(Xs)
    pred = (pred_signed == -1).astype(int)
    score = -model.decision_function(Xs)
    return pred, score


def autoencoder_mlp(
    X: np.ndarray,
    hidden_layers: tuple[int, ...] = (8, 2, 8),
    contamination: float = 0.05,
    max_iter: int = 2000,
    random_state: int = 42,
) -> tuple[np.ndarray, np.ndarray, dict]:
    """Autoencoder thực thi qua sklearn.MLPRegressor với input == target.

    Kiến trúc mặc định: p - 8 - 2 - 8 - p (cổ chai 2 chiều).
    Score = MSE tái tạo. Ngưỡng = phân vị (1-contamination) của MSE.
    """
    scaler = StandardScaler().fit(X)
    Xs = scaler.transform(X)
    model = MLPRegressor(
        hidden_layer_sizes=hidden_layers,
        activation="tanh",
        solver="adam",
        learning_rate_init=1e-3,
        max_iter=max_iter,
        random_state=random_state,
        tol=1e-6,
    )
    model.fit(Xs, Xs)
    Xs_hat = model.predict(Xs)
    score = np.mean((Xs - Xs_hat) ** 2, axis=1)
    threshold = float(np.quantile(score, 1 - contamination))
    pred = (score > threshold).astype(int)
    info = {
        "loss": float(model.loss_),
        "n_iter": int(model.n_iter_),
        "threshold": threshold,
    }
    return pred, score, info


__all__ = ["iforest", "ocsvm", "autoencoder_mlp"]
