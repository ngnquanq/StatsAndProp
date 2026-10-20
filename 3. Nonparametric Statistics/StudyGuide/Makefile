PYTHON ?= python3

.PHONY: all figures pdf check
all: figures pdf

figures:
	$(PYTHON) verify_and_figures.py

pdf:
	latexmk -xelatex -interaction=nonstopmode -halt-on-error main.tex

check:
	$(PYTHON) verify_and_figures.py
	latexmk -xelatex -interaction=nonstopmode -halt-on-error main.tex
	$(PYTHON) check_document.py
