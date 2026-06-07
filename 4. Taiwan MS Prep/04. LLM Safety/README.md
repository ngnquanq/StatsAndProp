# LLM Safety

Chen's lab has expanded into LLM safety. You don't need to be an expert here for the cold email — your thesis will be in privacy attacks. But you need enough fluency to discuss Chen's EMNLP 2024 and jailbreaking work intelligently.

## Reading order

| # | File | What it covers | Time |
|---|---|---|---|
| 1 | instructgpt_rlhf_ouyang_2022.pdf | How ChatGPT-style alignment works: supervised fine-tuning → reward model → PPO. The foundational RLHF paper. | 3 hrs |
| 2 | dpo_rafailov_2023.pdf | Direct Preference Optimization — RLHF without a separate reward model. Simpler, widely adopted. Chen's model merging paper builds on this space. | 2 hrs |
| 3 | gcg_zou_2023.pdf | GCG: the first practical automated jailbreak. Finds adversarial suffixes that transfer across models. Core paper in Chen's SPML syllabus Week 5. | 3 hrs |
| 4 | autodan_liu_2023.pdf | AutoDAN: readable jailbreaks via genetic search. Harder to filter than GCG. | 2 hrs |

## Key concepts

**RLHF pipeline:** Pretrain → supervised fine-tune on demonstrations → train reward model → PPO against reward model
**DPO:** Skip the reward model. Directly optimize on (chosen, rejected) response pairs.
**Jailbreaking:** Find input x (or suffix appended to x) such that a safety-trained model produces harmful output.
- GCG: gradient-based search over token space → transferable suffixes
- AutoDAN: readable natural language jailbreaks via genetic algorithms

**Model merging (Chen's EMNLP 2024):** Merging a safety-tuned model with a task-specific model via task vectors (TIES/DARE). Chen showed this can both preserve capabilities and maintain safety — or be exploited to remove safety.

## What you need to be able to say in Chen's office

> "RLHF aligns models via a reward signal from human preferences. DPO simplifies this by treating alignment as a classification problem on preference pairs. Jailbreaks like GCG show that aligned models are still adversarially fragile — they find token-level perturbations that transfer to black-box models. Your model merging work in EMNLP 2024 takes a different angle: studying alignment as a property of the model's weight space, not just its outputs."

That's enough. You don't need to reproduce GCG to say this correctly.
