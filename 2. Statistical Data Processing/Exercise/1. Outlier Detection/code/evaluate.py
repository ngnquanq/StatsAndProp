"""Tính metric và xuất results_table.tex."""

from __future__ import annotations

from dataclasses import dataclass, asdict
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.metrics import (
    f1_score,
    precision_score,
    recall_score,
    roc_auc_score,
)


RESULTS_TEX = Path(__file__).resolve().parents[1] / "results_table.tex"


@dataclass
class Result:
    method: str
    dataset: str
    n_pred: int
    n_true: int
    tp: int
    fp: int
    fn: int
    precision: float
    recall: float
    f1: float
    auc: float | None


def evaluate(
    method: str,
    dataset: str,
    y_true: np.ndarray,
    y_pred: np.ndarray,
    score: np.ndarray | None = None,
) -> Result:
    y_true = np.asarray(y_true).astype(int)
    y_pred = np.asarray(y_pred).astype(int)
    tp = int(((y_pred == 1) & (y_true == 1)).sum())
    fp = int(((y_pred == 1) & (y_true == 0)).sum())
    fn = int(((y_pred == 0) & (y_true == 1)).sum())
    p = float(precision_score(y_true, y_pred, zero_division=0))
    r = float(recall_score(y_true, y_pred, zero_division=0))
    f = float(f1_score(y_true, y_pred, zero_division=0))
    auc: float | None
    if score is not None and len(np.unique(y_true)) > 1:
        auc = float(roc_auc_score(y_true, score))
    else:
        auc = None
    return Result(
        method=method,
        dataset=dataset,
        n_pred=int(y_pred.sum()),
        n_true=int(y_true.sum()),
        tp=tp,
        fp=fp,
        fn=fn,
        precision=p,
        recall=r,
        f1=f,
        auc=auc,
    )


# -------------------- xuất bảng LaTeX --------------------

# Tên hiển thị tiếng Việt cho mỗi phương pháp
METHOD_LABELS = {
    "zscore": r"Z-score",
    "modz": r"Modified Z-score",
    "iqr": r"IQR (Tukey)",
    "grubbs": r"Grubbs (ESD)",
    "mahal": r"Mahalanobis",
    "pca": r"PCA (T$^2$, Q)",
    "dbscan": r"DBSCAN",
    "lof": r"LOF",
    "iforest": r"Isolation Forest",
    "ocsvm": r"One-Class SVM",
    "autoenc": r"Autoencoder (MLP)",
}

DATASET_LABELS = {
    "UD": "UD",
    "MD2": "MD2",
    "MD-NL": "MD-NL",
}

# Thứ tự cố định
METHOD_ORDER = list(METHOD_LABELS.keys())


def to_dataframe(results: list[Result]) -> pd.DataFrame:
    df = pd.DataFrame([asdict(r) for r in results])
    df["method_order"] = df["method"].map(
        {m: i for i, m in enumerate(METHOD_ORDER)}
    )
    df = df.sort_values("method_order").drop(columns="method_order")
    return df.reset_index(drop=True)


def _fmt(x: float | None, digits: int = 3) -> str:
    if x is None or (isinstance(x, float) and np.isnan(x)):
        return "--"
    return f"{x:.{digits}f}".replace(".", ",")


def write_results_tex(results: list[Result], path: Path = RESULTS_TEX) -> Path:
    df = to_dataframe(results)
    lines = [
        r"% Bảng được sinh tự động từ code/run_all.py — KHÔNG sửa tay.",
        r"\begin{table}[ht]",
        r"\centering",
        r"\caption{Kết quả thực nghiệm của 11 phương pháp trên 3 dataset mô phỏng (seed = 42).}",
        r"\label{tab:experiment-results}",
        r"\small",
        r"\begin{tabular}{llccccccc}",
        r"\toprule",
        r"\textbf{Phương pháp} & \textbf{Dataset} & "
        r"\textbf{TP} & \textbf{FP} & \textbf{FN} & "
        r"\textbf{Precision} & \textbf{Recall} & \textbf{F1} & \textbf{AUC} \\",
        r"\midrule",
    ]
    for _, row in df.iterrows():
        lines.append(
            " & ".join(
                [
                    METHOD_LABELS.get(row["method"], row["method"]),
                    DATASET_LABELS.get(row["dataset"], row["dataset"]),
                    str(int(row["tp"])),
                    str(int(row["fp"])),
                    str(int(row["fn"])),
                    _fmt(row["precision"]),
                    _fmt(row["recall"]),
                    _fmt(row["f1"]),
                    _fmt(row["auc"]),
                ]
            )
            + r" \\"
        )
    lines += [
        r"\bottomrule",
        r"\end{tabular}",
        r"\medskip",
        r"",
        r"\textit{Ghi chú}: TP = số ngoại lai phát hiện đúng; "
        r"FP = số điểm bình thường bị gắn nhầm là ngoại lai; "
        r"FN = số ngoại lai bị bỏ sót. "
        r"Mỗi dataset có số ngoại lai thực: UD = 10, MD2 = 15, MD-NL = 15.",
        r"\end{table}",
        "",
    ]
    path.write_text("\n".join(lines), encoding="utf-8")
    return path


__all__ = ["Result", "evaluate", "to_dataframe", "write_results_tex"]
