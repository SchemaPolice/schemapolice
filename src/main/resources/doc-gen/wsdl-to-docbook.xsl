<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:fn="http://www.w3.org/2005/xpath-functions"
        xmlns:df="http://schemapolice.com/documentation/functions"

        xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:db="http://docbook.org/ns/docbook"

        version="2.0">

    <!-- WSDL to Docbook transformation rules, to generate a Docbook XML
         document that draws heavily from embedded 'documentation' nodes
         to provide a human-friendly accompaniment to a web service API

         @author Dawid Loubser
     -->

    <xsl:output method="xml" media-type="application/docbook+xml"/>

    <!-- Specify to make this organisation name the visible author -->
    <xsl:param name="orgName" as="xs:string?">Travellinck International</xsl:param>


    <!-- Disable default pass-through -->
    <xsl:template match="*|@*"/>


    <xsl:template match="wsdl:definitions">
        <db:book>
            <db:info>
                <db:title>Web Service Contract: <xsl:value-of select="df:wsdlHumanName(.)"/> </db:title>
                <xsl:apply-templates select="@targetNamespace"/>
                <xsl:if test="not(empty($orgName))">
                    <db:author>
                        <db:orgname><xsl:value-of select="$orgName"/></db:orgname>
                    </db:author>
                </xsl:if>
                <!-- TODO: Date (original, how? Look for date in WSDL docs? Also, indicate 'generated' date -->
            </db:info>

            <xsl:apply-templates/>

        </db:book>
    </xsl:template>


    <!-- Handling of documentation blocks -->
    <xsl:template match="wsdl:definitions/wsdl:documentation">
        <db:chapter>
            <db:title>General introduction</db:title>
            <xsl:copy-of select="df:wsdlDocumentationToParas( text() )"/>
        </db:chapter>
    </xsl:template>


    <xsl:template match="wsdl:definitions/@targetNamespace">
        <db:subtitle><xsl:value-of select="."/></db:subtitle>
    </xsl:template>


    <xsl:template match="wsdl:portType">
        <db:chapter>
            <db:title>Contract: <xsl:value-of select="@name"/></db:title>

            <xsl:call-template name="portTypeOverview">
                <xsl:with-param name="portType" select="."/>
            </xsl:call-template>

            <xsl:apply-templates/>

        </db:chapter>
    </xsl:template>


    <xsl:template name="portTypeOverview">
        <xsl:param name="portType"/>
        <xsl:variable name="ops" select="$portType/wsdl:operation"/>
        <xsl:copy-of select="df:wsdlDocumentationToParas( $portType/wsdl:documentation/text() )"/>
        <db:para>
            <db:literal>
                <xsl:value-of select="$portType/@name"/>
            </db:literal>
            offers
            <xsl:value-of select="count($ops)"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="df:pluralise('use case', count($ops))"/>:

            <db:itemizedlist>
                <xsl:for-each select="$ops">
                    <db:listitem>
                        <db:para><xsl:value-of select="@name"/></db:para>
                    </db:listitem>
                </xsl:for-each>
            </db:itemizedlist>
        </db:para>
    </xsl:template>



    <xsl:template match="wsdl:operation">
        <db:section>
            <db:title>Use-case: <xsl:value-of select="@name"/></db:title>
        </db:section>

        <xsl:copy-of select="df:wsdlDocumentationToParas(wsdl:documentation)"/>

    </xsl:template>


    <xsl:function name="df:pluralise">
        <xsl:param name="base"/>
        <xsl:param name="n"/>
        <xsl:sequence select="if ($n eq 1) then $base else concat( $base, 's')"/>
    </xsl:function>


    <!-- Given a WSDL document - which could contain one or more PortTypes, generates
         a human-friendly "name" for the WSDL. Biased towards single-PortType WSDLs -->
    <xsl:function name="df:wsdlHumanName">
        <xsl:param name="wsdl"/>
        <xsl:variable name="portTypeNames" select="($wsdl//wsdl:portType/@name)"/>
        <xsl:sequence select="fn:string-join($portTypeNames,', ')"/>
    </xsl:function>


    <!-- From a plaintext 'documentation' node, produces a sequence of visible paragraphs -->
    <xsl:function name="df:wsdlDocumentationToParas" as="node()*">
        <xsl:param name="documentation" as="xs:string?"/>
        <xsl:if test="not(empty($documentation))">
            <xsl:variable name="paras" select="fn:tokenize($documentation,'\s*&#10;\s*&#10;\s*')"/>
            <!-- TODO: Filter out obvious copyrights, author statements, or image refs -->
            <xsl:for-each select="$paras">
                <db:para><xsl:value-of select="."/></db:para>
            </xsl:for-each>
        </xsl:if>
    </xsl:function>

</xsl:stylesheet>