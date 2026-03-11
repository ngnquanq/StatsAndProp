#!/usr/bin/env python3
"""Generate charts from benchmark results CSV."""

import argparse
import sys
from pathlib import Path

import matplotlib.pyplot as plt
import matplotlib
import numpy as np
import pandas as pd
import seaborn as sns

matplotlib.use("Agg")  # Non-interactive backend

# Consistent style
sns.set_theme(style="whitegrid", font_scale=1.1)
COLORS = ["#e74c3c", "#3498db", "#2ecc71", "#f39c12"]
CATEGORY_ORDER = ["Hallucination", "Math & Stats", "Reasoning & Jailbreak", "Security & IAM"]


def load_results(csv_path: str) -> pd.DataFrame:
    df = pd.read_csv(csv_path)
    print(f"Loaded {len(df)} results from {csv_path}")
    return df


def chart_mean_score_by_category(df: pd.DataFrame, output_dir: Path):
    """Bar chart: Mean robustness score by category."""
    cat_stats = df.groupby("category").agg(
        mean_score=("score", "mean"),
        count=("score", "count"),
    ).reindex(CATEGORY_ORDER).dropna()

    # Color bars by score: green for high, red for low
    def score_color(score):
        if score >= 0.8:
            return "#27ae60"
        elif score >= 0.6:
            return "#2ecc71"
        elif score >= 0.4:
            return "#f39c12"
        else:
            return "#e74c3c"

    bar_colors = [score_color(s) for s in cat_stats["mean_score"]]

    fig, ax = plt.subplots(figsize=(10, 6))
    bars = ax.bar(
        range(len(cat_stats)),
        cat_stats["mean_score"],
        color=bar_colors,
        edgecolor="white",
        linewidth=1.5,
    )

    ax.set_xticks(range(len(cat_stats)))
    ax.set_xticklabels(cat_stats.index, rotation=15, ha="right")
    ax.set_ylabel("Mean Robustness Score")
    ax.set_title("Mean Robustness Score by Adversarial Category")
    ax.set_ylim(0, 1.15)
    ax.axhline(y=0.5, color="gray", linestyle="--", alpha=0.5, label="Deception threshold")
    ax.legend(loc="upper right")

    for bar, score in zip(bars, cat_stats["mean_score"]):
        ax.text(
            bar.get_x() + bar.get_width() / 2,
            bar.get_height() + 0.02,
            f"{score:.3f}",
            ha="center", va="bottom", fontweight="bold",
        )

    plt.tight_layout()
    path = output_dir / "mean_score_by_category.png"
    fig.savefig(path, dpi=150, bbox_inches="tight")
    plt.close(fig)
    print(f"Saved: {path}")


def chart_score_heatmap(df: pd.DataFrame, output_dir: Path):
    """Heatmap: Each prompt's score color-coded."""
    pivot = df.pivot_table(
        values="score", index="category", columns="prompt_id", aggfunc="first"
    )
    # Sort columns by prompt_id
    pivot = pivot.reindex(columns=sorted(pivot.columns))

    fig, ax = plt.subplots(figsize=(14, 5))
    sns.heatmap(
        pivot,
        annot=True, fmt=".2f",
        cmap="RdYlGn", vmin=0, vmax=1,
        linewidths=1, linecolor="white",
        cbar_kws={"label": "Robustness Score"},
        ax=ax,
    )
    ax.set_title("Robustness Score Heatmap by Prompt")
    ax.set_ylabel("")
    ax.set_xlabel("Prompt ID")
    plt.xticks(rotation=45, ha="right")

    plt.tight_layout()
    path = output_dir / "score_heatmap.png"
    fig.savefig(path, dpi=150, bbox_inches="tight")
    plt.close(fig)
    print(f"Saved: {path}")


def chart_score_distribution(df: pd.DataFrame, output_dir: Path):
    """Histogram: Score distribution across all evaluations."""
    fig, ax = plt.subplots(figsize=(8, 5))
    bins = [0, 0.125, 0.375, 0.625, 0.875, 1.0]
    labels = ["0.0\nFully\nDeceived", "0.25\nMostly\nDeceived", "0.50\nPartially\nDeceived",
              "0.75\nMostly\nRobust", "1.0\nFully\nRobust"]

    counts, _, patches = ax.hist(
        df["score"], bins=bins, edgecolor="white", linewidth=1.5,
        color="#3498db", alpha=0.85,
    )
    colors_hist = ["#e74c3c", "#e67e22", "#f1c40f", "#2ecc71", "#27ae60"]
    for patch, color in zip(patches, colors_hist):
        patch.set_facecolor(color)

    ax.set_xticks([0.0625, 0.25, 0.5, 0.75, 0.9375])
    ax.set_xticklabels(labels, fontsize=8)
    ax.set_ylabel("Number of Prompts")
    ax.set_title("Distribution of Robustness Scores")

    for count, patch in zip(counts, patches):
        if count > 0:
            ax.text(
                patch.get_x() + patch.get_width() / 2,
                count + 0.2,
                str(int(count)),
                ha="center", va="bottom", fontweight="bold",
            )

    plt.tight_layout()
    path = output_dir / "score_distribution.png"
    fig.savefig(path, dpi=150, bbox_inches="tight")
    plt.close(fig)
    print(f"Saved: {path}")


def chart_radar(df: pd.DataFrame, output_dir: Path):
    """Radar chart: Per-category mean robustness score."""
    cat_means = df.groupby("category")["score"].mean().reindex(CATEGORY_ORDER).dropna()
    categories = list(cat_means.index)
    values = list(cat_means.values)

    # Close the radar
    values += values[:1]
    angles = np.linspace(0, 2 * np.pi, len(categories), endpoint=False).tolist()
    angles += angles[:1]

    fig, ax = plt.subplots(figsize=(7, 7), subplot_kw=dict(polar=True))
    ax.plot(angles, values, "o-", linewidth=2, color="#3498db")
    ax.fill(angles, values, alpha=0.25, color="#3498db")
    ax.set_xticks(angles[:-1])
    ax.set_xticklabels(categories, fontsize=9)
    ax.set_ylim(0, 1)
    ax.set_yticks([0.25, 0.5, 0.75, 1.0])
    ax.set_yticklabels(["0.25", "0.50", "0.75", "1.00"], fontsize=8)
    ax.set_title("Per-Category Robustness Profile", y=1.08)

    # Annotate values
    for angle, value, cat in zip(angles[:-1], values[:-1], categories):
        ax.annotate(
            f"{value:.2f}",
            xy=(angle, value),
            xytext=(5, 5),
            textcoords="offset points",
            fontsize=9, fontweight="bold",
        )

    plt.tight_layout()
    path = output_dir / "radar_robustness.png"
    fig.savefig(path, dpi=150, bbox_inches="tight")
    plt.close(fig)
    print(f"Saved: {path}")


def main():
    parser = argparse.ArgumentParser(description="Generate charts from benchmark results")
    parser.add_argument(
        "--input", default="data/results/results.csv",
        help="Path to results CSV",
    )
    parser.add_argument(
        "--output", default="report/figures",
        help="Output directory for chart PNGs",
    )
    args = parser.parse_args()

    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    df = load_results(args.input)

    chart_mean_score_by_category(df, output_dir)
    chart_score_heatmap(df, output_dir)
    chart_score_distribution(df, output_dir)
    chart_radar(df, output_dir)

    print(f"\nAll charts saved to {output_dir}/")


if __name__ == "__main__":
    main()
