.DELETE_ON_ERROR:

MY_DOC = eprb_signal_correlations

$(MY_DOC).pdf: $(MY_DOC).tex $(MY_DOC).bib $(MY_DOC)_revision.txt
	pdflatex $(MY_DOC) && \
	bibtex $(MY_DOC) && \
	pdflatex $(MY_DOC) && \
	pdflatex $(MY_DOC)

$(MY_DOC)_revision.txt: GNUmakefile
	date -u > $(@)

.PHONY: clean
clean:
	rm -f $(MY_DOC).{log,aux,out}
	rm -f missfont.log

.PHONY: install
install: $(MY_DOC).pdf
	scp $(^) crudfact@crudfactory.com:www/.
