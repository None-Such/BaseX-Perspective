<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:sxx="http://www.SoundExchange/ns/xslt/util" exclude-result-prefixes="#all">

   <!-- XPath-writing logic - only works on "namespace clean" documents -->

   <!-- (Results on documents with namespace prefix reassignments cannot be
        guaranteed.) -->

   <xsl:function name="sxx:xpath" as="xs:string?">
      <xsl:param name="node" as="node()?"/>
      <xsl:value-of>
         <xsl:apply-templates select="$node" mode="sxx:xpath"/>
      </xsl:value-of>
   </xsl:function>

   <xsl:template match="/ | node() | @*" mode="sxx:xpath">
      <xsl:apply-templates select="parent::*" mode="sxx:xpath"/>
      <xsl:apply-templates select="." mode="sxx:xpath-step"/>
   </xsl:template>

   <xsl:template match="/" priority="1" mode="sxx:xpath-step">
      <xsl:text>/</xsl:text>
   </xsl:template>
   
   <xsl:template match="*" mode="sxx:xpath-step">
      <xsl:text>/</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:call-template name="position-among">
         <xsl:with-param name="set" select="../*[node-name(.)=node-name(current())]"/>
      </xsl:call-template>
   </xsl:template>

   <xsl:template match="text()" mode="sxx:xpath-step">
      <xsl:text>/text()</xsl:text>
      <xsl:call-template name="position-among">
         <xsl:with-param name="set" select="../text()"/>
      </xsl:call-template>
   </xsl:template>

   <xsl:template match="processing-instruction()" mode="sxx:xpath-step">
      <xsl:text>/processing-instruction()</xsl:text>
      <xsl:call-template name="position-among">
         <xsl:with-param name="set" select="../processing-instruction()"/>
      </xsl:call-template>
   </xsl:template>

   <xsl:template match="comment()" mode="sxx:xpath-step">
      <xsl:text>/comment()</xsl:text>
      <xsl:call-template name="position-among">
         <xsl:with-param name="set" select="../comment()"/>
      </xsl:call-template>
   </xsl:template>

   <xsl:template name="position-among">
      <xsl:param name="this" select="."/>
      <xsl:param name="set" required="yes"/>
      <xsl:if test="count($set) > 1">
         <xsl:text>[</xsl:text>
         <xsl:value-of select="count($this|$set[. &lt;&lt; $this])"/>
         <xsl:text>]</xsl:text>
      </xsl:if>
   </xsl:template>

   <xsl:template match="@*" mode="sxx:xpath-step">
      <xsl:text>/@</xsl:text>
      <xsl:value-of select="name()"/>
   </xsl:template>

</xsl:stylesheet>
