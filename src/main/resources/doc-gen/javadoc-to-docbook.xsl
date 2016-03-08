<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:fn="http://www.w3.org/2005/xpath-functions"
        xmlns:df="http://schemapolice.com/documentation/functions"

        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:db="http://docbook.org/ns/docbook"

        version="2.0">

    <!-- Transforms JavaDoc documentation (rendered to XML using github.com/markusbernhardt's
         'xmldoclet' plugin) to a PDF, with an emphasis on design-by-contract. The output is
         meant as a business-friendly accompaniment to the in-code documentation.

         @author Dawid Loubser
     -->

    <xsl:output method="xml" media-type="application/docbook+xml"/>

    <!-- Specify to make this organisation name the visible author -->
    <xsl:param name="orgName" as="xs:string?">Anonymous</xsl:param>

    <!-- Specify to name the system (TODO: Generate default if missing) -->
    <xsl:param name="systemName" as="xs:string?">System</xsl:param>

    <!-- TODO: Support multiple (comma-separated). For now, only one package prefix -->
    <xsl:param name="filterPackages" as="xs:string" select="''"/>

    <!-- Packages which are considered 'system' packages. Implementations of interfaces in these packages
         are not considered as bona fide "service implementations" -->
    <xsl:param name="systemPackages" as="xs:string*" select="('java','javax','net.jini')"/>

    <xsl:param name="dontRenderInTypeName">java.lang.|java.util.</xsl:param>


    <!-- Disable default pass-through -->
    <xsl:template match="*|@*"/>


    <xsl:template match="root">
        <db:book>
            <db:info>
                <db:title>Systems documentation: <xsl:value-of select="$systemName"/> </db:title>
                <xsl:if test="not(empty($orgName))">
                    <db:author>
                        <db:orgname><xsl:value-of select="$orgName"/></db:orgname>
                    </db:author>
                </xsl:if>
                <!-- TODO: Date (original, how? Look for most recent data in JavaDoc comments?) -->
            </db:info>

            <xsl:apply-templates/>

        </db:book>
    </xsl:template>


    <!-- Top-level, only for packages that match the filter -->
    <xsl:template match="package[ starts-with(@name, $filterPackages)]">

        <!-- Per-package formula:
         - Service contracts, incl request / response
         - Implementation(s) - in this, or other, packages
         - Data types (with the other sections linking to this)
         -->
        <xsl:variable name="contracts" select="interface"/>
        <!-- TODO: Implement (slightly tricky) -->
        <!--<xsl:variable name="implementations" select="for $c in class[interface[not( fn:starts-with(@qualified,$systemPackages))]]"/>-->
        <xsl:variable name="dataStructures" select="(enum,annotation,class)[not(implementations)]"/>

        <db:chapter xml:id="{@name}">
            <db:title><xsl:value-of select="@name"/></db:title>
            <xsl:apply-templates select="comment"/>

            <xsl:if test="not(empty($contracts))">
                <db:section>
                    <db:title>Service contracts</db:title>
                    <xsl:apply-templates select="$contracts" mode="contract"/>
                </db:section>
            </xsl:if>

            <xsl:if test="not(empty($dataStructures))">
                <db:section>
                    <db:title>Data structures and implementations</db:title>
                    <xsl:apply-templates select="$dataStructures"/>
                </db:section>
            </xsl:if>

        </db:chapter>
    </xsl:template>


    <xsl:template match="interface" mode="contract">
        <db:section xml:id="{@qualified}">
            <db:title><xsl:value-of select="@name"/> </db:title>
            <xsl:apply-templates select="comment"/>

            <!-- Service summary -->
            <xsl:variable name="services" select="method"/>
            <db:para>
                <db:literal>
                    <xsl:value-of select="@name"/>
                </db:literal>
                offers
                <xsl:value-of select="count($services)"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="df:pluralise('use case', count($services))"/>:

                <db:itemizedlist>
                    <xsl:for-each select="$services">
                        <db:listitem>
                            <db:para>
                                <db:link linkend="{@qualified}"><db:literal><xsl:value-of select="@name"/></db:literal></db:link>
                            </db:para>
                        </db:listitem>
                    </xsl:for-each>
                </db:itemizedlist>
            </db:para>

            <!-- Details -->
            <xsl:apply-templates select="$services"/>

        </db:section>
    </xsl:template>


    <xsl:template match="method">
        <db:section xml:id="{@qualified}">
            <db:title><xsl:value-of select="@name"/></db:title>
            <xsl:apply-templates select="comment"/>


            <xsl:variable name="inputs" select="parameter"/>
            <xsl:variable name="output" select="return"/>

            <xsl:if test="not(empty($inputs))">
                <db:para>
                    <xsl:value-of select="df:pluralise('Input', count($inputs))"/>:
                </db:para>
                <db:orderedlist>
                    <xsl:for-each select="$inputs">
                        <db:listitem>
                            <db:formalpara>
                                <db:title><xsl:value-of select="@name"/></db:title>
                                <db:para>
                                    <db:link linkend="{type/@qualified}"><db:literal><xsl:value-of select="type/@qualified"/></db:literal></db:link>
                                </db:para>
                            </db:formalpara>
                        </db:listitem>
                    </xsl:for-each>
                </db:orderedlist>
            </xsl:if>

            <xsl:if test="not(empty($output/@qualified))">
                <db:para>Output:</db:para>
                <db:orderedlist>
                    <db:listitem>
                        <db:formalpara>
                            <db:title>return</db:title>
                            <db:para>
                                <db:link linkend="{$output/@qualified}"><db:literal><xsl:value-of select="$output/@qualified"/></db:literal></db:link>
                            </db:para>
                        </db:formalpara>
                    </db:listitem>
                </db:orderedlist>
            </xsl:if>

            <!--<db:programlisting language="Java">-->
<!--<xsl:value-of select="@scope"/><xsl:text> </xsl:text><xsl:value-of select="@name"/> (-->
<!--<xsl:for-each select="parameter">-->
<!--<xsl:text>  </xsl:text><xsl:value-of select="type/@qualified"/><xsl:text> </xsl:text><xsl:value-of select="@name"/>-->
<!--</xsl:for-each>-->
<!--)-->
            <!--</db:programlisting>-->
        </db:section>
    </xsl:template>


    <!-- TODO: Implement -->
    <!--<xsl:template match="class" mode="implementation">-->
        <!--<db:section>-->
            <!--<db:title>Implementation: <xsl:value-of select="@name"/> </db:title>-->
            <!--<xsl:apply-templates/>-->
        <!--</db:section>-->
    <!--</xsl:template>-->

    <!-- Types look like:
    <type qualified="org.foo.bar">
        <generic qualified="java.lang.String"/>
    -->

    <xsl:template match="class">
        <db:section xml:id="{@qualified}">
            <db:title>Class: <xsl:value-of select="@name"/> </db:title>
            <xsl:apply-templates select="comment"/>

            <!-- Data stucture -->
            <!-- Methods -->
            <!--<xsl:apply-templates select="method"/>-->

            <xsl:if test="not(empty(method))">
                <db:para>
                    Class details:
                </db:para>
                <db:table width="100%">
                    <!--<db:title>Method(s) offered by <xsl:value-of select="@name"/></db:title>-->
                    <db:tgroup cols="4">
                        <db:colspec colnum="1" colwidth="25%"/>
                        <db:colspec colnum="2" colwidth="25%"/>
                        <db:colspec colnum="3" colwidth="25%"/>
                        <db:colspec colnum="4" colwidth="25%"/>
                        <db:thead>
                            <db:row>
                                <db:entry><db:para>Name</db:para></db:entry>
                                <db:entry><db:para>Input(s)</db:para></db:entry>
                                <db:entry><db:para>Output(s)</db:para></db:entry>
                                <db:entry><db:para>Comment</db:para></db:entry>
                            </db:row>
                        </db:thead>
                        <db:tbody>
                            <xsl:for-each select="method">
                                <db:row>
                                    <!--<db:entry>-->
                                        <!--<db:literal><xsl:value-of select="@name"/>()</db:literal>-->
                                    <!--</db:entry>-->
                                    <!--<db:entry>-->
                                        <!---->
                                    <!--</db:entry>-->
                                    <!--<db:entry>-->
                                        <!--<xsl:apply-templates select="return"/>-->
                                    <!--</db:entry>-->
                                    <!--<db:entry>-->
                                        <!---->
                                    <!--</db:entry>-->
                                    <db:entry>
                                        <db:para>
                                            <db:literal><xsl:value-of select="@name"/>()</db:literal>
                                        </db:para>
                                    </db:entry>
                                    <db:entry>
                                        <xsl:apply-templates select="parameter"/>
                                    </db:entry>
                                    <db:entry>
                                        <xsl:apply-templates select="return"/>
                                    </db:entry>
                                    <db:entry>
                                        <xsl:apply-templates select="comment"/>
                                    </db:entry>
                                </db:row>
                            </xsl:for-each>
                        </db:tbody>
                    </db:tgroup>
                </db:table>
            </xsl:if>
        </db:section>
    </xsl:template>


    <!-- Generically rendes a type name (with link) -->
    <xsl:template match="type">
        <db:link linkend="{@qualified}"><xsl:value-of select="replace(@qualified,$dontRenderInTypeName,'')"/></db:link>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="generic">
        <xsl:text>&lt;</xsl:text>
        <db:link linkend="{@qualified}"><xsl:value-of select="replace(@qualified,$dontRenderInTypeName,'')"/></db:link>
        <xsl:text>&gt;</xsl:text>
    </xsl:template>

    <xsl:template match="class/method/parameter">
        <db:para>
            <xsl:apply-templates select="type"/>
        </db:para>
    </xsl:template>

    <!-- TODO: Generalise with 'type' template -->
    <xsl:template match="class/method/return">
        <db:para>
            <db:link linkend="{@qualified}"><xsl:value-of select="replace(@qualified,$dontRenderInTypeName,'')"/></db:link>
            <xsl:apply-templates/>
        </db:para>
    </xsl:template>


    <xsl:template match="enum">
        <db:section xml:id="{@qualified}">
            <db:title>Enum: <xsl:value-of select="@name"/> </db:title>
            <xsl:apply-templates select="comment"/>
            <db:table>
                <db:tgroup cols="2">
                    <db:thead>
                        <db:row>
                            <db:entry><db:para>Constant</db:para></db:entry>
                            <db:entry><db:para>Description</db:para></db:entry>
                        </db:row>
                    </db:thead>
                    <db:tbody>
                        <xsl:for-each select="constant">
                            <db:row>
                                <db:entry>
                                    <db:literal><xsl:value-of select="@name"/></db:literal>
                                </db:entry>
                                <db:entry>
                                    <xsl:apply-templates select="comment"/>
                                </db:entry>
                            </db:row>
                        </xsl:for-each>
                    </db:tbody>
                </db:tgroup>
            </db:table>
        </db:section>
    </xsl:template>


    <xsl:template match="annotation">
        <db:section xml:id="{@qualified}">
            <db:title>@<xsl:value-of select="@name"/> </db:title>
            <xsl:apply-templates/>
        </db:section>
    </xsl:template>


    <xsl:template match="comment">
        <xsl:sequence select="df:wsdlDocumentationToParas(text())"/>
    </xsl:template>


    <xsl:function name="df:pluralise">
        <xsl:param name="base"/>
        <xsl:param name="n"/>
        <xsl:sequence select="if ($n eq 1) then $base else concat( $base, 's')"/>
    </xsl:function>


    <!-- From a plaintext 'documentation' node, produces a sequence of visible paragraphs -->
    <xsl:function name="df:wsdlDocumentationToParas" as="node()*">
        <xsl:param name="documentation" as="xs:string?"/>
        <xsl:if test="not(empty($documentation))">
            <xsl:variable name="paras" select="fn:tokenize($documentation,'(\s*&#10;\s*&#10;\s*|\s+-)')"/>
            <!-- TODO: Filter out obvious copyrights, author statements, or image refs -->
            <!-- TODO: Detect markdown-style lists and convert to true lists -->
            <xsl:for-each select="$paras">
                <db:para><xsl:value-of select="."/></db:para>
            </xsl:for-each>
        </xsl:if>
    </xsl:function>

</xsl:stylesheet>