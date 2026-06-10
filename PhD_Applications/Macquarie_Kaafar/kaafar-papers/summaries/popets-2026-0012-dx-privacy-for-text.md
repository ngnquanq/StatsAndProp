# Paper Summary: dX-Privacy for Text and the Curse of Dimensionality

**Citation:** Hassan Jameel Asghar, Robin Carpentier, Benjamin Zi Hao Zhao, and Dali Kaafar. 2026. "dX-Privacy for Text and the Curse of Dimensionality." Proceedings on Privacy Enhancing Technologies 2026(1), 224-241. https://doi.org/10.56553/popets-2026-0012  
**Source:** `/home/nhatquang/Desktop/HCMUS Course/PhD_Applications/Macquarie_Kaafar/kaafar-papers/pdfs/popets-2026-0012-dx-privacy-for-text.pdf`  
**One-line takeaway:** The standard word-level multidimensional Laplace mechanism for dX-private text sanitization often returns either the original word or a semantically distant word, and the paper shows that nearest-neighbor post-processing in high-dimensional embedding spaces is the main cause.

## 1. What Problem Is This Paper Solving?

The paper studies a privacy-utility failure in text sanitization methods that apply dX-privacy, also called metric privacy, to word embeddings. In this setting, a word is mapped into an embedding space, multidimensional Laplace noise is added, and the closest vocabulary embedding to the noisy point is returned. Prior work used this mechanism for privacy-preserving text analytics, prompt sanitization, author obfuscation, and related NLP tasks because dX-privacy gives stronger indistinguishability for nearby points than for distant points.

The expected behavior is intuitive: with strong privacy, outputs should often be distant replacements; with weaker privacy, outputs should increasingly be the original word or semantically close neighbors. Instead, the authors observe a peculiar pattern across epsilon values and common embeddings: close semantic neighbors are rarely selected. The mechanism tends to leave the word unchanged or jump to distant, low-utility substitutions. This is serious because text privacy mechanisms are often sold as preserving usable semantic content while hiding sensitive terms.

## 2. Main Contributions

- The paper identifies and empirically demonstrates an unexpected behavior of a widely used word-level dX-private multidimensional Laplace mechanism: close neighbors are almost never output, while original words and distant words dominate.
- It traces the issue to the nearest-neighbor search after noise addition, not to the Laplace noise distribution itself. In high-dimensional embedding spaces, each word behaves like an isolated point because the distance to its nearest neighbor is large relative to the distance gaps among successive neighbors.
- It derives the "noisy dot product" distribution governing nearest-neighbor selection, including the angular component, moments, sub-Gaussian behavior, tail bounds, expectation, and variance.
- It proposes a simple post-processing mitigation: after selecting the nearest neighbor of the noisy embedding, sample from that word's ranked neighbors with probability proportional to `exp(-c * epsilon * rank)`, where `c` is tuned per vocabulary.

## 3. Method Explained

**Intuition:** If noise pushes a word embedding into empty high-dimensional space, the mechanism must map the noisy point back to a real word. The paper shows that this mapping step is biased: because the original word is relatively far from even its nearest neighbor, while successive neighbor distances are separated by small margins, the original word wins too often once epsilon is moderately large. If it does not win, the noisy point may fall closer to a faraway word than to a semantically close neighbor.

**Technical core:**

- The mechanism samples multidimensional Laplace noise by choosing a random direction on the unit hypersphere and a radius from a Gamma distribution, then adds this vector to the original word embedding.
- The sanitized output is the vocabulary embedding nearest to the noisy point under Euclidean distance. This nearest-neighbor step is post-processing, so it preserves dX-privacy.
- The authors derive conditions under which the original word or a neighbor is selected. These conditions depend on a dot product between the noise vector and vectors connecting embeddings.
- They characterize `Z = R * K`, where `R` is the Gamma-distributed noise length and `K` is the cosine of the angle between the noise direction and a fixed embedding direction. The angular component has mean 0, variance `1/n`, and is sub-Gaussian with parameter `1/sqrt(n)`, so high-dimensional noise is nearly orthogonal to any fixed embedding direction.
- Reformulating nearest-neighbor search as a loss function shows that, in expectation, closer words should win. The failure arises from the actual probability gaps: the original-to-nearest-neighbor distance dominates the much smaller differences between close neighbors.

## 4. Experiments And Results

- **Data:** The authors use pretrained word embeddings: GloVe-Twitter with 25, 50, 100, and 200 dimensions and 1,193,514 words; GloVe-Wiki with 50, 100, 200, and 300 dimensions and 400,000 words; Word2Vec with 300 dimensions and 3,000,000 words; and fastText with 300 dimensions and 2,519,370 words.
- **Baselines:** The main comparison is the original multidimensional Laplace dX-private mechanism. They also compare their mitigation with the exponential mechanism used by Yue et al. for natural text sanitization.
- **Metrics:** They track the proportion of outputs that are the original word, one of the first 100 nearest neighbors, or a distant neighbor. They also compute probability terms for nearest-neighbor selection, including average `z` values over 5,000 random words.
- **Key findings:** For GloVe-Wiki and Word2Vec, the original mechanism shows the pathological pattern: close neighbors are rarely selected, and outputs are dominated by original or distant words. Table 2 shows that `z_w,x1`, the term related to original-versus-nearest-neighbor selection, is much larger than `z_x1,x2`, the term for nearest-versus-second-nearest selection. For example, GloVe-Wiki 300d has `z_w,x1 = 2.896` versus `z_x1,x2 = 0.282`, and Word2Vec 300d has `0.763` versus `0.058`. The proposed rank-based post-processing fix produces a more balanced distribution among original, close-neighbor, and distant outputs; the paper reports `c = 0.04` for GloVe-Wiki 300d and `c = 0.007` for Word2Vec.

## 5. Limitations And Risks

- The fix requires empirical tuning of `c` for each vocabulary, so it is not a parameter-free theory-to-practice solution.
- The evaluation focuses on word-level behavior, not full downstream privacy leakage, adversarial reconstruction, grammar quality, or task accuracy after sanitization.
- The mechanism still works token by token, so it may break syntax, entity consistency, and sentence-level meaning unless another post-processing model is used.
- The proposed rank-based sampling is a post-processing fix, not a new metric. The paper explicitly leaves open the problem of constructing a valid distance metric that flattens nearest-neighbor gaps while satisfying metric properties.
- The analysis assumes public, fixed embedding spaces and Euclidean nearest-neighbor lookup. Results may differ for contextual embeddings, sentence embeddings, domain-specific security corpora, or LLM-internal representations.

## 6. Why This Matters For You

For Nguyen Nhat Quang's IAM/security-ML PhD direction, this paper is useful because it connects privacy mechanisms, high-dimensional ML representations, and security deployment risk. IAM and security analytics often involve sensitive textual artifacts: access requests, incident tickets, audit logs, policy justifications, emails, prompts, and analyst notes. A sanitization mechanism that appears formally private but mostly preserves the original token or destroys utility can create false assurance in privacy-preserving pipelines.

The paper is also a strong example of detector-aware and mechanism-aware critique. It does not merely report bad utility; it identifies where the formal mechanism interacts badly with representation geometry. That style is relevant for security-ML research, where systems often fail at the boundary between a mathematical guarantee and the data representation used in deployment. For PhD preparation, this paper can support a research narrative around privacy-preserving security analytics, prompt/data sanitization before cloud LLM use, and rigorous evaluation of ML-based privacy controls.

## 7. How To Use This Paper

- **Cite it for:** Evidence that word-level dX-private text sanitization with multidimensional Laplace noise and nearest-neighbor decoding can have poor semantic utility because close embedding neighbors are rarely selected.
- **Cite it for:** A mathematical explanation of how high-dimensional embedding geometry and noisy dot products affect nearest-neighbor post-processing.
- **Cite it for:** A practical mitigation that preserves privacy as post-processing while improving output behavior through rank-based neighbor sampling.
- **Do not cite it for:** A complete solution to private text release, sentence-level privacy, LLM prompt privacy, or end-to-end security-log anonymization. The paper does not establish those broader claims.
- **Follow-up reading:** Read Feyisetan et al. 2020 on calibrated multivariate perturbations, Mattern et al. 2022 on limits of word-level differential privacy, Yue et al. 2021 on natural text sanitization, and recent reconstruction attacks on differentially private text sanitization to connect this mechanism-level critique to adversarial evaluation.
