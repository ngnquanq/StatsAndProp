# NLP / Advanced Deep Learning — Yun-Nung (Vivian) Chen
**Instructor:** Yun-Nung Chen (NTU CSIE — dialogue systems, NLP)
**Credits:** 3 | **Area:** Natural Language Processing
**Note:** Slides not publicly posted. Papers below are the foundation papers for the course.

---

## Foundation papers downloaded

| File | What it covers |
|---|---|
| attention_is_all_you_need_vaswani_2017.pdf | The transformer architecture — everything in NLP builds on this |
| bert_devlin_2019.pdf | BERT: bidirectional encoder, masked LM pre-training |
| gpt3_brown_2020.pdf | GPT-3: few-shot learning at scale, in-context learning |
| chain_of_thought_wei_2022.pdf | Chain-of-thought prompting: making LLMs reason step by step |
| rag_lewis_2020.pdf | Retrieval-Augmented Generation — relevant to SPML Week 7 (RAG security) |

---

## Reading order

1. **attention_is_all_you_need** — understand the transformer before anything else
   - Also read: `09. Pre-Taiwan Online Courses/Stanford CS229/cs224n_transformers_self_attention.pdf`
2. **bert_devlin_2019** — how BERT extends the transformer for understanding tasks
   - Also read: `09. Pre-Taiwan Online Courses/Hung-yi Lee ML 2023/02_bert_transformers.pdf`
3. **gpt3_brown_2020** — how scale changes everything; emergence of few-shot ability
4. **chain_of_thought_wei_2022** — prompting paradigm shift
5. **rag_lewis_2020** — retrieval augmented generation; read before SPML Week 7

---

## Why take this course (for your direction)

Chen's LLM safety work (EMNLP 2024 on model merging) and the SPML jailbreaking weeks assume you understand:
- How transformers process tokens
- What fine-tuning does to model weights
- What "in-context learning" means mechanistically

This course gives you that foundation. Take it in Semester 2 after SPML — you'll understand the SPML LLM weeks better with this background.

---

## Supplement (already in folder `09. Pre-Taiwan Online Courses/Hung-yi Lee GenAI 2024`)

| Slide | Topic |
|---|---|
| 08_transformer_internals.pdf | Deep dive into attention mechanism |
| 06_llm_training.pdf | Pre-training → fine-tuning → RLHF |
| 05_llm_agent.pdf | LLM agents and tool use |
