<?xml version="1.0" encoding="UTF-8"?>
<!-- XML Schema to XHTML Documentation Generator
     
     @version 0.2 (26 Sept 2005)
     @author  Dawid Loubser (Solms TCD)
     
     This is a style sheet to generically create XHTML documentation for a single
     XML Schema. It aims to do so in a self-contained and elegant manner, and relies
     on standard <annotation> and <documentation> tags. Some features:
     
     - Supports object-orientation (extension and restriction)
     - Supports both Anonymous and Explicit types properly
     - Correctly renders any combination fo xs:all, xs:sequence, xs:choice, etc to unlimited nested levels
     - Attribute and Element groups (and references thereto) properly handled and expanded
     - Multiplicities
     
     Inter-linking (to types, etc) is very primitive, and works best if built-in schema types are
     prepended with a 'xs:' or 'xsd:' prefix.
     
     TODO: Improve interlinking mechanism and namespace handling.     
     TODO: Support xs:anyAttribute
     TODO: Support imported schemas (componentisation)
-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.w3.org/1999/xhtml">
    
    <!-- Properly set output format, including DOCTYPE headers, etc for XHTML Strict -->
    <xsl:output method="xml" 
        doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
    
    <!-- Main schema body -->
    <xsl:template match="/xs:schema" xml:space="preserve">
        <html>
            <head>
                <title>XML Schema Documentation</title>
                <style type="text/css">
                    
                    /* Styles to control visual apprearance of schema documentation. */
                    
                    html
                    {
                      font-family: Georgia, times;
                      font-size: 11pt;
                      background-color: #cdeddd;
                    }
                    
                    body
                    {
                      width: 75%;
                      margin-left: auto;
                      margin-right: auto;
                      background-color: white;
                      border: 1px solid #009e4c;
                      padding: 10px;
                    }
                    
                    h1
                    {
                      padding: 5px;
                      color: white;
                      background-color: #009e4c;
                      margin: 0 0 7px 0;
                    }
                    
                    h2
                    {
                      margin: 0 0 7px 0;
                    }
                    
                    h5
                    {
                      margin: 0 0 7px 0;
                    }
                    
                    .nameSpace
                    {
                      color: red;
                    }
                    
                    .footer
                    {
                      color: grey;
                      background-color: #EEE;
                      font-size: 0.8em;
                    }
                    
                    .footer em
                    {
                      color: #009e4c;
                    }
                    
                    div.rootElements, div.types
                    {
                      padding: 5px;
                    }
                    
                    div.rootElements
                    {
                    }
                    
                    div.types
                    {
                    }
                    
                    div.rootElements h3, div.types h3
                    {
                      margin: 0 0 10px 0;
                      padding: 5px 5px 5px 0;
                      border-width: 0 0 2px 0;
                      border-style: solid;
                      color: #009e4c;
                      border-color: #009e4c;
                    }
                    
                    div.simpleType, div.complexType
                    {
                      padding: 5px;
                      margin: 0 0 15px 0;
                    }
                    
                    
                    .complexTypeIcon, .simpleTypeIcon
                    {
                      font-weight: bold;
                      border: 2px solid;
                      padding: 2px;
                      margin-right: 5px;
                      background-color: white;
                      font-size: 0.8em;
                    }
                    
                    .complexTypeIcon
                    {
                      color: blue;
                      border-color: blue;
                    }
                    
                    .simpleTypeIcon
                    {
                      color: brown;
                      border-color: brown;
                    }
                    
                    div.complexType h4, div.simpleType h4
                    {
                      margin: 0 0 5px 0;
                      border: 1px solid black;
                      border-width: 0 0 1px 0;
                    }
                    
                    span.hierarchyInfo, span.typeInfo
                    {
                      color: grey;
                      font-weight: normal;
                      font-size: 0.9em;
                    }
                    
                    span.hierarchyInfo em, span.typeInfo em
                    {
                      text-decoration: underline;
                    }
                    
                    p.xsdDoc
                    {
                      margin-left: 5px;
                    }
                    
                    code.tagName, code.attribute
                    {
                      font-family: 'Courier New',courier,fixed;
                      color: red;
                      font-weight: bold;
                      font-size: 0.9em;
                    }
                    
                    div.elementSequence
                    {
                      margin: 5px;
                      padding: 5px;
                      border-width: 0 0 1px 2px;
                      border-style: solid;
                      border-color: green;
                    }
                    
                    h5.elementSequence
                    {
                      color: green;
                    }
                    
                    div.choice
                    {
                      margin: 5px;
                      padding: 5px;
                      border-width: 0 0 1px 2px;
                      border-style: solid;
                      border-color: blue;
                    }
                    
                    h5.choice
                    {
                      color: blue;
                    }
                    
                    .choiceText
                    {
                      color: blue;
                    }
                    
                    p.choiceText
                    {
                      margin: 0 0 0 20px;
                    }
                    
                    div.groupRef
                    {
                      clear: both;
                      background-color: #EEEEEE;
                      margin-bottom: 4px;
                      padding: 4px;
                      color: grey;
                    }
                    
                    div.groupRef div.groupLink
                    {
                      /*background-color: #DDDDDD;*/
                      font-size: 0.9em;
                      width: 30%;
                      float: right;
                      clear: both;
                      padding: 2px;
                      color: grey;
                      text-align: right;
                    }
                    
                    div.element
                    {
                      padding-left: 2px;
                    }
                    
                    div.element p.xsdDoc
                    {
                      margin-top: 0px;
                      font-size: 0.9em;
                    }
                    
                    div.simpleRestriction
                    {
                      margin: 5px;
                      padding: 5px;
                      border-width: 0 0 0 2px;
                      border-style: solid;
                      border-color: purple;
                    }
                    
                    div.simpleRestriction span.type
                    {
                      color: purple;
                      font-weight: bold;
                    }
                    
                    div.typeReferenceList
                    {
                      background-color: #EEEEEE;
                      color: #666666;
                      font-size: 0.9em;
                      margin-left: 5px;
                    }
                    
                    div.attributes
                    {
                      margin: 5px;
                      padding: 5px;
                      border-width: 0 0 1px 2px;
                      border-style: solid;
                      border-color: orange;
                    }
                    
                    h5.attributes
                    {
                      color: orange;
                    }
                    
                    span.multiplicity
                    {
                      color: green;
                      font-size: 0.9em;
                    }
                    
                </style>
            </head>
            <body> 
                <h1>XML Schema Documentation</h1>
                <xsl:if test="@targetNamespace">
                    <h2 class="nameSpace"><xsl:value-of select="@targetNamespace"/></h2>
                </xsl:if>
                
                <xsl:apply-templates select="xs:annotation"/>
                <xsl:call-template name="rootElements"/>
                <xsl:call-template name="rootTypes"/>
                <xsl:call-template name="footer"/>
            </body>
        </html>
    </xsl:template>
    

    <!-- Annotation -->
    <xsl:template match="xs:annotation">
        <div class="xsdAnno">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    
    <!-- Documentation -->
    <xsl:template match="xs:documentation">
        <p class="xsdDoc">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    
    <!-- Footer -->
    <xsl:template name="footer" xml:space="preserve">
        <div class="footer">
            W3C XML Schema Documentation Automatically generated by 
            <a href="http://www.solms.co.za/">Solms TCD</a> <em>xsd2xhtml</em>. 
            No rights reserved.
        </div>
    </xsl:template>
    
    <!-- Base list of all elements -->
    <xsl:template name="rootElements">
        <div class="rootElements">
            <h3>Root elements:</h3>
            <xsl:choose>
                <xsl:when test="/xs:schema/xs:element">
                    <xsl:apply-templates select="/xs:schema/xs:element">
                        <xsl:sort data-type="text" select="@name"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <p>
                        This schema does not define any root elements. It can thus not be used to
                        validate instance documents wihout it being included into another schema
                        (it is only a container for re-usable types).
                    </p>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    
    <!-- Base list of all types -->
    <xsl:template name="rootTypes">
        <div class="types">
            <h3>Types:</h3>
            <xsl:choose>
                <xsl:when test="/xs:schema/xs:complexType|/xs:schema/xs:simpleType">
                    <xsl:apply-templates select="/xs:schema/xs:complexType|/xs:schema/xs:simpleType">
                        <!-- Sort alphabetically by name -->
                        <xsl:sort data-type="text" select="@name"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <p>
                        This schema does not define any explicit (re-usable) types. It can thus not be
                        re-used in a component-oriented environment.
                    </p>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    
    <!-- Elements -->
    <xsl:template match="xs:element">
        <div class="element">
            <xsl:element name="a">
                <xsl:attribute name="name">
                    <xsl:value-of select="@name"/>
                </xsl:attribute>
            </xsl:element>
            <code class="tagName">&lt;<xsl:value-of select="@name"/>&gt;</code>            

            <!-- Type -->
            <xsl:apply-templates select="@type"/>
            
            <!-- Multiplicity -->
            <xsl:call-template name="multiplicity">
                <xsl:with-param name="element" select="."/>
            </xsl:call-template>
            
            <!-- Documentation -->
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- Referenced Elements -->
    <xsl:template match="xs:element[@ref]" priority="1">
        <div class="element">
            <xsl:element name="a">
                <xsl:attribute name="name">
                    <xsl:value-of select="@name"/>
                </xsl:attribute>
            </xsl:element>
            <code class="tagName">&lt;<xsl:value-of select="@ref"/>&gt;</code> (Reference to: <xsl:call-template name="linkToElementReference"><xsl:with-param name="element" select="@ref"></xsl:with-param></xsl:call-template>)            

            <!-- Type -->
            <xsl:apply-templates select="@type"/>
            
            <!-- Multiplicity -->
            <xsl:call-template name="multiplicity">
                <xsl:with-param name="element" select="."/>
            </xsl:call-template>
            
            <!-- Documentation -->
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    
    <!-- Element Type -->
    <xsl:template match="@type">
        <xsl:text xml:space="preserve"> </xsl:text>
        <span class="typeInfo">(type 
            <xsl:text xml:space="preserve"> </xsl:text>
            <xsl:call-template name="linkToType">
                <xsl:with-param name="typeName">
                    <xsl:value-of select="."/>
                </xsl:with-param>
            </xsl:call-template>
        )</span>
    </xsl:template>
    
    
    <!-- Group Reference -->
    <xsl:template match="xs:group[@ref]">
        <xsl:variable name="ref" select="@ref"/>
        <div class="groupRef">
            <div class="groupLink">
                <em><xsl:value-of select="$ref"/></em>
            </div>
            <xsl:apply-templates select="/*//xs:group[@name=$ref]/*"/>
        </div>
    </xsl:template>
    
    
    <!-- Complex Types -->
    <xsl:template match="xs:complexType">
        <div class="complexType">
            <xsl:element name="a">
                <xsl:attribute name="name">
                    <xsl:value-of select="@name"/>
                </xsl:attribute>
            </xsl:element>
            <h4>
                <span class="complexTypeIcon"  title="Complex Type">C</span>
                <!-- Is it an anonymous type or not? -->
                <xsl:choose>
                    <xsl:when test="@name">
                        <xsl:value-of select="@name"/>
                    </xsl:when>
                    <xsl:otherwise>
                        (anonymous type)
                    </xsl:otherwise>
                </xsl:choose>
                
                <!-- Is it abstract? -->
                <xsl:if test="@abstract='true'">
                    <xsl:text xml:space="preserve"> </xsl:text>
                    (abstract)
                </xsl:if>
                
                <!-- Is it mixed? -->
                <xsl:if test="@mixed='true'">
                    <xsl:text xml:space="preserve"> </xsl:text>
                    (<acronym title="Can contain character children">mixed</acronym>)
                </xsl:if>
                
                <!-- Does it extend anything? -->
                <xsl:call-template name="extensionHeader">
                    <xsl:with-param name="type" select="."/>
                </xsl:call-template>
            </h4>

            <!-- Attributes -->
            <xsl:call-template name="createAttributeList">
                <xsl:with-param name="type" select="."/>
            </xsl:call-template>
            
            <!-- Any other supported structural elements -->
            <xsl:apply-templates select="xs:all | xs:annotation | xs:choice | xs:complexContent | xs:group | xs:sequence | xs:simpleContent"/>
            
            <!-- Known Users -->
            <xsl:call-template name="knownUsers">
                <xsl:with-param name="type" select="."/>
            </xsl:call-template>
        </div>
    </xsl:template>
    
    <!-- Simple Type -->
    <xsl:template match="xs:simpleType">
        <div class="simpleType">
            <xsl:element name="a">
                <xsl:attribute name="name">
                    <xsl:value-of select="@name"/>
                </xsl:attribute>
            </xsl:element>
            <h4>
                <span class="simpleTypeIcon" title="Simple Type">S</span>
                <xsl:value-of select="@name"/>
                
                <!-- Does it extend anything? -->
                <xsl:call-template name="extensionHeader">
                    <xsl:with-param name="type" select="."/>
                </xsl:call-template>
            </h4>
            
            <xsl:apply-templates/>
            
            <!-- Known Users -->
            <xsl:call-template name="knownUsers">
                <xsl:with-param name="type" select="."/>
            </xsl:call-template>
        </div>
    </xsl:template>
    
    <!-- Template for dealing with extensions/restrictions (short header) -->
    <xsl:template name="extensionHeader">
        <xsl:param name="type"/>
        <span class="hierarchyInfo">
            <xsl:if test="$type/*/xs:extension">
                (extends 
                <xsl:call-template name="linkToType">
                    <xsl:with-param name="typeName">
                        <xsl:value-of select="$type/*/xs:extension/@base"/>
                    </xsl:with-param>
                </xsl:call-template>
                )
            </xsl:if>
            <xsl:if test="$type/xs:restriction">
                (restricts 
                <xsl:call-template name="linkToType">
                    <xsl:with-param name="typeName">
                        <xsl:value-of select="$type/xs:restriction/@base"/>
                    </xsl:with-param>
                </xsl:call-template>
                )
            </xsl:if>
        </span>
    </xsl:template>
    
    
    <!-- Creates linked text to the given type as a parameter -->
    <xsl:template name="linkToType">
        <xsl:param name="typeName"/>
        <xsl:choose>
            <!-- Don't link to schema types (this is a stupid impl)-->
            <xsl:when test="starts-with($typeName, 'xs:') or starts-with($typeName, 'xsd:')">
                <em><xsl:value-of select="$typeName"/></em>
            </xsl:when>
            <!-- Strip namespace and link -->
            <xsl:when test="contains($typeName, ':')">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        #<xsl:value-of select="substring-after($typeName, ':')"/>
                    </xsl:attribute>
                    <xsl:value-of select="substring-after($typeName, ':')"/>
                </xsl:element>
            </xsl:when>
            <!-- Link as-is -->
            <xsl:otherwise>
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        #<xsl:value-of select="$typeName"/>
                    </xsl:attribute>
                    <xsl:value-of select="$typeName"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Creates linked text to the given referenced element as a parameter -->
    <xsl:template name="linkToElementReference">
        <xsl:param name="element"/>
        <xsl:choose>
            <!-- Strip namespace and link -->
            <xsl:when test="contains($element, ':')">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        #<xsl:value-of select="substring-after($element, ':')"/>
                    </xsl:attribute>
                    <xsl:value-of select="substring-after($element, ':')"/>
                </xsl:element>
            </xsl:when>
            <!-- Link as-is -->
            <xsl:otherwise>
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        #<xsl:value-of select="$element"/>
                    </xsl:attribute>
                    <xsl:value-of select="$element"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Sequence of elements -->
    <xsl:template match="xs:sequence">
        <div class="elementSequence">
            <h5 class="elementSequence">Sequence:</h5>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- Choice -->
    <xsl:template match="xs:choice">
        <div class="choice">
            <h5 class="choice">One of:</h5>
            <xsl:for-each select="*">
                <div class="choiceItem">
                    <xsl:apply-templates select="."/>
                </div>
                <xsl:if test="position() != last()">
                    <p class="choiceText">or</p>
                </xsl:if>
            </xsl:for-each>
        </div>
    </xsl:template>
    
    <!-- All elements (No Order) -->
    <xsl:template match="xs:all">
        <div class="elementAll">
            <h5>All of (in any order):</h5>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- Enumeration restriction -->
    <xsl:template match="xs:enumeration" priority="1">
        <div class="simpleRestriction">
            Legal value: 
            <span class="type"><xsl:value-of select="@value"/></span>
        </div>
    </xsl:template>
    
    <!-- Common Simple Type Restrictions (patterns, sizes, etc) -->
    <xsl:template xml:space="preserve"
        match="*[parent::xs:restriction]">
        <div class="simpleRestriction">
            Restriction: 
            <span class="type"><xsl:value-of select="local-name(.)"/></span>
            <xsl:if test="@value">
                <code><xsl:value-of select="@value"/></code>
            </xsl:if>
        </div>
    </xsl:template>
    
    <!-- Generates a list of the known "users" of a type (within the same schema) -->
    <xsl:template name="knownUsers">
        <!-- The node that is a complex or simple type -->
        <xsl:param name="type"/>
        <xsl:variable name="typeName" select="$type/@name"/>
        <xsl:if test="/*/xs:complexType[ descendant::*/@*[ string(.) = $typeName or substring-after(.,':' ) = $typeName ] ]">
            <div class="typeReferenceList">            
                Known dependants: 
                <xsl:for-each select="/*/xs:complexType[ descendant::*/@*[ string(.) = $typeName or substring-after(.,':' ) = $typeName ] ]">
                            <xsl:call-template name="linkToType">
                                <xsl:with-param name="typeName">
                                    <xsl:value-of select="ancestor-or-self::xs:complexType/@name"/>
                                </xsl:with-param>
                            </xsl:call-template>
                    <!-- Comma -->
                    <xsl:if test="position() != last()" xml:space="preserve">, </xsl:if>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>
    
    <!-- Generates a list of attributes for a type (just the explicit ones) -->
    <xsl:template name="createAttributeList">
        <!-- The type (node) to generate list for -->
        <xsl:param name="type"/>
        
        <xsl:if test="$type/descendant::xs:attribute | $type//descendant::xs:attributeGroup">
            <div class="attributes">
                <h5 class="attributes">Attributes</h5>
                <xsl:apply-templates select="$type//descendant::xs:attribute"/>
                <xsl:apply-templates select="$type//descendant::xs:attributeGroup"/>
            </div>
        </xsl:if>
    </xsl:template>
    
    <!-- A single atribute -->
    <xsl:template match="xs:attribute">
        <div class="attribute">
            <code class="attribute">
                <xsl:value-of select="@name"/>
            </code>
            <xsl:apply-templates select="@type"/>
            
            <xsl:call-template name="attributeMultiplicity">
                <xsl:with-param name="attribute" select="."/>
            </xsl:call-template>
        </div>
    </xsl:template>
    
    <!-- An attribute group (reference)-->
    <xsl:template match="xs:attributeGroup[@ref]">
        <xsl:variable name="refName" select="@ref"/>
        <div class="groupRef">
            <div class="groupLink">
                <em><xsl:value-of select="$refName"/></em>
            </div>
            <xsl:choose>
                <xsl:when test="/*//xs:attributeGroup[@name=$refName]/*">
                    <xsl:apply-templates select="/*//xs:attributeGroup[@name=$refName]/*"/>
                </xsl:when>
                <xsl:otherwise>
                    ( no details )
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    
    <!-- Generates a small multiplicity string for elements -->
    <xsl:template name="multiplicity" xml:space="default">
        <xsl:param name="element"/>
        <span class="multiplicity">
            
        <xsl:variable name="min">
            <xsl:choose>
              <xsl:when test="$element[@minOccurs]">
                  <xsl:value-of select="$element/@minOccurs"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
            
        <xsl:variable name="max">
            <xsl:choose>
              <xsl:when test="$element[@maxOccurs='unbounded']">
                  *
              </xsl:when>
              <xsl:when test="$element[@maxOccurs]">
                  <xsl:value-of select="$element/@maxOccurs"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
            
        [<xsl:choose>
            <xsl:when test="$min = $max">
                <xsl:value-of select="$min"/>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="$min"/>..<xsl:value-of select="$max"/></xsl:otherwise>
        </xsl:choose>]
        </span>
    </xsl:template>
    
    <!-- Generates a small multiplicity string for attributes -->
    <xsl:template name="attributeMultiplicity" xml:space="default">
        <xsl:param name="attribute"/>
        <span class="multiplicity">

        <xsl:variable name="usage">
            <xsl:choose>
              <xsl:when test="$attribute[@use='prohibited']">
                  <span class="prohibited">PROHIBITED</span>
              </xsl:when>
              <xsl:when test="$attribute[@use]">
                  <xsl:value-of select="$attribute/@use"/>
              </xsl:when>
              <xsl:otherwise>optional</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
            
        (<xsl:value-of select="$usage"/>)
        </span>
    </xsl:template>
    
</xsl:stylesheet>