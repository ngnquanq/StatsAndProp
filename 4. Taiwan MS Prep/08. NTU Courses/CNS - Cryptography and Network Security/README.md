# Cryptography and Network Security (CSIE 7190) — Hsu-Chun Hsiao
**Instructor:** Hsu-Chun Hsiao (network security, applied cryptography)
**Credits:** 3 | **Format:** Seminar + group project
**Course page:** https://www.csie.ntu.edu.tw/~hchsiao/courses/cns24.html

A paper-reading seminar on applied cryptography and security. More conceptual than mathematical — focuses on understanding protocols and attacks rather than proving theorems. Good complement to SPML for the security vocabulary.

---

## Files downloaded

| File | Topic |
|---|---|
| diffie_hellman_1976.pdf | Original Diffie-Hellman key exchange paper (1976) — foundational |
| signal_protocol_analysis.pdf | Formal analysis of Signal Protocol (arXiv:1601.00795) — modern secure messaging |
| tls13_formal_analysis.pdf | Formal security analysis of TLS 1.3 (arXiv:1907.02425) |

**Note:** Course slides are not publicly posted — available through NTU COOL after enrollment.

---

## Course syllabus (Spring 2024)

| Week | Topic |
|---|---|
| 1 | Course intro |
| 2 | Security & crypto overview |
| 3 | Randomness, hash functions |
| 4 | Symmetric cryptography (AES, modes of operation) |
| 5 | Asymmetric cryptography (RSA, ECC) |
| 6 | Key management |
| 7 | Project overview |
| 8 | Authentication (passwords, MFA, WebAuthn) |
| 9 | Anonymity & privacy (Tor, mixnets) |
| 10 | Internet insecurity (BGP hijacking, DNS poisoning) |
| 11 | TLS and MLS protocols |
| 12 | Midterm exam |
| 13 | DDoS attacks |
| 14 | Advanced topics |
| 15–16 | Group project presentations |

---

## Key concepts to take from this course

| Concept | Why it matters for your research |
|---|---|
| Differential privacy (formal) | Connects to DP-SGD in your portfolio project |
| Authentication systems | IAM domain — SailPoint/CyberArk protocols |
| Anonymity guarantees | Formal privacy vs. empirical privacy in ML |
| TLS internals | Relevant to enterprise security pipelines |
| Threat modeling | STRIDE — use for framing your portfolio project's threat model |

---

## Recommended self-study (before the course)

1. **diffie_hellman_1976.pdf** — 7 pages, very readable. Understand key exchange before the course.
2. **signal_protocol_analysis.pdf** — how modern secure messaging achieves forward secrecy. Good model for thinking about privacy guarantees.
3. Watch: "Introduction to Cryptography" by Christof Paar (YouTube, free) — if you have zero crypto background

---

## Priority relative to other courses

**Take this in Semester 2**, after SPML and ML. It's useful but not critical for Chen's lab specifically. Skip it for Semester 3 if your thesis direction is clearly privacy attacks on ML — the CNS material won't appear in your thesis. Take it for the security vocabulary and networking context it provides.
