#!/bin/bash
saxon "$3" "$4" "$5" -xsl:src/main/resources/doc-gen/javadoc-to-docbook.xsl $1 | xmllint --pretty 1  - | pandoc -V geometry:margin=3cm -S -N --toc -f docbook -o $2
