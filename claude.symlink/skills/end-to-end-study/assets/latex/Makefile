PDF := main.pdf
TEX := main.tex
BIB := references.bib
FIGS := $(wildcard Fig*.pdf)

.PHONY: all clean full

all: $(PDF)

$(PDF): $(TEX) $(BIB) $(FIGS)
	latexmk -pdf $(TEX)

full:
	latexmk -C
	pdflatex -interaction=nonstopmode $(TEX)
	bibtex main
	pdflatex -interaction=nonstopmode $(TEX)
	pdflatex -interaction=nonstopmode $(TEX)

clean:
	latexmk -C
