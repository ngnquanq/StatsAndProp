"""Entry point: sinh dữ liệu → chạy 11 phương pháp → ghi hình + bảng.

Cách dùng:
    python run_all.py
"""

from __future__ import annotations

import warnings
from pathlib import Path

import numpy as np

from data_gen import generate
from evaluate import (
    Result,
    METHOD_LABELS,
    evaluate,
    write_results_tex,
)
from methods.density import dbscan, lof
from methods.ml import autoencoder_mlp, iforest, ocsvm
from methods.multivariate import mahalanobis, pca_t2_q
from methods.univariate import grubbs_esd, iqr, modified_zscore, zscore
from plotting import (
    FIGS_DIR,
    dataset_overview,
    plot_2d_method,
    plot_univariate_method,
    score_comparison,
)

# Tiêu chí được giữ ổn định: contamination cho LOF/IF/AE = 15/315
CONTAMINATION_NL = 15 / 315


def main() -> None:
    warnings.filterwarnings(
        "ignore", category=UserWarning, module="sklearn"
    )

    print("[1/4] Sinh dữ liệu (seed=42)…")
    data = generate(save=True)
    ud_x, ud_y = data["ud_x"], data["ud_y"]
    md2_x, md2_y = data["md2_x"], data["md2_y"]
    mdnl_x, mdnl_y = data["mdnl_x"], data["mdnl_y"]
    print(f"    UD={ud_x.shape}, MD2={md2_x.shape}, MD-NL={mdnl_x.shape}")

    print("[2/4] Sinh hình tổng quan dataset…")
    dataset_overview(data)

    results: list[Result] = []
    fig_paths: dict[str, Path] = {}

    print("[3/4] Chạy 11 phương pháp…")

    # ---- UD: 4 phương pháp đơn biến ----
    for key, fn, extra in [
        ("zscore", zscore, "τ=3"),
        ("modz", modified_zscore, "τ=3,5"),
        ("iqr", iqr, "k=1,5"),
        ("grubbs", grubbs_esd, "α=0,05"),
    ]:
        pred, score = fn(ud_x)
        res = evaluate(key, "UD", ud_y, pred, score)
        results.append(res)
        path = FIGS_DIR / f"{key}.pdf"
        plot_univariate_method(key, ud_x, ud_y, pred, path, title_extra=extra)
        fig_paths[key] = path

    # ---- MD2: Mahalanobis, PCA ----
    pred, score = mahalanobis(md2_x)
    results.append(evaluate("mahal", "MD2", md2_y, pred, score))
    fig_paths["mahal"] = plot_2d_method(
        "mahal", md2_x, md2_y, pred, FIGS_DIR / "mahalanobis.pdf",
        title_extra="α=0,05",
    )

    pred, score, info = pca_t2_q(md2_x)
    results.append(evaluate("pca", "MD2", md2_y, pred, score))
    fig_paths["pca"] = plot_2d_method(
        "pca", md2_x, md2_y, pred, FIGS_DIR / "pca.pdf",
        title_extra=f"k={info['k']}, α=0,05",
    )

    # ---- MD-NL: DBSCAN, LOF ----
    pred, score, info = dbscan(mdnl_x)
    results.append(evaluate("dbscan", "MD-NL", mdnl_y, pred, score))
    fig_paths["dbscan"] = plot_2d_method(
        "dbscan", mdnl_x, mdnl_y, pred, FIGS_DIR / "dbscan.pdf",
        title_extra=f"ε={info['eps']:.2f}, MinPts={info['min_samples']}",
    )

    pred, score = lof(mdnl_x, n_neighbors=20, contamination=CONTAMINATION_NL)
    results.append(evaluate("lof", "MD-NL", mdnl_y, pred, score))
    fig_paths["lof"] = plot_2d_method(
        "lof", mdnl_x, mdnl_y, pred, FIGS_DIR / "lof.pdf",
        title_extra="k=20",
    )

    # ---- MD-NL: IsoForest, OC-SVM, Autoencoder ----
    pred, score = iforest(mdnl_x, contamination=CONTAMINATION_NL)
    results.append(evaluate("iforest", "MD-NL", mdnl_y, pred, score))
    fig_paths["iforest"] = plot_2d_method(
        "iforest", mdnl_x, mdnl_y, pred, FIGS_DIR / "iforest.pdf",
        title_extra="n_estimators=100",
    )

    pred, score = ocsvm(mdnl_x, nu=CONTAMINATION_NL)
    results.append(evaluate("ocsvm", "MD-NL", mdnl_y, pred, score))
    fig_paths["ocsvm"] = plot_2d_method(
        "ocsvm", mdnl_x, mdnl_y, pred, FIGS_DIR / "ocsvm.pdf",
        title_extra=f"RBF, ν={CONTAMINATION_NL:.3f}",
    )

    pred, score, info = autoencoder_mlp(
        mdnl_x, contamination=CONTAMINATION_NL
    )
    results.append(evaluate("autoenc", "MD-NL", mdnl_y, pred, score))
    fig_paths["autoenc"] = plot_2d_method(
        "autoenc", mdnl_x, mdnl_y, pred, FIGS_DIR / "autoencoder.pdf",
        title_extra=f"2-8-2-8-2, loss={info['loss']:.3g}",
    )

    print("[4/4] Xuất bảng và biểu đồ so sánh…")
    score_comparison(results)
    tex_path = write_results_tex(results)

    print()
    print("=" * 78)
    print(
        f"{'Method':<22}{'Dataset':<8}{'TP':>4}{'FP':>4}{'FN':>4}"
        f"{'Prec':>8}{'Recall':>8}{'F1':>8}{'AUC':>8}"
    )
    print("-" * 78)
    for r in results:
        auc_s = "  --  " if r.auc is None else f"{r.auc:.3f}"
        print(
            f"{METHOD_LABELS.get(r.method, r.method):<22}{r.dataset:<8}"
            f"{r.tp:>4}{r.fp:>4}{r.fn:>4}"
            f"{r.precision:>8.3f}{r.recall:>8.3f}{r.f1:>8.3f}{auc_s:>8}"
        )
    print("=" * 78)
    print(f"Bảng LaTeX: {tex_path}")
    print(f"Hình PDF  : {len(fig_paths) + 2} file ở {FIGS_DIR}")


if __name__ == "__main__":
    main()
