.DELETE_ON_ERROR:

eprb_signal_correlations.pdf: eprb_signal_correlations.tex revision.txt
	pdflatex $(<)
	pdflatex $(<)
	pdflatex $(<)

revision.txt: GNUmakefile
	date -u > $(@)
