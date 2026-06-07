# Hung-yi Lee — Generative AI 2024 (NTU)
**Instructor:** Hung-yi Lee
**Course page:** https://speech.ee.ntu.edu.tw/~hylee/genai/2024-spring.php
**YouTube:** https://www.youtube.com/playlist?list=PLJV_el3uVTsOePyfmkfivYZ7Yqm5A0m2E

Dedicated course on LLMs and generative AI. More applied than ML 2023. Several slides directly overlap with Chen's SPML topics (prompt injection, LLM evaluation, ethics).

---

## Slides downloaded

| File | Topic | Relevance to Chen's lab |
|---|---|---|
| 01_intro_generative_ai.pdf | What is GenAI, overview of the space | Background |
| 02_prompt_engineering_part1.pdf | In-context learning, few-shot, instruction tuning | Medium |
| 03_universal_adversarial.pdf | Universal adversarial perturbations for LLMs | **High — SPML Week 6** |
| 04_prompt_engineering_part2.pdf | Advanced prompting, chain-of-thought, ReAct | Medium |
| 05_llm_agent.pdf | LLM agents, tool use, planning | Medium |
| 06_llm_training.pdf | Pre-training, fine-tuning, RLHF, DPO | **High — SPML Week 5** |
| 07_explainability.pdf | Interpreting LLMs, probing, attention visualization | High (your XAI background) |
| 08_transformer_internals.pdf | Multi-head attention, positional encoding deep dive | High |
| 09_ai_ethics.pdf | Bias, fairness, responsible AI | Medium — SPML Week 11 |
| 10_llm_evaluation.pdf | Benchmarks, MMLU, human eval, automated eval | Medium |
| 11_prompt_injection.pdf | Prompt injection attacks, jailbreaking | **Critical — SPML Week 7** |
| 12_llm_strategy.pdf | RAG, retrieval-augmented generation | High — SPML Week 7 |
| 13_vision_language_models.pdf | CLIP, GPT-4V, multimodal models | Medium |
| 14_gpt4o_analysis.pdf | GPT-4o architecture analysis | Low |

---

## Cross-reference with SPML

| SPML Week | Topic | Slides to read first |
|---|---|---|
| 5 | Jailbreaking LLMs | 06_llm_training + `04. LLM Safety/gcg_zou_2023.pdf` |
| 6 | LLM/VLM Adversarial Attacks | 03_universal_adversarial |
| 7 | Prompt Injection + RAG | 11_prompt_injection + 12_llm_strategy |
| 13 | LLM Memorization | 07_explainability |
