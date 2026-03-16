# Games and Economic Behavior Submission Audit

Updated: March 16, 2026

## Journal fit

The manuscript is framed as a theory paper with simulations for *Games and Economic Behavior*. The abstract, introduction, and cover letter all present the contribution as a game theoretic study of equilibrium fragility, delegated predation, endogenous enforcement, and welfare under insecure claims.

## Required manuscript elements

| Item | Status | Where |
| --- | --- | --- |
| Title, author, and corresponding contact | Complete | `paper/main.tex`; `submission/geb_title_page.tex` |
| Abstract | Complete | `paper/main.tex`; `submission/geb_title_page.tex` |
| Keywords | Complete | `paper/main.tex`; `submission/geb_title_page.tex` |
| JEL classification | Complete | `paper/main.tex`; `submission/geb_title_page.tex` |
| Acknowledgements section before references | Complete | `paper/sections/backmatter.tex` |
| Competing interest declaration | Complete | `paper/sections/backmatter.tex`; `submission/geb_title_page.tex` |
| Data availability statement | Complete | `paper/sections/backmatter.tex`; `submission/geb_title_page.tex` |
| Generative AI disclosure | Complete | `paper/sections/backmatter.tex` |
| Bibliography before appendix | Complete | `paper/main.tex` |
| XeLaTeX build | Complete | `Makefile` |

## Submission package

| File | Purpose |
| --- | --- |
| `combined.pdf` | Main submission PDF |
| `submission/geb_title_page.tex` | Separate title page and metadata sheet |
| `submission/cover_letter.md` | Journal-specific cover letter |
| `submission/highlights.txt` | Short highlights for the portal if requested |
| `reports/final_qa.md` | Internal quality-control record |
| `reports/citation_verification.md` | Citation existence check |

## Points to confirm in the submission portal

| Item | Note |
| --- | --- |
| Author affiliation label | The title page and manuscript now use `Université Laval`. Add a department or research unit only if a more specific institutional label is preferred. |
| Submission exclusivity | Confirm directly in Elsevier's portal at the time of upload. |
| Funding metadata | The manuscript states that no external funding supported the research. Match the portal entry to that statement. |
| Repository archiving | The public replication package is archived on Zenodo at `10.5281/zenodo.19051109`, with GitHub retained as the development mirror. |

## Residual risks

The manuscript now contains the standard declarations requested by the journal guide, but Elsevier occasionally updates portal-specific metadata fields independently of the manuscript template. A final check inside the live submission portal remains advisable before upload.
