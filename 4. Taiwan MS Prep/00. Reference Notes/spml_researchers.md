# Key Researchers in SPML

The people whose papers you'll cite, whose work you need to know, and who define the field Chen operates in.

---

## The Inner Circle (papers you already have)

| Researcher | Institution | What they're known for | Papers in your folder |
|---|---|---|---|
| **Nicholas Carlini** | Google DeepMind | MIA, extracting training data from LLMs, memorization — the most cited person in privacy attacks right now. Actively publishing in 2025–2026 on LLM deanonymization. | `lira_carlini_2022.pdf`, `extracting_training_data_carlini_2021.pdf` |
| **Reza Shokri** | NUS Singapore | Invented the shadow model MIA framework. Now at NUS Singapore. | `membership_inference_shokri_2017.pdf` |
| **Nicolas Papernot** | U of Toronto / Google | Foundational SPML taxonomy, distillation defenses, PATE (private aggregation of teacher ensembles). Co-authored the survey in `11. Survey Papers/`. | `adversarial_ml_survey_papernot_2016.pdf` |
| **Aleksander Mądry** | MIT | PGD adversarial training. His 2018 paper redefined how the field thinks about robustness. | `pgd_madry_2018.pdf` |
| **Matt Fredrikson** | CMU | Original model inversion paper (2015). His threat model is what Trap-MID defends against. | `model_inversion_fredrikson_2015.pdf` |

---

## The Extended Network (know their names, read abstracts)

| Researcher | Institution | Specific focus |
|---|---|---|
| **Florian Tramèr** | ETH Zurich | Adaptive attacks (shows why many defenses are broken), privacy side channels, now collaborating with Carlini on LLM deanonymization (2026) |
| **Bo Li** | U of Chicago | Trustworthy ML — combines robustness + privacy + fairness, similar scope to Chen's lab |
| **Zico Kolter** | CMU | Certified defenses via convex relaxations, co-authored with Mądry |
| **Aditi Raghunathan** | CMU | Certified defenses, SDP-based verification |
| **Vitaly Feldman** | Apple | Memorization in ML — why neural nets memorize training data |
| **Cho-Jui Hsieh** | UCLA | Certified defenses, also Taiwanese — secondary backup advisor option |

---

## Where Chen sits in this map

Chen is in the same publication tier (NeurIPS/ICML/ICLR) as everyone above. His specific edge:

- Works on **both attack and defense** simultaneously (DRAG = attack, Trap-MID = defense)
- Bridges **privacy + robustness** in single papers (most researchers specialize in one)
- One of very few in **Asia** doing this at top-venue level

The gap nobody has filled: privacy attacks on **non-image, behavioral/tabular data**. Carlini, Shokri, Fredrikson all work on image models or language models. Your CERT insider threat angle sits in a blind spot for the entire field.

---

## Who to follow actively

Before the cold email (Oct 2026), read the abstracts of anything new from:
- Nicholas Carlini: https://nicholas.carlini.com/papers
- Shang-Tse Chen: https://www.csie.ntu.edu.tw/~stchen/
- Florian Tramèr: https://floriantramer.com/publications/

New papers from Chen are the most important — if he publishes something new between now and Oct 2026, that becomes your cold email hook.
