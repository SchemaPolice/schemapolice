#!/bin/bash
saxon -xsl:src/main/resources/doc-gen/javadoc-to-docbook.xsl $1 | xmllint --pretty 1  -
