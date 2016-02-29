#!/bin/bash
saxon -xsl:src/main/resources/doc-gen/wsdl-to-docbook.xsl $1 | xmllint --pretty 1  -
