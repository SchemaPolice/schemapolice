#!/bin/bash
saxon -xsl:src/main/resources/doc-gen/javadoc-to-docbook.xsl $1 | xmllint --pretty 1  - | pandoc -S -N --toc -f docbook -o $2
