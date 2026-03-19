# Black Sheep GEB Submission Package

This repository rebuilds `No Country for Honest Men: Equilibrium and Inequality in Calvino's Black Sheep` as a theory-and-simulation paper aimed at *Games and Economic Behavior*. The repo contains:

- a revised LaTeX manuscript and appendix;
- an R simulation pipeline for the baseline, patronage, and enforcement regimes;
- publication-grade figures in PDF and PNG;
- manuscript tables generated from source;
- revision, response, and QA reports.

## Layout

```text
black_sheep_geb_submission_ready/
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

Run from the repository root:

```bash
make setup
```

### Full build

Run from the repository root:

```bash
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
- Journal-specific submission material is kept outside the public replication archive.
- Repository-level archival metadata for Zenodo and GitHub are stored in `.zenodo.json` and `CITATION.cff`.

## Zenodo archival release

This repository is public at `https://github.com/cheikh-a/black_sheep_geb_submission_ready` and the current archival release is available at `https://doi.org/10.5281/zenodo.19051109`.

1. Log in at `https://zenodo.org` and connect the GitHub account.
2. In the GitHub tab on Zenodo, enable archiving for `cheikh-a/black_sheep_geb_submission_ready`.
3. Check the imported metadata from `.zenodo.json` and edit it on Zenodo only if the release-specific record needs additional fields.
4. Create a GitHub release, for example `v1.0.0`.
5. Wait for Zenodo to archive the release and mint the version DOI and concept DOI.
6. Use `Zenodo` as the repository name in the journal submission system and paste the Zenodo record URL or DOI there.
7. The current version DOI is `10.5281/zenodo.19051109`.

The detailed release checklist is stored in `reports/zenodo_release_checklist.md`.
