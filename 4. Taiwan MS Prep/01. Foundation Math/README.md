# Foundation Math

## Files

- **how_to_write_research_paper_spj.pdf** — Simon Peyton Jones, "How to Write a Great Research Paper". Read this before you write anything. 7 pages.

## Reading order

1. **Information Theory** (not a file here — read online)
   - Cover & Thomas, *Elements of Information Theory*, Ch 1–2 only
   - Free access: search "Cover Thomas Elements Information Theory PDF" — widely mirrored
   - Key concepts: entropy H(X), mutual information I(X;Y), KL divergence, Rényi divergence
   - Why: membership inference is formally about information leakage. Chen's papers use this language.

2. **Statistical Learning Theory** (not a file here — read online)
   - Hastie, Tibshirani, Friedman, *The Elements of Statistical Learning* — free PDF at https://web.stanford.edu/~hastie/ElemStatLearn/
   - Read Ch 2 (supervised learning overview) and Ch 7 (model assessment and selection)
   - Key concepts: bias-variance tradeoff, VC dimension intuition, generalization

3. **how_to_write_research_paper_spj.pdf**
   - Read before writing your cold email framing and portfolio project README
   - Core lesson: lead with the problem, not the solution

## Key concepts to be solid on before touching adversarial ML papers

| Concept | Why |
|---|---|
| Entropy, mutual information | Privacy attacks = information leakage |
| KL divergence | Appears in every adversarial training loss |
| Concentration inequalities (Hoeffding) | Randomized smoothing certification proofs |
| Minimax optimization | Adversarial training is a minimax problem |
| Likelihood ratio test | Membership inference (LiRA) is a hypothesis test |
