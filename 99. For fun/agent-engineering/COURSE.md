# Stanford CS329Z: Engineering AI Agents

Source: https://cs329z.stanford.edu/
Last checked: 2026-11-10T13:27:54.237Z

The Stanford schedule is tentative. Dates and times below are copied from the course site; deadlines use Pacific time.

## Lectures

### Week 1 · Wed Sep 23 · Introduction — What Are Agentic Systems?

Theme: Foundations & Landscape

Course logistics, a brief history of agents, and the anatomy of an agent: LLM core, reasoning, memory, tools, and environment. Compound AI systems and workflows vs. agents, plus the key challenges of reliability, training, safety, and evaluation.

Materials: [Slides](https://web.stanford.edu/class/cs329z/slides/lecture01.pdf) · [Video](https://youtu.be/DGI4vucR71w)

Readings:

- [Zaharia et al. "The Shift from Models to Compound AI Systems." BAIR Blog (2024).](https://bair.berkeley.edu/blog/2024/02/18/compound-ai-systems/)
- [Weng. "LLM Powered Autonomous Agents." Lil'Log (2023).](https://lilianweng.github.io/posts/2023-06-23-agent/)
- [Kapoor et al. "AI Agents That Matter." TMLR (2025).](https://arxiv.org/abs/2407.01502)

### Week 2 · Mon Sep 28 · LLMs for Builders

Language model internals for agent builders: decoding strategies, transformer attention (including linear and hybrid) and context length, the pretraining-to-post-training pipeline, inference and test-time scaling, structured I/O and constrained decoding, and context engineering.

Materials: [Slides](https://web.stanford.edu/class/cs329z/slides/lecture02.pdf)

Readings:

- [Vaswani et al. "Attention Is All You Need." NeurIPS (2017).](https://arxiv.org/abs/1706.03762)
- [Katharopoulos et al. "Transformers are RNNs: Fast Autoregressive Transformers with Linear Attention." ICML (2020).](https://arxiv.org/abs/2006.16236)
- [Rajasekaran et al. "Effective Context Engineering for AI Agents." Anthropic (2025).](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)

### Week 2 · Wed Sep 30 · Retrieval-Augmented Generation (RAG)

Theme: Building Blocks

Why retrieval helps, then the RAG pipeline end to end: indexing (chunking, contextual retrieval, RAPTOR, HNSW), retrievers from BM25 and DPR to hybrid search, reranking, and ColBERT, agentic RAG (Self-RAG, Search-R1), and common failure modes. Plus a course project overview.

Materials: [Slides](https://web.stanford.edu/class/cs329z/slides/lecture03.pdf)

Readings:

- [Lewis et al. "Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks." NeurIPS (2020).](https://arxiv.org/abs/2005.11401)
- [Karpukhin et al. "Dense Passage Retrieval for Open-Domain Question Answering." EMNLP (2020).](https://arxiv.org/abs/2004.04906)
- [Khattab & Zaharia. "ColBERT: Efficient and Effective Passage Search via Contextualized Late Interaction over BERT." SIGIR (2020).](https://arxiv.org/abs/2004.12832)

### Week 3 · Mon Oct 5 · Tool Use & Function Calling

Why LLMs need tools and how they learn to use them: Toolformer, scaling to thousands of APIs with Gorilla and ToolLLM, standard interfaces from REST to function calling to MCP, evaluating tool use with BFCL, ToolBench, and τ-bench, and common failure modes.

Materials: [Slides](https://web.stanford.edu/class/cs329z/slides/lecture04.pdf)

Readings:

- [Schick et al. "Toolformer: Language Models Can Teach Themselves to Use Tools." NeurIPS (2023).](https://arxiv.org/abs/2302.04761)
- [Patil et al. "Gorilla: Large Language Model Connected with Massive APIs." NeurIPS (2024).](https://arxiv.org/abs/2305.15334)
- [Model Context Protocol Specification, revision 2025-06-18. modelcontextprotocol.io (2025).](https://modelcontextprotocol.io/specification/2025-06-18)

### Week 3 · Wed Oct 7 · Frameworks & Orchestration

Theme: Frameworks & Agent Design

The data, system, and evals pillars of agent engineering, with live demos of DSPy (signatures, modules, optimizers) and LangGraph (state, nodes, edges). A tour of open-source agent harnesses (mini-SWE-agent, OpenHands, Pi), durable orchestration with Temporal, observability tooling, and best practices.

Materials: [Slides](https://web.stanford.edu/class/cs329z/slides/lecture05.pdf) · [Code](https://github.com/cs329z/lecture5-frameworks)

Readings:

- [Khattab et al. "DSPy: Compiling Declarative Language Model Calls into Self-Improving Pipelines." ICLR (2024).](https://arxiv.org/abs/2310.03714)
- [LangChain. "LangGraph Overview." LangChain Docs.](https://docs.langchain.com/oss/python/langgraph/overview)
- [Arena.ai. "HarnessTax: How Much Does the Harness Matter for Coding Agents?" Arena Blog (2026).](https://arena.ai/blog/coding-agents-harness-tax)

### Week 4 · Mon Oct 12 · Agent Design Patterns & Scaffolds

Workflows vs. agents and the design patterns for each: five composable workflow patterns, reasoning and acting patterns (ReAct, Reflexion, CodeAct, ReWOO), and context-management patterns (event logs, compaction, observation masking, context isolation). Case study of the Pi harness.

Materials: [Slides](https://web.stanford.edu/class/cs329z/slides/lecture06.pdf)

Readings:

- [Yao et al. "ReAct: Synergizing Reasoning and Acting in Language Models." ICLR (2023).](https://arxiv.org/abs/2210.03629)
- [Schluntz & Zhang. "Building Effective AI Agents." Anthropic (2024).](https://www.anthropic.com/engineering/building-effective-agents)
- [LangChain. "Context Engineering." LangChain Blog (2025).](https://www.langchain.com/blog/context-engineering-for-agents)
- [Shinn et al. "Reflexion: Language Agents with Verbal Reinforcement Learning." NeurIPS (2023).](https://arxiv.org/abs/2303.11366)
- [Wang et al. "Executable Code Actions Elicit Better LLM Agents." ICML (2024).](https://arxiv.org/abs/2402.01030)

### Week 4 · Wed Oct 14 · Agent Memory Architectures

Theme: Memory & Multi-Agent Systems

Why agents need memory and the four types (working, episodic, semantic, procedural). Four architecture patterns: skill libraries, tiered hierarchies like MemGPT, reflective consolidation, and memory maintenance. Memory benchmarks and open problems in forgetting, privacy, and over-personalization.

Materials: [Slides](https://web.stanford.edu/class/cs329z/slides/lecture07.pdf)

Readings:

- [Sumers et al. "Cognitive Architectures for Language Agents." TMLR (2024).](https://arxiv.org/abs/2309.02427)
- [Packer et al. "MemGPT: Towards LLMs as Operating Systems." arXiv (2023).](https://arxiv.org/abs/2310.08560)
- [Park et al. "Generative Agents: Interactive Simulacra of Human Behavior." UIST (2023).](https://arxiv.org/abs/2304.03442)

### Week 5 · Mon Oct 19 · Multi-Agent Systems

When to use single vs. multi-agent systems and how to build them: orchestration patterns (orchestrator, swarm, hybrid), communication through handoffs, message boards, and the A2A protocol, and coordination infrastructure (task ledgers, shared memory, worktree isolation). Why multi-agent systems fail.

Materials: [Slides](https://web.stanford.edu/class/cs329z/slides/lecture08.pdf)

Readings:

- [Wu et al. "AutoGen: Enabling Next-Gen LLM Applications via Multi-Agent Conversation." COLM (2024).](https://arxiv.org/abs/2308.08155)
- [Cemri et al. "Why Do Multi-Agent LLM Systems Fail?" NeurIPS Datasets & Benchmarks (2025).](https://arxiv.org/abs/2503.13657)
- [Kim et al. "Towards a Science of Scaling Agent Systems." arXiv (2025).](https://arxiv.org/abs/2512.08296)

### Week 5 · Wed Oct 21 · Optimization

Theme: Optimization

When optimization pays off and how to do it: context optimization (bootstrapped few-shot, MIPROv2, OPRO, TextGrad, GEPA), weight optimization (SFT on agent rollouts, RL with PPO and GRPO, on-policy distillation), agents as optimizers (Darwin Gödel Machine, autoresearch), and when to optimize prompts vs. weights.

Materials: [Slides](https://web.stanford.edu/class/cs329z/slides/lecture09.pdf)

Readings:

- [Agrawal et al. "GEPA: Reflective Prompt Evolution Can Outperform Reinforcement Learning." ICLR (2026).](https://arxiv.org/abs/2507.19457)
- [Opsahl-Ong et al. "Optimizing Instructions and Demonstrations for Multi-Stage Language Model Programs." EMNLP (2024).](https://arxiv.org/abs/2406.11695)
- [Shao et al. "DeepSeekMath: Pushing the Limits of Mathematical Reasoning in Open Language Models." arXiv (2024).](https://arxiv.org/abs/2402.03300)

### Week 6 · Mon Oct 26 · 📺 Guest Lecture: Terminal-Bench

Ryan Marten and Alex Shaw (Laude Institute), co-creators of Terminal-Bench, on benchmarking how well AI agents accomplish real-world tasks in a terminal environment.

Materials: [Ryan Marten](https://ryanmarten.com/) · [Alex Shaw](https://www.alexgshaw.com/) · [Slides](https://web.stanford.edu/class/cs329z/slides/lecture10.pdf)

Readings:

- [Terminal-Bench project site (leaderboard, tasks, and harness).](https://www.tbench.ai/)
- [Merrill et al. "Terminal-Bench: Benchmarking Agents on Hard, Realistic Tasks in Command Line Interfaces." ICLR (2026).](https://arxiv.org/abs/2601.11868)

### Week 6 · Wed Oct 28 · What Data Do Agents Need?

Theme: Data for Agentic Systems

Traces, demonstrations, and feedback, data for optimization vs. evaluation, data flywheels, synthetic data generation, and collecting data from human-agent interaction.

Materials: [Slides](https://web.stanford.edu/class/cs329z/slides/lecture11.pdf)

Readings:

- [Shankar. "Data Flywheels for LLM Applications." (2024).](https://www.sh-reya.com/blog/ai-engineering-flywheel/)
- [Tan et al. "Large Language Models for Data Annotation and Synthesis: A Survey." EMNLP (2024).](https://aclanthology.org/2024.emnlp-main.54/)

### Week 7 · Mon Nov 2 · Data Selection & Quality

Finding maximally informative data, filtering and selection strategies, tiny-but-targeted benchmarks, annotation practices, quality assessment, and building datasets from agent traces.

Materials: [Slides](https://web.stanford.edu/class/cs329z/slides/lecture12.pdf)

Readings:

- [Yang et al. "SWE-smith: Scaling Data for Software Engineering Agents." NeurIPS D&B (2025).](https://arxiv.org/abs/2504.21798)
- [Shankar et al. "Who Validates the Validators? Aligning LLM-Assisted Evaluation with Human Preferences." UIST (2024).](https://arxiv.org/abs/2404.12272)
- [Zhou et al. "LIMA: Less Is More for Alignment." NeurIPS (2023).](https://arxiv.org/abs/2305.11206)

### Week 7 · Wed Nov 4 · Evaluation Fundamentals & Benchmark Design

Theme: Evaluation for Agentic Systems

Why evals are hard, the 4-tuple framework (request, environment, stopping criteria, scorer), designing each component, properties of good benchmarks, realistic scaffolding, and reliability dimensions.

Materials: [Slides](https://web.stanford.edu/class/cs329z/slides/lecture13.pdf)

Readings:

- [Zhu et al. "Establishing Best Practices for Building Rigorous Agentic Benchmarks." (2025).](https://arxiv.org/abs/2507.02825)
- [Press. "How to Build Good Language Modeling Benchmarks." (2024).](https://ofir.io/How-to-Build-Good-Language-Modeling-Benchmarks/)
- [Polo et al. "tinyBenchmarks: Evaluating LLMs with Fewer Examples." ICML (2024).](https://arxiv.org/abs/2402.14992)

### Week 8 · Mon Nov 9 · 📺 Fireside Chat with Andrew Ng

A fireside chat with Andrew Ng, hosted by Diyi Yang. Professor Ng is the founder of DeepLearning.AI, co-founder of Coursera, founding lead of Google Brain, and an Adjunct Professor of Computer Science at Stanford.

Materials: [Andrew Ng](https://www.andrewng.org/)

### Week 8 · Wed Nov 11 · LLM-as-Judge & Evaluation Infrastructure

The three grader types, designing judge prompts, known biases, pairwise vs. pointwise evaluation, non-determinism metrics (pass@k vs. pass^k), harness design, and Anthropic's 8-step roadmap.

Readings:

- [Grace et al. "Demystifying Evals for AI Agents." Anthropic (2026).](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents)
- [Zheng et al. "Judging LLM-as-a-Judge with MT-Bench and Chatbot Arena." NeurIPS (2023).](https://arxiv.org/abs/2306.05685)
- [Ryan et al. "AutoMetrics: Approximate Human Judgements with Automatically Generated Evaluators." ICLR (2026).](https://arxiv.org/abs/2512.17267)
- [Zhu et al. "AutoLibra: Agent Metric Induction from Open-Ended Human Feedback." ICLR (2026).](https://openreview.net/forum?id=4BjGVZ7Bxn)

### Week 9 · Mon Nov 16 · 📺 Guest Lecture: SWE-bench

Carlos Jimenez and Alexander Wettig (Anthropic), creators of SWE-bench, on the evolution and future of evaluations for coding capabilities and beyond.

Materials: [Carlos Jimenez](https://www.carlosejimenez.com/) · [Alexander Wettig](https://codecreator.github.io/)

Readings:

- [Jimenez et al. "SWE-bench: Can Language Models Resolve Real-World GitHub Issues?" ICLR (2024).](https://arxiv.org/abs/2310.06770)

### Week 9 · Wed Nov 18 · Agent Safety & Guardrails

Theme: Safety

Privacy risks of tool access, prompt injection (including indirect injection), red-teaming, sandboxing and permission models, output guardrails, liability considerations, responsible deployment, and human-in-the-loop patterns.

Readings:

- [Shao et al. "PrivacyLens: Evaluating Privacy Norm Awareness of LMs in Action." NeurIPS D&B (2024).](https://arxiv.org/abs/2409.00138)
- [Zhang & Yang. "Searching for Privacy Risks in LLM Agents via Simulation." arXiv (2025).](https://arxiv.org/abs/2508.10880)
- [Li. "Agentic LLMs as Powerful Deanonymizers." arXiv (2026).](https://arxiv.org/abs/2601.05918)
- [Wen et al. "Contextualized Privacy Defense for LLM Agents." arXiv (2026).](https://arxiv.org/abs/2603.02983)
- [OpenAI. "Understanding Prompt Injections: A Frontier Security Challenge." (2025).](https://openai.com/index/prompt-injections/)
- [Anthropic. "Anthropic's Responsible Scaling Policy." (2023).](https://www.anthropic.com/news/anthropics-responsible-scaling-policy)

### Week 10 · Mon Nov 23 · No Class — Thanksgiving Recess

### Week 10 · Wed Nov 25 · No Class — Thanksgiving Recess

### Week 11 · Mon Nov 30 · Coding & Software Agents

Theme: Coding Agents & Proactive Agents

How coding agents work end to end: the SWE-agent, Claude Code, and OpenHands architectures, scaffolds as design decisions, SWE-bench and the 4-tuple framework in practice, and the future of software development with agents.

Readings:

- [Yang et al. "SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering." NeurIPS (2024).](https://arxiv.org/abs/2405.15793)
- [Wang et al. "OpenHands: An Open Platform for AI Software Developers." ICLR (2025).](https://arxiv.org/abs/2407.16741)
- [Anthropic. "Claude Code: Best Practices for Agentic Coding." (2025).](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Young. "Effective Harnesses for Long-Running Agents." Anthropic (2025).](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)

### Week 11 · Wed Dec 2 · Proactive Agents

From reactive to proactive agents: General User Models (GUM), Next Action Prediction, open-source proactive personal agents, privacy and trust implications, and when agents should initiate vs. wait (mixed initiative).

Readings:

- [Shaikh et al. "Creating General User Models from Computer Use." UIST (2025).](https://arxiv.org/abs/2505.10831)
- [Shaikh et al. "Learning Next Action Predictors from Human-Computer Interaction." arXiv (2026).](https://arxiv.org/abs/2603.05923)
- [Steinberger. "OpenClaw: Open-source proactive AI agent." (2025).](https://github.com/openclaw/openclaw)

### Week — · Wed Dec 9 · Final Project Demo Day

Theme: Open Problems & Final Demos

Held during the end-quarter examination period, 3:30–6:30 p.m. Location TBA.

## Deadlines

| Week | Item | Date | Time (Pacific) |
| --- | --- | --- | --- |
| 3 | [HW1 Released](https://github.com/cs329z/assignment1-harness) | Mon Oct 5 | — |
| 3 | Project Proposal Due | Fri Oct 9 | 11:59 p.m. |
| 6 | HW1 Due | Fri Oct 30 | 11:59 p.m. |
| 6 | [HW2 Released](https://github.com/cs329z/assignment2-harness) | Sun Nov 1 | — |
| 7 | Midpoint Demo Video Due | Fri Nov 6 | 11:59 p.m. |
| 7 | Midway Report Due | Fri Nov 6 | 11:59 p.m. |
| 8 | [Paper Video Due (10–15 min)](https://web.stanford.edu/class/cs329z/assignments/paper_video.pdf) | Fri Nov 13 | 11:59 p.m. |
| 10 | HW2 Task Submission Due (during Thanksgiving Break) | Mon Nov 23 | 11:59 p.m. |
| 11 | Paper Video Peer Reviews Due (2 videos) | Mon Nov 30 | 11:59 p.m. |
| 11 | HW2 Peer Reviews Due (3 tasks) | Wed Dec 2 | 11:59 p.m. |
| Finals | Final System Demo (Demo Day) | Wed Dec 9 | 3:30–6:30 p.m. |
| Finals | Final Report Due | Fri Dec 11 | 11:59 p.m. |

## Course pages

- [CS329Z Home](https://cs329z.stanford.edu/index.html)
- [Logistics](https://cs329z.stanford.edu/logistics.html)
- [Project](https://cs329z.stanford.edu/project.html)
