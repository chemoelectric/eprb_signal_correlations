# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <https://unlicense.org>

.DELETE_ON_ERROR:

MY_DOC = How-to-Entangle-Craytons

CTANGLE = ctangle
CTANGLEFLAGS = -v

CWEAVE = cweave
CWEAVEFLAGS = -v

PDFTEX = pdftex
PDFTEXFLAGS =

QPDF = qpdf
QPDFFLAGS =

CC = cc
CFLAGS = -g

.PHONY: pdf default
pdf default: $(MY_DOC).pdf

.PHONY: program
program: $(MY_DOC)

.PHONY: all
all: pdf program

%.c: %.w
	$(CTANGLE) $(CTANGLEFLAGS) $(<) - $(@)

%.tex: %.w
	$(CWEAVE) $(CWEAVEFLAGS) $(<) - $(@)

%.pdf: %.tex
	$(PDFTEX) $(PDFTEXFLAGS) $(<)
	mv $(@) $(MY_DOC).tmp1.pdf
	$(QPDF) $(QPDFFLAGS) $(MY_DOC).tmp1.pdf --pages . r1 . 1-r2 -- \
		$(MY_DOC).tmp2.pdf
	rm $(MY_DOC).tmp1.pdf
	mv $(MY_DOC).tmp2.pdf $(@)

$(MY_DOC): $(MY_DOC).c
	$(CC) $(CFLAGS) -o $(@) $(<) -lm

$(MY_DOC).tex: $(MY_DOC)-revision.txt

$(MY_DOC)-revision.txt: GNUmakefile
	date -u > $(@)

.PHONY: clean
clean:
	rm -f $(MY_DOC){,.{c,idx,log,scn,toc,tex}}
