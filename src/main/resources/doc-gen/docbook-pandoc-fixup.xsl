<?xml version="1.0" encoding="UTF-8"?>
<!-- This XSLT is a quick hack to fix up a complete, XInclude-processed docbook document
    which does not render in pandoc due to issues with relative image paths, unsupported
    elements that don't render properly, etc.
   
    Recommended usage:  [xmllint (with XInclude)] -> [saxon] -> [pandoc]
   
    @author Dawid Loubser
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xmlns:db="http://docbook.org/ns/docbook"
      xmlns:local="urn:local"
      exclude-result-prefixes="xs"
      version="2.0">
    
    <!-- By default, pass through everything -->
    <xsl:template match="*|text()|comment()|processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>
    
    
    <!-- Fix up relative file paths -->
    <xsl:template match="@fileref">
        <xsl:attribute name="fileref" select=" concat( local:determineBase(ancestor-or-self::*/@xml:base), '/',  .)"/>
    </xsl:template>
    
    
    <!-- Remove index terms for now (not supported by pandoc) -->
    <xsl:template match="db:indexterm | db:bibliography"/>
    
    <xsl:template match="db:citation">
        <xsl:text>[*]</xsl:text>
    </xsl:template>
    
    <!-- XRef linking not supported, replace with text 'the picture' -->
    <xsl:template match="db:xref">
        <xsl:choose>
            <xsl:when test="normalize-space(string-join(preceding-sibling::text(),'')) eq ''">
                <xsl:text>The</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>the</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text> picture</xsl:text>
    </xsl:template>
    
    
    <!-- For the given sequence of xml:base paths (starting with innermost, and ending with outermost) determines
        the correct single xml:base path that is implied -->
    <xsl:function name="local:determineBase" as="xs:string*">
        <xsl:param name="paths" as="xs:string*"/>
        <!-- TODO: Deal with absolute xml:base (where we ignore all preceding paths) -->
        <!-- The full, flattened set of directory components (drops the filename from each) -->
        <xsl:variable name="pathComponents" select="for $p in $paths return tokenize($p,'/')[position() lt last()]"/>
        <xsl:sequence select="string-join( $pathComponents, '/')"/>
    </xsl:function>
    
    <!-- Structure fixup: chapters within chapters become sections -->
    <xsl:template match="db:chapter[parent::db:chapter or parent::db:section]">
        <db:section>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>    
        </db:section>
    </xsl:template>
    
    <!-- Structure fixup: Top-level sections become chapters -->
    <xsl:template match="db:book/db:section | db:part/db:section | db:part/db:part">
        <db:chapter>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>    
        </db:chapter>
    </xsl:template>
    
    <xsl:template match="db:part/db:part/db:chapter | db:chapter/db:part">
        <db:section>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>    
        </db:section>
    </xsl:template>
    <!-- TODO: Parts in parts, or parts in chapters -->

</xsl:stylesheet>