# Black Sheep GEB Revision

This repository rebuilds `No Country for Honest Men: Equilibrium and Inequality in Calvino's Black Sheep` as a theory-and-simulation paper aimed at *Games and Economic Behavior*. The repo contains:

- a revised LaTeX manuscript and appendix;
- an R simulation pipeline for the baseline, patronage, and enforcement regimes;
- publication-grade figures in PDF and PNG;
- manuscript tables generated from source;
- revision, response, and QA reports.

## Layout

```text
black_sheep_geb/
  data/processed/
  output/figures/
  output/tables/
  output/logs/
  paper/
  reports/
  src/
```

## Reproducibility

The code uses R throughout. Package management is handled with `renv`.

### One-time setup

```bash
cd /Users/cheikhahmadou/Documents/Black_Sheep/black_sheep_geb
make setup
```

### Full build

```bash
cd /Users/cheikhahmadou/Documents/Black_Sheep/black_sheep_geb
make all
```

This will:

1. restore the R environment with `renv`,
2. generate processed simulation outputs,
3. build all figures and tables,
4. compile the XeLaTeX manuscript PDFs in `paper/main.pdf`, `paper/combined.pdf`, and `combined.pdf`.

### Incremental targets

```bash
make data
make figures
make tables
make paper
make clean
```

## Main outputs

- manuscript: `paper/main.pdf`
- combined submission PDF: `paper/combined.pdf` and `combined.pdf`
- appendix inputs: `paper/appendix.tex`
- figures: `output/figures/` and `paper/figures/`
- tables: `output/tables/` and `paper/tables/`
- revision materials: `reports/`
- submission package: `submission/`

## Notes

- The simulation is deterministic where the theory requires exact event accounting and stochastic where the richer patronage and enforcement dynamics require matching and target variation.
- Figure generation is centralized in `src/07_make_figures.R`; table generation is centralized in `src/08_make_tables.R`.
- The manuscript is compiled with XeLaTeX and uses standalone `tabular` inputs for every included table.
- The manuscript distinguishes analytical results from computational findings throughout.
- The `submission/` folder contains a GEB-oriented title page, cover letter, highlights, and journal-facing metadata.
