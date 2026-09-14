# Tutorials — How to Use the Skills

This directory is a hands-on guide to the **70 skills** in this repository. Each tutorial walks through one skill category with concrete use-case scenarios, so you can see exactly when and how to reach for each skill.

> 📖 The definitive reference for every skill is its own `SKILL.md` under [skills/](../skills/). These tutorials are the *how to use it* companion — one scenario per skill, organized by category.

---

## How to Use a Skill

Skills are invoked by the agent when it detects a matching task. You don't need to type a skill name — you describe the job and the agent picks the right skill. To *force* a skill, name it in your prompt:

> "Use **paper-lookup** to find recent papers on BGP route hijacking."

Two practical notes:

- **Install only what you need.** Each skill declares its own dependencies in `SKILL.md`. Install a subset rather than all 70.
- **Some skills need network or API keys.** Database lookups, web search, and LLM-powered steps require internet; a few need keys (e.g. `EXA_API_KEY`, `PARALLEL_API_KEY`, `OPENROUTER_API_KEY`). Check the relevant `SKILL.md`.

---

## The Category Guides

| # | Category | Guide | Skills |
|---|---|---|---|
| 01 | 🗄️ Databases & Data Access | [01-databases.md](01-databases.md) | 2 |
| 02 | 🔎 Literature & Web Search | [02-literature-search.md](02-literature-search.md) | 9 |
| 03 | ✍️ Scientific Writing & Evaluation | [03-scientific-writing.md](03-scientific-writing.md) | 4 |
| 04 | 📄 Documents | [04-documents.md](04-documents.md) | 8 |
| 05 | 🎨 Presentations & Visuals | [05-presentations.md](05-presentations.md) | 10 |
| 06 | 📊 Data Processing & Visualization | [06-data-processing.md](06-data-processing.md) | 7 |
| 07 | 🤖 Machine Learning & AI | [08-machine-learning.md](08-machine-learning.md) | 12 |
| 08 | 🧮 Simulation & Mathematics | [10-simulation-math.md](10-simulation-math.md) | 3 |
| 09 | ⚙️ Infrastructure & Platforms | [11-infrastructure.md](11-infrastructure.md) | 5 |
| 10 | 🎓 Research Methodology & Ideation | [12-research-methodology.md](12-research-methodology.md) | 10 |

---

## Quick Start — End-to-End Workflows

You can chain skills into multi-step research workflows from a single prompt. A few examples:

### 📚 Systematic Literature Review
```
Search arXiv, OpenAlex, and Semantic Scholar via paper-lookup for recent work on BGP
route hijacking and RPKI deployment, pull structured experimental details with
bgpt-paper-search, synthesize a systematic review with literature-review, verify and
format references with citation-management, and write up the findings with
scientific-writing.
```

### 🔎 Reproducible Database Lookup
```
Use database-lookup to retrieve relevant scientific and regulatory data with explicit
endpoints, and map related findings through the available public databases with
provenance recorded for every result.
```

### 📊 Data Analysis & Reporting
```
Load this large routing-table CSV with polars, profile the BGP attribute distributions,
build publication-quality figures with scientific-visualization, and export the results
to an Excel workbook with xlsx.
```

### 🤖 Machine Learning Pipeline
```
Train an anomaly detector for BGP route changes with scikit-learn (or pytorch-lightning
for a neural net), reduce the high-dimensional routing features with umap-learn for
visualization, explain the predictions with shap, and write up methods and results with
scientific-writing.
```

### 📈 Zero-Shot Forecasting
```
Forecast this BGP announcement time series with timesfm-forecasting and visualize the
forecast with prediction intervals.
```

### 📄 Paper Reproduction
```
Reproduce the experiments in this BGP security paper PDF with paper-reproduction-flow,
and write up the results as a Chinese research report with research-report-word.
```

---