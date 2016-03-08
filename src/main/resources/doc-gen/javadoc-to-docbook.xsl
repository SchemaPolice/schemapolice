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
    <xsl:param name="orgName" as="xs:string?">Travellinck International</xsl:param>
    <!-- Specify to name the system (TODO: Generate default if missing) -->
    <xsl:param name="systemName" as="xs:string?">Corporate App: Tags Module</xsl:param>

    <xsl:param name="filterPackages" as="xs:string*" select="(
        'com.travellinck.tags.meaningful',
        'com.travellinck.tags.meaningful.impl',
        'com.travellinck.tags.meaningful.reporting.plugins',
        'com.travellinck.tags.meaningful.transIT',
        'com.travellinck.tags.meaningful.util')"/>

        <!--'com.travellinck.trip.observations',-->
        <!--'com.travellinck.trip.observations.impl')"/>-->

    <!-- Packages which are considered 'system' packages. Implementations of interfaces in these packages
         are not considered as bona fide "service implementations" -->
    <xsl:param name="systemPackages" as="xs:string*" select="('java','javax','net.jini')"/>


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
    <xsl:template match="package[@name = $filterPackages]">

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
                            <db:para><xsl:value-of select="@name"/></db:para>
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
                                    <db:link linkend="{type/@qualified}"><xsl:value-of select="type/@qualified"/></db:link>
                                </db:para>
                            </db:formalpara>
                        </db:listitem>
                    </xsl:for-each>
                </db:orderedlist>
            </xsl:if>

            <xsl:if test="not(empty($output))">
                <db:para>Output:</db:para>
                <db:orderedlist>
                    <db:listitem>
                        <db:formalpara>
                            <db:title>return</db:title>
                            <db:para>
                                <db:link linkend="{$output/@qualified}"><xsl:value-of select="$output/@qualified"/></db:link>
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
                <db:table>
                    <!--<db:title>Method(s) offered by <xsl:value-of select="@name"/></db:title>-->
                    <db:tgroup cols="4">
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


    <xsl:template name="portTypeOverview">
        <xsl:param name="portType"/>
        <xsl:variable name="ops" select="$portType/operation"/>
        <xsl:copy-of select="df:wsdlDocumentationToParas( $portType/documentation/text() )"/>
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



    <xsl:template match="operation">
        <db:section>
            <db:title>Use-case: <xsl:value-of select="@name"/></db:title>

            <xsl:copy-of select="df:wsdlDocumentationToParas(documentation)"/>

            <xsl:call-template name="operationOverview">
                <xsl:with-param name="operation" select="."/>
            </xsl:call-template>

            <xsl:apply-templates/>
        </db:section>

    </xsl:template>


    <xsl:template name="operationOverview">
        <xsl:param name="operation"/>
        <xsl:variable name="serviceType" select="if ( not(empty($operation/input)) and not(empty($operation/output)))
            then 'request/response (synchronous)' else 'input-only (async)'"/>
        <xsl:variable name="preCondCount" select="count($operation/fault)"/>
        <xsl:variable name="preCondInd" select="if ($preCondCount eq 0) then 'no' else $preCondCount"/>
        <db:para>
            This is a <db:emphasis><xsl:value-of select="$serviceType"/></db:emphasis> service with
            <xsl:value-of select="$preCondInd"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="df:pluralise('pre-condition', $preCondCount)"/>
            <xsl:text>.</xsl:text>
        </db:para>
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
            <xsl:for-each select="$paras">
                <db:para><xsl:value-of select="."/></db:para>
            </xsl:for-each>
        </xsl:if>
    </xsl:function>

</xsl:stylesheet>