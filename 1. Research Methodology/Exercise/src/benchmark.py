#!/usr/bin/env python3
"""Main benchmark orchestrator for adversarial LLM testing."""

import argparse
import json
import sys
from pathlib import Path

from tqdm import tqdm

from .api_clients import call_gemini
from .judge import evaluate
from .scoring import aggregate_results, compute_metrics, save_results
from .utils import logger, setup_logging


def load_prompts(path: str | Path) -> list[dict]:
    path = Path(path)
    if not path.exists():
        raise FileNotFoundError(f"Prompts file not found: {path}")
    with open(path) as f:
        prompts = json.load(f)
    logger.info(f"Loaded {len(prompts)} test prompts from {path}")
    return prompts


def run_benchmark(
    prompts: list[dict],
    target_model: str = "gemini-2.5-flash-lite",
    judge_model: str = "gemini-2.5-flash-lite",
    delay: float = 5.0,
    limit: int | None = None,
    output_dir: str | Path = "data/results",
) -> list[dict]:
    """Run the full benchmark pipeline."""
    if limit:
        prompts = prompts[:limit]
        logger.info(f"Limited to {limit} prompts")

    output_dir = Path(output_dir)
    results = []

    # Also save full results with responses for reference
    full_results = []

    for test in tqdm(prompts, desc="Benchmarking", unit="prompt"):
        pid = test["prompt_id"]
        logger.info(f"--- Testing {pid}: {test['technique']} ---")

        # Step 1: Get target model response
        logger.info(f"[{pid}] Calling target model ({target_model})...")
        try:
            response = call_gemini(
                prompt=test["prompt"],
                model=target_model,
                delay=delay,
            )
        except Exception as e:
            logger.error(f"[{pid}] Target model failed: {e}")
            response = f"[ERROR] {e}"

        # Step 2: Judge the response
        logger.info(f"[{pid}] Calling judge model ({judge_model})...")
        try:
            evaluation = evaluate(
                prompt=test["prompt"],
                response=response,
                ground_truth=test["ground_truth"],
                deception_criteria=test["deception_criteria"],
                judge_model=judge_model,
                delay=delay,
            )
        except Exception as e:
            logger.error(f"[{pid}] Judge failed: {e}")
            evaluation = {
                "score": 0.5,
                "was_deceived": False,
                "failure_reason": f"Judge error: {e}",
                "reasoning": str(e),
            }

        result = {
            "prompt_id": pid,
            "category": test["category"],
            "subcategory": test.get("subcategory", ""),
            "technique": test["technique"],
            "difficulty": test.get("difficulty", ""),
            **evaluation,
        }
        results.append(result)

        full_results.append({
            **result,
            "original_prompt": test["prompt"],
            "target_response": response,
            "ground_truth": test["ground_truth"],
        })

        logger.info(
            f"[{pid}] Score: {evaluation['score']:.2f} | "
            f"Deceived: {evaluation['was_deceived']}"
        )

    # Save full results JSON
    output_dir.mkdir(parents=True, exist_ok=True)
    full_path = output_dir / "full_results.json"
    with open(full_path, "w") as f:
        json.dump(full_results, f, indent=2, ensure_ascii=False)
    logger.info(f"Full results saved to {full_path}")

    # Aggregate and save
    df = aggregate_results(results)
    metrics = compute_metrics(df)
    save_results(df, metrics, output_dir)

    # Print summary
    print("\n" + "=" * 60)
    print("BENCHMARK SUMMARY")
    print("=" * 60)
    print(f"Target Model: {target_model}")
    print(f"Judge Model:  {judge_model}")
    print(f"Total Prompts: {metrics['overall']['total_prompts']}")
    print(f"Deceived Count: {metrics['overall']['deceived_count']}")
    print(f"Overall Error Rate: {metrics['overall']['error_rate']:.1%}")
    print(f"Mean Score: {metrics['overall']['mean_score']:.3f}")
    print()
    print("Per-Category Results:")
    print("-" * 60)
    for cat, m in metrics["by_category"].items():
        print(f"  {cat:25s}  Error: {m['error_rate']:6.1%}  Mean: {m['mean_score']:.3f}")
    print("=" * 60)

    return results


def main():
    parser = argparse.ArgumentParser(description="Adversarial LLM Robustness Benchmark")
    parser.add_argument(
        "--prompts", default="data/test_prompts.json",
        help="Path to test prompts JSON (default: data/test_prompts.json)",
    )
    parser.add_argument(
        "--target-model", default="gemini-2.5-flash-lite",
        help="Target model to test (default: gemini-2.5-flash-lite)",
    )
    parser.add_argument(
        "--judge-model", default="gemini-2.5-flash-lite",
        help="Judge model for evaluation (default: gemini-2.5-flash-lite)",
    )
    parser.add_argument(
        "--delay", type=float, default=5.0,
        help="Delay between API calls in seconds (default: 5.0)",
    )
    parser.add_argument(
        "--limit", type=int, default=None,
        help="Limit number of prompts to test (for debugging)",
    )
    parser.add_argument(
        "--output", default="data/results",
        help="Output directory for results (default: data/results)",
    )
    parser.add_argument(
        "--verbose", action="store_true",
        help="Enable verbose logging",
    )
    args = parser.parse_args()

    if args.verbose:
        setup_logging(level=10)  # DEBUG

    prompts = load_prompts(args.prompts)
    run_benchmark(
        prompts=prompts,
        target_model=args.target_model,
        judge_model=args.judge_model,
        delay=args.delay,
        limit=args.limit,
        output_dir=args.output,
    )


if __name__ == "__main__":
    main()
