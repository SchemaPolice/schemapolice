#!/bin/bash
saxon "$3" "$4" "$5" -xsl:src/main/resources/doc-gen/javadoc-to-docbook.xsl $1 | xmllint --pretty 1  -
