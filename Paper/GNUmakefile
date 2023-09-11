.DELETE_ON_ERROR:

eprb_signal_correlations.pdf: eprb_signal_correlations.tex revision.txt
	pdflatex $(<) && pdflatex $(<) && pdflatex $(<)

revision.txt: GNUmakefile
	date -u > $(@)

.PHONY: clean
clean:
	rm -f eprb_signal_correlations.{log,aux,out}
	rm -f missfont.log

.PHONY: install
install: eprb_signal_correlations.pdf
	scp $(^) crudfact@crudfactory.com:www/.
