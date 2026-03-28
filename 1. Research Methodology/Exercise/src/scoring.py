from pathlib import Path

import pandas as pd

from .utils import logger


def aggregate_results(results: list[dict]) -> pd.DataFrame:
    """Convert raw results list to a structured DataFrame."""
    rows = []
    for r in results:
        rows.append({
            "prompt_id": r["prompt_id"],
            "category": r["category"],
            "subcategory": r.get("subcategory", ""),
            "technique": r["technique"],
            "difficulty": r.get("difficulty", ""),
            "score": r["score"],
            "was_deceived": r["was_deceived"],
            "failure_reason": r.get("failure_reason", ""),
            "reasoning": r.get("reasoning", ""),
        })
    return pd.DataFrame(rows)


def compute_metrics(df: pd.DataFrame) -> dict:
    """Compute overall and per-category error metrics."""
    total = len(df)
    deceived = df["was_deceived"].sum()
    overall_error_rate = deceived / total if total > 0 else 0

    metrics = {
        "overall": {
            "total_prompts": total,
            "deceived_count": int(deceived),
            "error_rate": round(overall_error_rate, 4),
            "mean_score": round(df["score"].mean(), 4),
            "median_score": round(df["score"].median(), 4),
        },
        "by_category": {},
    }

    for cat, group in df.groupby("category"):
        cat_total = len(group)
        cat_deceived = group["was_deceived"].sum()
        metrics["by_category"][cat] = {
            "total": cat_total,
            "deceived": int(cat_deceived),
            "error_rate": round(cat_deceived / cat_total, 4) if cat_total > 0 else 0,
            "mean_score": round(group["score"].mean(), 4),
        }

    return metrics


def save_results(df: pd.DataFrame, metrics: dict, output_dir: str | Path):
    """Save results to CSV and Excel files."""
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    csv_path = output_dir / "results.csv"
    df.to_csv(csv_path, index=False)
    logger.info(f"Results saved to {csv_path}")

    xlsx_path = output_dir / "results.xlsx"
    with pd.ExcelWriter(xlsx_path, engine="openpyxl") as writer:
        df.to_excel(writer, sheet_name="Raw Results", index=False)

        metrics_rows = []
        for cat, m in metrics["by_category"].items():
            metrics_rows.append({"category": cat, **m})
        metrics_rows.append({
            "category": "OVERALL",
            "total": metrics["overall"]["total_prompts"],
            "deceived": metrics["overall"]["deceived_count"],
            "error_rate": metrics["overall"]["error_rate"],
            "mean_score": metrics["overall"]["mean_score"],
        })
        pd.DataFrame(metrics_rows).to_excel(writer, sheet_name="Metrics", index=False)

    logger.info(f"Excel saved to {xlsx_path}")
    return csv_path, xlsx_path
