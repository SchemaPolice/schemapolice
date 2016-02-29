<?xml version="1.0" encoding="UTF-8"?>
<!-- Strips ugly namespace prefixes from old docbook XML documents.
     Mostly useful to fix up old, existing documentation. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:db="http://docbook.org/ns/docbook"
    exclude-result-prefixes="xs db"
    version="2.0">
    
    <!-- Docbook: Strip namespace -->
    <xsl:template match="db:*">
        <xsl:element name="{local-name()}" namespace="http://docbook.org/ns/docbook">
            <xsl:apply-templates select="@*"/>
            
            <!-- If root element, attach schemalocation etc -->
            <xsl:if test="count(parent::*) eq 0">
                <xsl:attribute name="xsi:schemaLocation" namespace="http://www.w3.org/2001/XMLSchema-instance">http://docbook.org/ns/docbook http://www.docbook.org/xml/5.0/xsd/docbook.xsd</xsl:attribute>
                <xsl:namespace name="xi">http://www.w3.org/2001/XInclude</xsl:namespace>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*|text()|comment()|processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>
   
</xsl:stylesheet>