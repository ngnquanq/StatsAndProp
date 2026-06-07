# Generative Models
**Area:** VAE, GAN, Diffusion Models
**Why it matters:** Chen's DRAG paper (ICML 2025) uses guided diffusion for model inversion. KEDMI uses GANs. You need to understand generative models to extend this work.

---

## Papers downloaded

| File | What it covers |
|---|---|
| vae_kingma_2014.pdf | Variational Autoencoder — latent space, ELBO, reparameterization trick |
| gan_goodfellow_2014.pdf | Original GAN paper — adversarial generator/discriminator training |
| ddpm_ho_2020.pdf | Denoising Diffusion Probabilistic Models — the diffusion training objective |
| stable_diffusion_rombach_2022.pdf | Latent Diffusion Models — how Stable Diffusion works |
| score_matching_song_2020.pdf | Score-based generative models — the theoretical foundation of diffusion |

---

## Reading order

1. **vae_kingma_2014** — latent space concept used in model inversion attacks
2. **gan_goodfellow_2014** — adversarial training; KEDMI uses a GAN for model inversion
3. **ddpm_ho_2020** — the diffusion training objective Chen's DRAG paper builds on
4. **stable_diffusion_rombach_2022** — how diffusion works in latent space
5. **score_matching_song_2020** — theoretical depth (optional unless your thesis extends DRAG)

---

## Connection to Chen's lab work

| Chen's paper | Generative model used | Your need |
|---|---|---|
| DRAG (ICML 2025) | Guided diffusion for reconstruction | Understand DDPM + score functions |
| KEDMI baseline | GAN-based model inversion | Understand GAN training |
| Trap-MID defense | GAN-based attack to defend against | Understand how GAN attacks work |

**Practical note:** You don't need to implement these from scratch. Use Hugging Face `diffusers` library for diffusion experiments. But reading the DDPM and VAE papers gives you the vocabulary to discuss DRAG intelligently with Chen.
