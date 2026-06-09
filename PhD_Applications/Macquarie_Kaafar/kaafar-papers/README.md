# Kaafar / Macquarie ISP Papers And Products

Collected: 2026-06-10

This folder is intended to be tracked in git so the papers can be pushed to GitHub. It collects papers and product references relevant to Prof. Dali Kaafar, Macquarie University's Cyber Security Hub, and the Information Security and Privacy (ISP) group.

## Start Here For Your Application

1. `pdfs/2505.08148-custom-gpt-vulnerabilities.pdf`
   - Title: A Large-Scale Empirical Analysis of Custom GPTs' Vulnerabilities in the OpenAI Ecosystem
   - Why it matters: strongest link to your IAM chatbot / RAG work.
   - Source: https://arxiv.org/abs/2505.08148

2. `pdfs/1610.09044-behaviocog-authentication.pdf`
   - Title: BehavioCog: An Observation Resistant Authentication Scheme
   - Why it matters: closest to identity, authentication, and continuous assurance.
   - Source: https://arxiv.org/abs/1610.09044

3. `pdfs/popets-2026-0012-dx-privacy-for-text.pdf`
   - Title: dX-privacy for text and the curse of dimensionality
   - Why it matters: privacy-preserving text/embedding analytics, useful for IAM tickets, access requests, logs, and security text.
   - Source: https://doi.org/10.56553/popets-2026-0012

4. `pdfs/1811.03197-private-continual-release.pdf`
   - Title: Private Continual Release of Real-Valued Data Streams
   - Why it matters: differential privacy for streaming monitoring data; good fit for access-event dashboards and security monitoring.
   - Source: https://arxiv.org/abs/1811.03197

5. `pdfs/2307.01965-scam-baiting-calls.pdf`
   - Title: An analysis of scam baiting calls: Identifying and extracting scam stages and scripts
   - Why it matters: foundation for Apate-style AI scam intelligence; shows applied security NLP and threat-intelligence extraction.
   - Source: https://arxiv.org/abs/2307.01965

## Other Useful Papers

6. `pdfs/2310.02563-private-assurance-fhe.pdf`
   - Title: Practical, Private Assurance of the Value of Collaboration via Fully Homomorphic Encryption
   - Why it matters: privacy-preserving data collaboration with ML; useful for enterprise-sensitive security data.
   - Source: https://arxiv.org/abs/2310.02563

7. `pdfs/1603.06289-tracking-free-web.pdf`
   - Title: Towards Seamless Tracking-Free Web: Improved Detection of Trackers via One-class Learning
   - Why it matters: one-class learning for security/privacy classification; useful pattern for anomaly-style security detection.
   - Source: https://arxiv.org/abs/1603.06289

8. `pdfs/1905.09136-dadidroid-android-malware.pdf`
   - Title: DaDiDroid: An Obfuscation Resilient Tool for Detecting Android Malware via Weighted Directed Call Graph Modelling
   - Why it matters: applied ML/security detection system; good example of tool-building and evaluation.
   - Source: https://arxiv.org/abs/1905.09136

9. `pdfs/2107.07063-blockjack-bgp-hijacking.pdf`
   - Title: BlockJack: Towards Improved Prevention of IP Prefix Hijacking Attacks in Inter-Domain Routing Via Blockchain
   - Why it matters: systems/network security output from the broader group.
   - Source: https://arxiv.org/abs/2107.07063

## Product / System References

- Apate.ai homepage: https://www.apate.ai/
  - AI-powered fraud prevention and scam intelligence platform.

- Apate products: https://www.apate.ai/products
  - Apate Voice: conversational AI bots for scam-call diversion and disruption.
  - Apate Insights: dashboards, real-time alerts, scam intelligence, campaign/tactic extraction.
  - Apate Text: text-native bot engagement across SMS, WhatsApp, Telegram, and similar channels.

- Macquarie project page: Pitting AI Against Phone Scams - A Proactive Defence
  - https://researchers.mq.edu.au/en/projects/pitting-ai-against-phone-scams-a-proactive-defence/

- Macquarie Information Security and Privacy Group
  - https://www.mq.edu.au/faculty-of-science-and-engineering/departments-and-schools/school-of-computing/our-research/the-information-security-and-privacy-isp-group

- Prof. Dali Kaafar profile
  - https://researchers.mq.edu.au/en/persons/dali-kaafar/

## Suggested Reading Order

Read in this order if the goal is to prepare a supervisor email and concept note:

1. Custom GPT vulnerabilities
2. BehavioCog
3. dX-privacy for text
4. Private continual release
5. Scam baiting calls

Then skim DaDiDroid and Tracking-Free Web for examples of evaluation style in applied ML/security work.

## How To Use In Your Pitch

Use these papers to support this research direction:

> Privacy-preserving and explainable AI for identity and access management, focusing on secure IAM analytics, LLM/RAG security, and behavioral access-risk detection.

Do not pitch causal inference as the main topic. Keep it as a method for evaluating policy interventions after the core security/privacy framing is clear.
