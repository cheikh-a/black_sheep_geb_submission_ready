# Zenodo Release Checklist

This repository is prepared for GitHub-to-Zenodo archiving. The files `.zenodo.json` and `CITATION.cff` at the repository root provide the base metadata for the first archival release.

## Before the first archival release

1. Log in to `https://zenodo.org` with the GitHub account that owns `cheikh-a/black_sheep_geb_submission_ready`.
2. In Zenodo, open the GitHub integration page and enable the repository `cheikh-a/black_sheep_geb_submission_ready`.
3. Confirm that the metadata imported from `.zenodo.json` is correct.
4. Decide whether a formal software license should be added before the first release. The repository is public, but no license file is currently attached.

## Minting the DOI

1. Push the final submission state to `main`.
2. Create a GitHub release from a tag such as `v1.0.0`.
3. Wait for Zenodo to archive that GitHub release automatically.
4. Record both the version DOI and the concept DOI from the Zenodo record.

## After the DOI is minted

1. Use `Zenodo` as the repository name in the Elsevier submission system.
2. Paste the Zenodo record URL or DOI into the repository link field.
3. If desired, replace the GitHub URL in `paper/sections/backmatter.tex` with the Zenodo concept DOI and rebuild the manuscript.
4. If desired, update `submission/cover_letter.tex` and `submission/cover_letter.md` so the cover letter cites the same archival record.

## Suggested first tag

- `v1.0.0-submission`

This tag name is descriptive, stable, and makes it easy to distinguish the original submission archive from later revisions.
