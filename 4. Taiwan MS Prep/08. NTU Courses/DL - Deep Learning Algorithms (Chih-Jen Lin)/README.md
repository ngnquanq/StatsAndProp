# Deep Learning Algorithms and Implementations — Chih-Jen Lin
**Instructor:** Chih-Jen Lin (creator of LIBSVM, one of the most cited ML researchers)
**Credits:** 3 | **Meeting:** Tuesdays 10:20am–1pm
**Course page:** https://www.csie.ntu.edu.tw/~cjlin/courses/optdl2025/

This is the engineering course — not "how to use PyTorch" but how PyTorch actually works. Heavy on implementation. You'll build autograd from scratch and understand why GPU matrix multiplication matters.

---

## Slides downloaded

| File | Topic |
|---|---|
| tiled_matrix_products.pdf | Matrix-matrix multiplication, tiling for cache efficiency, BLAS |
| autodiff.pdf | Automatic differentiation — forward mode, reverse mode, implementation |
| LLM_transformer.pdf | Transformer internals: attention, positional encoding, layer norm |
| LLM_flashattention.pdf | FlashAttention: IO-aware exact attention algorithm |
| flashattention_paper_dao_2022.pdf | FlashAttention paper (arXiv:2205.14135) — Tri Dao et al. |

**Note:** BLAS slides (blas_optblas1/2) require institutional access — not publicly downloadable. Covered by `tiled_matrix_products.pdf` instead.

---

## Course structure

| Block | Topics |
|---|---|
| Optimization problems | Linear classification, fully-connected nets, CNNs |
| SGD methods | Gradient descent, SGD, momentum, Adam, convergence proofs |
| Gradient computation | Backprop in matrix/vector form, multi-layer chain rule |
| Implementation | BLAS, tiled matrix multiply, GPU via CUDA/cuBLAS |
| Automatic differentiation | Build autograd from scratch (simpleNN, HIPS/autograd) |
| LLMs | Transformer ops, FlashAttention, NanoGPT walkthrough |

---

## What you'll build

The course project involves implementing pieces from scratch:
- A simple neural network library (like micrograd/simpleNN)
- Efficient matrix multiply with tiling
- A simplified transformer forward pass

**Reference repos used in the course:**
- https://github.com/cjlin1/simpleNN — Lin's own simple NN implementation
- https://github.com/HIPS/autograd — pure Python autograd (study this)
- https://github.com/openai/gpt-2 — read the GPT-2 code

---

## Why this matters for Chen's lab

Chen's privacy attack papers (Trap-MID, DRAG) require:
- Understanding how gradients flow through a model (for model inversion)
- Knowing how training works at a low level (for membership inference)
- Being able to modify training loops (for DP-SGD with Opacus)

This course gives you the depth to modify and extend models, not just call `model.fit()`.
