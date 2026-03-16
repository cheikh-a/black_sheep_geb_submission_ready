SHELL := /bin/zsh
R := Rscript
LATEX := xelatex

.PHONY: all setup data figures tables paper submission clean

all: data figures tables paper submission

setup:
	$(R) -e "if (!requireNamespace('renv', quietly = TRUE)) install.packages('renv', repos = 'https://cloud.r-project.org')"
	$(R) -e "renv::consent(provided = TRUE); renv::restore(prompt = FALSE)"

data:
	$(R) src/03_simulate_baseline.R
	$(R) src/04_simulate_patronage.R
	$(R) src/05_simulate_enforcement.R
	$(R) src/06_parameter_sweeps.R

figures:
	$(R) src/07_make_figures.R

tables:
	$(R) src/08_make_tables.R

paper:
	cd paper && $(LATEX) -interaction=nonstopmode main.tex > ../output/logs/xelatex_pass1.log
	cd paper && bibtex main > ../output/logs/bibtex.log
	cd paper && $(LATEX) -interaction=nonstopmode main.tex > ../output/logs/xelatex_pass2.log
	cd paper && $(LATEX) -interaction=nonstopmode main.tex > ../output/logs/xelatex_pass3.log
	cp paper/main.pdf paper/combined.pdf
	cp paper/main.pdf combined.pdf

submission:
	cd submission && $(LATEX) -interaction=nonstopmode geb_title_page.tex > ../output/logs/xelatex_title_page.log

clean:
	setopt NULL_GLOB; rm -f paper/*.aux paper/*.bbl paper/*.blg paper/*.fdb_latexmk paper/*.fls paper/*.log paper/*.out paper/*.synctex.gz paper/combined.pdf combined.pdf submission/*.aux submission/*.log submission/*.out
