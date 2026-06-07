# Hung-yi Lee — Machine Learning 2023 (NTU)
**Instructor:** Hung-yi Lee (NTU EE — most-watched ML course in Chinese-speaking world)
**YouTube:** https://www.youtube.com/watch?v=7XZR0-4uS5s&list=PLJV_el3uVTsPM2mM-OQzJXziCGJa8nJL
**Course page:** https://speech.ee.ntu.edu.tw/~hylee/ml/2023-spring.php

This course covers practical deep learning from scratch through LLMs. Slides are in English, lectures are in Mandarin (with English subtitles available). Watch alongside the PDFs.

---

## Slides downloaded

| File | Topic | Priority |
|---|---|---|
| 01_ml_basics.pdf | Regression, classification, gradient descent, overfitting | High |
| 02_bert_transformers.pdf | BERT, self-attention, transformer architecture | High |
| 03_adversarial_attack.pdf | FGSM, PGD, black-box attacks, adversarial defense overview | **Critical** |
| 04_xai_explainability.pdf | SHAP, LIME, saliency maps, probing | High (you know this) |
| 05_gan.pdf | Generative Adversarial Networks — discriminator/generator training | Medium |
| 06_diffusion_models.pdf | DDPM, score matching — relevant to DRAG paper (Chen's lab) | High |
| 07_large_language_models.pdf | GPT, BERT, scaling laws, emergent abilities | High |
| 08_chatgpt_basics.pdf | ChatGPT architecture, RLHF overview | High |
| 09_prompt_engineering.pdf | In-context learning, chain-of-thought, few-shot | Medium |
| 10_auto_encoder.pdf | VAE, representation learning | Medium |
| 11_domain_adaptation.pdf | Transfer learning, domain shift | Low |
| 12_meta_learning.pdf | MAML, few-shot learning | Low |
| 13_pytorch_tutorial_1.pdf | PyTorch basics: tensors, autograd, Dataset/DataLoader | High |
| 14_pytorch_tutorial_2.pdf | PyTorch advanced: custom modules, training loops | High |
| 15_image_generation.pdf | Image synthesis: GAN vs diffusion comparison | Medium |

---

## Recommended watch order (pre-Taiwan, 4 weeks)

**Week 1:** 01 (ML basics) → 13 (PyTorch 1) → 14 (PyTorch 2)
**Week 2:** 02 (transformers) → 07 (LLMs) → 08 (ChatGPT)
**Week 3:** 03 (adversarial attacks) → 06 (diffusion) → 04 (XAI — review)
**Week 4:** 05 (GAN) → 09 (prompting) → 10 (autoencoder)

**Slide 03 is the most important** — it directly covers Chen's core area. Read it before touching the papers in `02. Adversarial ML/`.
