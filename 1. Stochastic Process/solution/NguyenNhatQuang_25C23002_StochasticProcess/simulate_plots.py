import numpy as np
import matplotlib.pyplot as plt
import matplotlib
import os

matplotlib.use('Agg')

output_dir = os.path.dirname(os.path.abspath(__file__))

# ── Bài tập 17: White noise ────────────────────────────────────────────────
sigma_W = 0.8
T = 300
t = np.arange(0, T + 1)

fig17, ax17 = plt.subplots(figsize=(10, 4))
for _ in range(5):
    W = np.random.normal(0, sigma_W, size=len(t))
    ax17.plot(t, W, linewidth=0.7)

ax17.set_title(r"White Noise $W_t \overset{\mathrm{i.i.d.}}{\sim} \mathcal{N}(0,\sigma_W^2)$, "
               r"$\sigma_W = 0.8$, 5 realizations")
ax17.set_xlabel(r"$t$")
ax17.set_ylabel(r"$W_t$")
ax17.axhline(0, color='black', linewidth=0.5, linestyle='--')
fig17.tight_layout()
path17 = os.path.join(output_dir, "white_noise.pdf")
fig17.savefig(path17)
print(f"Saved: {path17}")

# ── Bài tập 18: Standard Brownian motion ──────────────────────────────────
fig18, ax18 = plt.subplots(figsize=(10, 4))
for _ in range(3):
    increments = np.random.normal(0, 1, size=T)   # B(t) - B(t-1) ~ N(0,1)
    B = np.concatenate([[0], np.cumsum(increments)])
    ax18.plot(t, B, linewidth=0.7)

ax18.set_title(r"Standard Brownian Motion $B(t)$, 3 realizations")
ax18.set_xlabel(r"$t$")
ax18.set_ylabel(r"$B(t)$")
ax18.axhline(0, color='black', linewidth=0.5, linestyle='--')
fig18.tight_layout()
path18 = os.path.join(output_dir, "brownian_motion.pdf")
fig18.savefig(path18)
print(f"Saved: {path18}")

# ── LaTeX output ──────────────────────────────────────────────────────────
latex = r"""
\begin{figure}[H]
    \centering
    \includegraphics[width=0.9\linewidth]{white_noise.pdf}
    \caption{Bài tập 17: 5 sample paths của White noise process $W_t \overset{\mathrm{i.i.d.}}{\sim} \mathcal{N}(0,\sigma_W^2)$ với $\sigma_W = 0.8$, $t = 0,1,2,\ldots,300$.}
    \label{fig:white_noise}
\end{figure}

\begin{figure}[H]
    \centering
    \includegraphics[width=0.9\linewidth]{brownian_motion.pdf}
    \caption{Bài tập 18: 3 sample paths của Standard Brownian motion $B(t)$, $t = 0,1,2,\ldots,300$.}
    \label{fig:brownian_motion}
\end{figure}
"""

print("\n" + "=" * 60)
print("LaTeX code:")
print("=" * 60)
print(latex)
