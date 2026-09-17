# Scientific Agent Skills

A curated collection of **70** scientific and research skills for any AI agent that supports the open [Agent Skills](https://agentskills.io/) standard. These skills turn your coding agent into a research assistant that can run multi-step scientific workflows — searching the literature, querying public databases, analyzing data, training models, and producing publication-ready figures, papers, and reports.

> The agent can already write code with any Python package or call any API. These skills add curated documentation, working examples, and best practices so common research workflows run faster and more reliably.

---

## 📋 Table of Contents

- [Why Use This?](#-why-use-this)
- [Getting Started](#-getting-started)
- [Helper Scripts](#helper-scripts)
- [Prerequisites](#-prerequisites)
- [Security Disclaimer](#%EF%B8%8F-security-disclaimer)
- [Quick Examples](#-quick-examples)
- [Tutorials: How to Use the Skills](#-tutorials-how-to-use-the-skills)
- [Available Skills](#-available-skills)
- [Contributing](#-contributing)
- [Troubleshooting](#-troubleshooting)
- [FAQ](#-faq)
- [License](#-license)

---

## 🚀 Why Use This?

- **Skip the boilerplate** — no more hunting through API docs or wiring up integrations by hand. Each skill ships with tested examples and best practices.
- **Run multi-step workflows from one prompt** — chain literature search, database lookups, analysis, modeling, and reporting in a single request.
- **Reproducible by design** — the `database-lookup` skill makes deterministic REST calls with explicit endpoints, filters, pagination, and provenance.
- **Portable across agents** — one open standard, many hosts (Cursor, Claude Code, Codex, Gemini CLI, Google Antigravity, OpenClaw, Pi, and more).
- **Actively maintained** — continuously updated and security-scanned by the maintainers and community contributors.

---

## 🎯 Getting Started

### Option 1: npx (all platforms)

```bash
npx skills add FCBGP/awsome-idr-skills
```

This is the standard way to install Agent Skills across **all platforms**, including **Claude Code**, **Codex**, **Gemini CLI**, **Google Antigravity**, **Cursor**, **OpenClaw**, **Pi**, and any other agent that supports the open [Agent Skills](https://agentskills.io/) standard.

### Option 2: GitHub CLI (`gh skill`)

With the [GitHub CLI](https://cli.github.com/) (v2.90.0+):

```bash
# Browse and install interactively
gh skill install FCBGP/awsome-idr-skills

# Install a single skill
gh skill install FCBGP/awsome-idr-skills database-lookup

# Target a specific agent host
gh skill install FCBGP/awsome-idr-skills --agent claude-code
gh skill install FCBGP/awsome-idr-skills --agent cursor
gh skill install FCBGP/awsome-idr-skills --agent codex

# Pin to a release tag or commit for reproducible installs
gh skill install FCBGP/awsome-idr-skills --pin v2.52.0

# Keep installed skills up to date
gh skill update --all
```

`gh skill` installs to the right directory for your agent host and records provenance metadata for supply-chain integrity.

### Option 3: Clone directly

Any compliant client that scans the shared skills directory will discover them automatically:

```bash
# User-level install
git clone https://github.com/FCBGP/awsome-idr-skills.git ~/.agents/skills/scientific-agent-skills

# Project-level install
git clone https://github.com/FCBGP/awsome-idr-skills.git .agents/skills/scientific-agent-skills
```

> 💡 **Tip:** You don't need every skill. Install the topical subset you actually use — it keeps your agent's context lean and reduces the surface area you need to trust (see [Security Disclaimer](#%EF%B8%8F-security-disclaimer)).

**That's it.** Your agent discovers relevant skills automatically, and you can always invoke one by name in your prompt.

### Option 4: Symlink with `scripts/link_skills.sh` (local checkout)

If you already have this repository checked out (or cloned) and want the skills live under `~/.agents/skills` without duplicating files, use the included helper script:

```bash
cd <repo-root>
./scripts/link_skills.sh
```

This symlinks **every directory under `skills/`** into `~/.agents/skills` (one link per skill), keeping a single source of truth. The destination directory is created if it does not exist. The script:

- Removes any existing non-symlink entry at the target path first, so it won't shadow the new link.
- Reports each skill as it links and a final count.
- Supports command-line options:
  - `-h` / `--help` — print usage information and a short intro, then exit.
  - `-d DIR` / `--dest DIR` — set the destination directory (defaults to `~/.agents/skills`).

```bash
./scripts/link_skills.sh              # link into ~/.agents/skills (default)
./scripts/link_skills.sh -h           # show help
./scripts/link_skills.sh -d /tmp/sk   # link into /tmp/sk
./scripts/link_skills.sh --dest /tmp/sk
```

Re-run it anytime after pulling new skills to refresh the links. Recommended destination is `~/.agents/skills`, and you can manage the active skill set with **cc-switch**. See [Helper Scripts](#helper-scripts) for all three scripts shipped in `scripts/`.

---

## 🛠 Helper Scripts

Three self-contained shell helpers live in `scripts/` and are maintained alongside this repo. They depend only on a POSIX shell and the codex CLI, so you can also copy them anywhere and run them directly.

| Script | What it does |
| ------ | ------------ |
| `link_skills.sh` | Symlinks every skill directory under `skills/` into a destination directory (default `~/.agents/skills`). |
| `codex-auto` | Loops `codex exec` over the unchecked items of a project's `TODO.md` until it is done. |
| `codex-todo-init` | Generates a minimal `TODO.md` task list. |

### `link_skills.sh` — install skills as symlinks

Symlinks **each directory under `skills/`** into a destination directory, so your agent can discover the skills without duplicating files (a single source of truth). It creates the destination if needed, removes any non-symlink entry already at the target path first, then reports every link and a final count.

**Recommended setup:** link into `~/.agents/skills` (the conventional agent-skills directory) and manage which skills are active with **cc-switch**. Re-run the script after `git pull` to refresh the links.

```bash
./scripts/link_skills.sh                # link into ~/.agents/skills (default)
./scripts/link_skills.sh -h             # show help
./scripts/link_skills.sh -d /tmp/sk     # link into a custom directory
./scripts/link_skills.sh --dest /tmp/sk # same as -d
```

### `codex-auto` — loop through a project's TODO.md with Codex

Repeatedly runs **Codex** against a project directory until its `TODO.md` task list is finished (or a round/stall limit is hit). It relies on the project containing:

- **`AGENTS.md`** — the project's agent instructions, which tell Codex how to work in this repository.
- **`TODO.md`** — the task list to work through (create one with [`codex-todo-init`](#codex-todo-init--scaffold-a-todomd)).

Each round sends Codex a prompt that:
1. Reads `TODO.md` and executes **exactly one** unchecked `- [ ]` item in listed priority order.
2. Completes the item, runs checks, verifies the result, then marks it `- [x]` in place.
3. Adds one indented line describing what was produced or verified.
4. If the item is genuinely blocked, marks it `- [~]`, records the blocker, and moves to the next open item.

`codex-auto` stops when all items are done, when the configured round limit is reached, or when the TODO file stops changing for N consecutive rounds. Each round is logged to `logs/round_<n>.md` inside the project directory. Codex permissions are managed by `~/.codex/config.toml`; the script only drives the TODO loop.

```bash
./scripts/codex-auto <project-dir>              # loop through TODO.md tasks (default 100 rounds)
./scripts/codex-auto . -t TODO_P0.md -n 50      # custom TODO file, max 50 rounds
./scripts/codex-auto ~/my/project --status       # only list remaining tasks, run nothing
./scripts/codex-auto . --dry                     # preview the prompt without running codex
./scripts/codex-auto . -p work -s 5             # use a Codex profile, wait 5s between rounds
```

### `codex-todo-init` — scaffold a TODO.md

Generates a minimal `TODO.md` checklist (`- [ ] P0:` / `- [ ] P1:`) to bootstrap a Codex-driven workflow. It refuses to overwrite an existing file.

```bash
./scripts/codex-todo-init             # create TODO.md
./scripts/codex-todo-init TODOS.md    # create a list in a custom file
```

---

## ⚙️ Prerequisites

- **Python**: 3.13+ for repository tooling; individual skills may support broader ranges (check each `SKILL.md`).
- **uv**: Python package manager used to install skill dependencies.
- **A compatible agent**: any host that supports the [Agent Skills](https://agentskills.io/) standard (Cursor, Claude Code, Codex, Gemini CLI, Google Antigravity, etc.).
- **OS**: macOS, Linux, or Windows with WSL2.

### Installing uv

**macOS / Linux:**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

**Windows:**
```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

Verify with `uv --version`. For more options, see the [official uv docs](https://docs.astral.sh/uv/).

---

## ⚠️ Security Disclaimer

> **Skills can execute code and influence your agent's behavior. Review what you install.**

Agent Skills can instruct your AI agent to run code, install packages, make network requests, and modify files. A malicious or poorly written skill could steer your agent into harmful behavior.

We run LLM-based security scans (via the [Cisco AI Defense Skill Scanner](https://github.com/cisco-ai-defense/skill-scanner)) on every skill in this repo and review contributions before merging. But as a small team, we can't guarantee every skill has been exhaustively reviewed. **It is ultimately your responsibility to review the skills you install.**

We recommend:

- **Install only what you need** rather than the whole collection.
- **Read the `SKILL.md`** before installing — it describes what the skill does, which packages it uses, and which external services it touches.
- **Scan third-party skills yourself:**
  ```bash
  uv pip install cisco-ai-skill-scanner
  skill-scanner scan /path/to/skill --use-behavioral
  ```
- **Report anything suspicious** by [opening an issue](https://github.com/FCBGP/awsome-idr-skills/issues).

Skills are re-scanned roughly weekly, with results tracked in [SECURITY.md](SECURITY.md).

---

## 💡 Quick Examples

Once installed, ask your agent to run end-to-end research workflows. A few examples using skills in this collection:

### 📚 Systematic Literature Review
```
Search arXiv, OpenAlex, and Semantic Scholar via paper-lookup for recent work on BGP
route hijacking and RPKI deployment, pull structured experimental details with
bgpt-paper-search, synthesize a systematic review with literature-review, verify and
format references with citation-management, and write up the findings with
scientific-writing.
```
**Skills used:** paper-lookup, bgpt-paper-search, literature-review, citation-management, scientific-writing

### 🔎 Reproducible Database Lookup
```
Use database-lookup to retrieve relevant scientific and regulatory data with explicit
endpoints, and map related findings through the available public databases with
provenance recorded for every result.
```
**Skills used:** database-lookup

### 📊 Data Analysis & Reporting
```
Load this large routing-table CSV with polars, profile the BGP attribute distributions,
build publication-quality figures with scientific-visualization, and export the results
to an Excel workbook with xlsx.
```
**Skills used:** polars, scientific-visualization, xlsx

### 🤖 Machine Learning Pipeline
```
Train an anomaly detector for BGP route changes with scikit-learn (or pytorch-lightning
for a neural net), reduce the high-dimensional routing features with umap-learn for
visualization, explain the predictions with shap, and write up methods and results with
scientific-writing.
```
**Skills used:** scikit-learn, pytorch-lightning, umap-learn, shap, scientific-writing

### 📈 Zero-Shot Forecasting
```
Forecast this BGP announcement time series with timesfm-forecasting and visualize the
forecast with prediction intervals.
```
**Skills used:** timesfm-forecasting, scientific-visualization

### 📄 Paper Reproduction
```
Reproduce the experiments in this BGP security paper PDF with paper-reproduction-flow,
and write up the results as a Chinese research report with research-report-word.
```
**Skills used:** paper-reproduction-flow, research-report-word

---

## 🎓 Tutorials: How to Use the Skills

Hands-on guides with a **use-case scenario for every skill**, organized by category — see [tutorials/README.md](tutorials/README.md) for the full index.

| # | Category | Guide |
|---|---|---|
| 01 | 🗄️ Databases & Data Access | [tutorials/01-databases.md](tutorials/01-databases.md) |
| 02 | 🔎 Literature & Web Search | [tutorials/02-literature-search.md](tutorials/02-literature-search.md) |
| 03 | ✍️ Scientific Writing & Evaluation | [tutorials/03-scientific-writing.md](tutorials/03-scientific-writing.md) |
| 04 | 📄 Documents | [tutorials/04-documents.md](tutorials/04-documents.md) |
| 05 | 🎨 Presentations & Visuals | [tutorials/05-presentations.md](tutorials/05-presentations.md) |
| 06 | 📊 Data Processing & Visualization | [tutorials/06-data-processing.md](tutorials/06-data-processing.md) |
| 07 | 🤖 Machine Learning & AI | [tutorials/08-machine-learning.md](tutorials/08-machine-learning.md) |
| 08 | 🧮 Simulation & Mathematics | [tutorials/10-simulation-math.md](tutorials/10-simulation-math.md) |
| 09 | ⚙️ Infrastructure & Platforms | [tutorials/11-infrastructure.md](tutorials/11-infrastructure.md) |
| 10 | 🎓 Research Methodology & Ideation | [tutorials/12-research-methodology.md](tutorials/12-research-methodology.md) |

---

## 📚 Available Skills

This repository contains **70 skills**. The listings below are *explicitly defined* skills — curated with documentation, examples, and best practices. They are not a ceiling: your agent can install and use any Python package or call any API even without a dedicated skill; these simply make common workflows faster and more dependable.

### 🗄️ Databases & Data Access (2)
- **database-lookup** — Deterministic REST access to 78 public scientific, biomedical, materials, regulatory, finance, and demographics databases (PubChem, ChEMBL, UniProt, PDB, AlphaFold, KEGG, Reactome, STRING, ClinVar, COSMIC, ClinicalTrials.gov, FDA, FRED, USPTO, SEC EDGAR, and more) with explicit filters, pagination, and provenance.
- **hugging-science** — Curated catalog of scientific datasets, models, blog posts, and interactive Spaces across 17 domains, with usage patterns for `datasets`, `transformers`, the HF Inference API, and `gradio_client`.

### 🔎 Literature & Web Search (9)
- **paper-lookup** — Search 10 academic databases (PubMed, PMC, bioRxiv, medRxiv, arXiv, OpenAlex, Crossref, Semantic Scholar, CORE, Unpaywall).
- **bgpt-paper-search** — Structured experimental data (25+ fields per paper) extracted from full text via the BGPT MCP server.
- **literature-review** — Systematic, multi-database literature reviews with verified citations and formatted output.
- **citation-management** — Search, validate, and generate BibTeX; convert DOIs; ensure reference accuracy.
- **pyzotero** — Programmatic access to Zotero libraries via the Web API v3.
- **paperzilla** — Project recommendations, canonical paper details, and feed export via Paperzilla.
- **exa-search** — Web search and URL extraction tuned for scientific/scholarly content via Exa.
- **parallel-web** — All-in-one web toolkit (search, extraction, bulk enrichment, deep research) emphasizing academic sources.
- **research-lookup** — Routed current-research lookup across parallel-cli, the Parallel Chat API, and Perplexity.

### ✍️ Scientific Writing & Evaluation (4)
- **scientific-writing** — Manuscripts in flowing prose with IMRAD structure, citations, and reporting guidelines (CONSORT/STROBE/PRISMA).
- **peer-review** — Checklist-based manuscript/grant review with methodology and reporting-standards assessment.
- **scholar-evaluation** — Quantitative scholarly assessment via the ScholarEval framework.
- **venue-templates** — LaTeX templates and submission requirements for major journals, conferences, posters, and grants.

### 📄 Documents (8)
- **pdf** — Read, create, merge/split, OCR, fill forms, and manipulate PDF files.
- **docx** — Create, read, and edit Word documents with rich formatting.
- **pptx** — Create, read, and edit PowerPoint presentations.
- **xlsx** — Create, edit, and analyze Excel workbooks (formulas, multi-sheet, financial models).
- **markitdown** — Convert PDF/Office/images/audio/HTML and more to Markdown.
- **liteparse** — Local document/PDF parsing with bounding boxes, OCR, and layout-preserved JSON for RAG.
- **report-word-format** — Generate Chinese research report Markdown and Word documents with fixed headings, figure/table captions, bibliography numbering, cross-references, three-line tables, and body-font inline code.
- **research-report-word-skill** — Chinese research report (调研报告) Markdown and Word generation with the same fixed formatting spec as `report-word-format`.

### 🎨 Presentations & Visuals (10)
- **scientific-slides** — Slide decks for research talks (PowerPoint and LaTeX Beamer).
- **latex-posters** — Conference posters in LaTeX (beamerposter, tikzposter, baposter).
- **pptx-posters** — HTML/CSS posters exportable to PDF or PPTX.
- **scientific-schematics** — Publication-quality diagrams (architectures, pathways, flowcharts) via AI generation.
- **scientific-visualization** — Meta-skill for journal-ready multi-panel figures with significance annotations and colorblind-safe palettes.
- **markdown-mermaid-writing** — Text-based diagrams and documents with style guides, diagram references, and templates.
- **infographics** — Professional infographics (10 types, 8 styles, colorblind-safe palettes).
- **generate-image** — General-purpose AI image generation and editing (FLUX, Nano Banana).
- **ppt-master** — AI-driven multi-format SVG content generation system. Converts source documents (PDF/DOCX/URL/Markdown) into high-quality SVG pages through multi-role collaboration and exports to PPTX.
- **cyber-ppt** — Turns DOCX/PDF/TXT/XLSX/research materials/business data into high-density, editable, consulting-style PowerPoint presentations with evidence chains and quality checks.

### 📊 Data Processing & Visualization (7)
- **polars** — High-performance, expression-based DataFrames with lazy/streaming execution.
- **dask** — Distributed computing for larger-than-RAM pandas/NumPy workflows.
- **vaex** — Out-of-core DataFrames for billions of rows on a single machine.
- **zarr-python** — Chunked, compressed N-D arrays for cloud-scale scientific data.
- **matplotlib** — Low-level plotting for full publication-grade control.
- **seaborn** — Statistical visualization with attractive defaults and pandas integration.
- **networkx** — Create, analyze, and visualize graphs and complex networks.

### 🤖 Machine Learning & AI (12)
- **scikit-learn** — Classical supervised/unsupervised learning, model evaluation, and pipelines.
- **pytorch-lightning** — Organized, scalable neural-network training (multi-GPU, DDP/FSDP/DeepSpeed).
- **transformers** — Hugging Face models, pipeline inference, generation, and Trainer fine-tuning.
- **shap** — Model interpretability and feature attribution across model types.
- **umap-learn** — Nonlinear dimensionality reduction and embeddings.
- **torch-geometric** — Graph neural networks (GCN, GAT, GraphSAGE, GIN, heterogeneous graphs).
- **pymc** — Bayesian modeling, MCMC (NUTS), variational inference, and model comparison.
- **pymoo** — Multi-objective optimization (NSGA-II/III, MOEA/D, Pareto fronts).
- **aeon** — Time-series ML (classification, regression, clustering, forecasting, anomaly detection).
- **timesfm-forecasting** — Zero-shot univariate forecasting with Google's TimesFM foundation model.
- **stable-baselines3** — Production-ready RL algorithms with a scikit-learn-like API.
- **pufferlib** — High-performance, vectorized RL for fast parallel and multi-agent training.

### 🧮 Simulation & Mathematics (3)
- **simpy** — Process-based discrete-event simulation (queues, resources, logistics).
- **sympy** — Exact symbolic mathematics (algebra, calculus, symbolic linear algebra).
- **matlab** — MATLAB/GNU Octave numerical computing and Python interoperability.

### ⚙️ Infrastructure & Platforms (5)
- **modal** — Serverless cloud compute, on-demand GPUs, and scalable batch/inference jobs.
- **optimize-for-gpu** — GPU-accelerate Python with CuPy, Numba CUDA, Warp, and the RAPIDS stack (cuDF, cuML, cuGraph, …).
- **get-available-resources** — Detect CPU/GPU/memory/disk and recommend a computational strategy before heavy work.
- **pi-agent** — Build with and use Pi, the minimal terminal coding harness (SDK, RPC, extensions, packages).
- **autoskill** — Detect repeated research workflows locally via screenpipe and draft new skills for them.

### 🎓 Research Methodology & Ideation (10)
- **scientific-brainstorming** — Open-ended creative research ideation and gap-finding.
- **hypothesis-generation** — Structured, testable hypotheses with predictions and mechanisms.
- **hypogenic** — Automated LLM-driven hypothesis generation and testing on tabular data.
- **scientific-critical-thinking** — Evaluate claims and evidence quality (GRADE, Cochrane risk of bias).
- **consciousness-council** — Multi-perspective deliberation and devil's-advocate analysis.
- **what-if-oracle** — Structured what-if scenario analysis with 4–6 branch exploration.
- **arbor** — Autonomously improve an artifact against an evaluator via Hypothesis Tree Refinement, with a held-out gate against overfitting.
- **research-grants** — Competitive proposals for NSF, NIH, DOE, DARPA, and Taiwan NSTC.
- **open-notebook** — Self-hosted NotebookLM alternative for research notebooks, multi-source ingestion, and podcast generation.
- **paper-reproduction-flow** — Multi-agent paper reproduction pipeline (Orchestrator + named subagents) for reproducing papers from a PDF/URL/text, with isolated dated run workspaces and effort tiers.

> 📖 For full details on every skill, see its `SKILL.md` under [skills/](skills/).

---

## 🤝 Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for repository structure, required `SKILL.md` frontmatter, the Agent Skills specification, versioning, validation, and security scanning.

**Quick checklist:**

1. **Fork** the repo and create a feature branch.
2. **Follow** [CONTRIBUTING.md](CONTRIBUTING.md) and the [Agent Skills Specification](https://agentskills.io/specification) — valid `SKILL.md` frontmatter, naming conventions, and directory structure.
3. **Include** a quoted `metadata.version`; increment it when updating an existing skill.
4. **Test** all code examples and workflows.
5. **Scan** your skill before submitting:
   ```bash
   uv pip install cisco-ai-skill-scanner
   skill-scanner scan /path/to/your/skill --use-behavioral
   ```
6. **Open** a pull request with a clear description.

---

## 🔧 Troubleshooting

**Skills not loading**
- Confirm the skill folders are in the correct directory for your host (see [Getting Started](#-getting-started)) and each contains a `SKILL.md`.
- Restart your agent/IDE after installing.

**Missing Python dependencies**
- Check the skill's `SKILL.md` for required packages and install with `uv pip install <package>`.

**API rate limits or auth errors**
- Many databases have rate limits and some services require API keys. Review the relevant `SKILL.md` for setup and consider caching or batching.

**Install path issues (v2.43.0+)**
- Skills live under `skills/` (not the older `scientific-skills/`). Update manual copy paths and re-run `gh skill install FCBGP/awsome-idr-skills`.

---

## ❓ FAQ

**Is this free to use?**
Yes — the repository is MIT licensed. Each skill also has its own license in the `license` field of its `SKILL.md`; review those before use.

**Do I need to install all the skills or Python packages?**
No. Install only the skills you need; each one specifies its own requirements in its `SKILL.md`.

**Can I use this with agents other than Claude Code?**
Yes. The skills follow the open [Agent Skills](https://agentskills.io/) standard and work with any compatible host (Cursor, Codex, Gemini CLI, Google Antigravity, OpenClaw, Pi, and more).

**Do the skills work offline?**
Package skills work offline once dependencies are installed. Database and web-search skills require internet access.

**Can I contribute my own skill?**
Absolutely — see [Contributing](#-contributing).

---

## 📄 License

Licensed under the **MIT License**. See [LICENSE.md](LICENSE.md).

> ⚠️ **Individual skills may carry different licenses.** Each skill's license is in the `license` field of its `SKILL.md`. You are responsible for reviewing and complying with those terms.

---