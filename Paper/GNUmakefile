.DELETE_ON_ERROR:

eprb_signal_correlations.pdf: eprb_signal_correlations.tex \
								eprb_signal_correlations.bib \
								eprb_signal_correlations.bbl \
								revision.txt
	pdflatex $(<) && pdflatex $(<) && pdflatex $(<)

# I suppose I should look up what a makefile for all this actually
# should look like.
eprb_signal_correlations.bbl: eprb_signal_correlations.aux \
								eprb_signal_correlations.bib
	bibtex $(<)

revision.txt: GNUmakefile
	date -u > $(@)

.PHONY: clean
clean:
	rm -f eprb_signal_correlations.{log,aux,out}
	rm -f missfont.log

.PHONY: install
install: eprb_signal_correlations.pdf
	scp $(^) crudfact@crudfactory.com:www/.
