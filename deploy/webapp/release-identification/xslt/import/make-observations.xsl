<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:sxx="http://www.SoundExchange/ns/xslt/util" exclude-result-prefixes="#all"
   version="2.0">

   <xsl:import href="provide-xpath.xsl"/>

   <!-- Templates in support of generating observations -->

   <xsl:variable name="xsltFilename" select="replace(document-uri(document('')),'.*/','')"/>

   <!-- Fallback template for document element if not matched in the calling stylesheet. -->
   <xsl:template match="/*">
      <EXCEPTION>
         <MESSAGE>
            <xsl:text>EXCEPTION: Incorrect document element provided to</xsl:text>
            <xsl:value-of select="$xsltFilename"/>
            <xsl:text>.</xsl:text>
         </MESSAGE>
         <SOURCE-DOCUMENT>
            <xsl:copy-of select="."/>
         </SOURCE-DOCUMENT>
      </EXCEPTION>
   </xsl:template>

   <!-- All observations should be generated using this template, or a template that calls it. -->
   <xsl:template name="make-observation">
      <xsl:param name="context" tunnel="yes" select="." as="node()"/>
      <xsl:param name="observationType" select="local-name()"/>
      <xsl:param name="test" select="true()"/>
      <xsl:param name="content" select="()"/>
      <xsl:param name="oi-c" select="()" as="xs:string*"/>
      <xsl:param name="itemContext" as="xs:string?" select="sxx:structural-context($context)"/>
      <xsl:param name="itemAddress" as="xs:string?" select="sxx:xpath($context)"/>
      <xsl:if test="$test">
         <observation type="{$observationType}">
            <xsl:if test="exists($itemAddress)">
               <xsl:attribute name="item-address" select="$itemAddress"/>
            </xsl:if>
            <xsl:if test="exists($itemContext)">
               <xsl:attribute name="item-context" select="$itemContext"/>
            </xsl:if>
            <xsl:if test="exists($oi-c)">
               <xsl:attribute name="oi-c" select="string-join($oi-c,' ')"/>
            </xsl:if>
            <xsl:copy-of select="$content"/>
         </observation>
      </xsl:if>
   </xsl:template>
   
   <xsl:template match="sxx:*">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="test" select="true()"/>
         <xsl:with-param name="content">
            <observation-detail type="exception">observation not implemented</observation-detail>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   
   
   <!-- Provides generic information regarding the context of a node, suitable for faceting. -->
   <xsl:function name="sxx:structural-context" as="xs:string?">
      <xsl:param name="n" as="element()?"/>
      <xsl:variable name="levels" select="2"/>
      <xsl:if test="exists($n)">
         <xsl:value-of select="string-join($n/ancestor-or-self::node()[position() = (1 to $levels)]/
            concat(self::attribute()/'@',name(.)),'/')"/>
      </xsl:if>
   </xsl:function>

   <!-- Provides information regarding the context of a node, with identifying information for
        releases and recordings
   <xsl:function name="sxx:canonical-context" as="element(local-context)">
      <xsl:param name="n" as="node()"/>
      <xsl:param name="levels" as="xs:integer"/>
      <local-context>
         <xsl:value-of select="string-join($n/ancestor-or-self::*[position() = (1 to $levels)]/sxx:identify(.),'/')"/>
      </local-context>
   </xsl:function> -->

   <!-- These templates are not currently being called (wap 2013-05-27). -->

   <!-- Generates an XPath step for a particular node $n by referring to templates in mode sxx:identify -->
   <xsl:function name="sxx:identify" as="xs:string">
      <xsl:param name="n" as="node()"/>
      <xsl:apply-templates select="$n" mode="sxx:identify"/>
   </xsl:function>

   <xsl:template match="*" mode="sxx:identify" as="xs:string">
      <xsl:value-of select="name()"/>
   </xsl:template>

   <xsl:template match="@*" mode="sxx:identify" as="xs:string">
      <xsl:value-of>
         <xsl:text>@</xsl:text>
         <xsl:value-of select="name()"/>
      </xsl:value-of>
   </xsl:template>

   <xsl:template match="recording" mode="sxx:identify" as="xs:string">
      <xsl:value-of>
         <xsl:text>recording[isrc='</xsl:text>
         <xsl:value-of select="isrc"/>
         <xsl:text>']</xsl:text>
      </xsl:value-of>
   </xsl:template>

   <xsl:template match="observation" mode="sxx:identify" as="xs:string">
      <xsl:value-of>
         <xsl:text>observation[@type='</xsl:text>
         <xsl:value-of select="@type"/>
         <xsl:text>']</xsl:text>
         <!--<xsl:if test="preceding-sibling::observation/@type = current()/@type">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(.|preceding-sibling::observation/@type = current()/@type)"/>
            <xsl:text>]</xsl:text>
         </xsl:if>-->
      </xsl:value-of>
   </xsl:template>

   <!-- Overriding the template from xpath-write.xsl for this application. -->
   <xsl:template match="/" mode="sxx:xpath-step"/>
   
   <!-- Mode renumbered observations assigns new @oi values to
        observations in sequence, preserving the referential
        integrity of @oi-c values they already carry. -->
   
   <xsl:function name="sxx:new-oi" as="xs:string">
      <xsl:param name="o" as="element(observation)"/>
      <xsl:number select="$o"/>
   </xsl:function>
   
   <xsl:key name="observation-by-oi"
      match="observation" use="@oi"/>
   
   <xsl:template match="observations" mode="renumber">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates select="*" mode="renumber"/>
      </xsl:copy>
   </xsl:template>
   
   <xsl:template match="observation" mode="renumber">
     <xsl:copy>
        <!-- Handling attributes in the optimal order in case the processor
             respects it (Saxon should). -->
        <xsl:attribute name="oi" select="sxx:new-oi(.)"/>
        <xsl:for-each select="@oi-c">
           <xsl:attribute name="oi-c"
              select="string-join(key('observation-by-oi',tokenize(.,'\s+'))/sxx:new-oi(.),' ')"/>
        </xsl:for-each>
        <xsl:copy-of select="@type, (@* except (@oi | @oi-c | @type))"/>
        <xsl:copy-of select="*"/>
     </xsl:copy>
   </xsl:template>
   
   <!-- Utility functions -->
   <xsl:function name="sxx:observed-field-name" as="xs:string?">
      <!-- returns the element name of the context of an observation -->
      <xsl:param name="o" as="element(observation)"/>
      <xsl:sequence select="tokenize($o/@item-address,'/')[last()]"/>
   </xsl:function>
   
</xsl:stylesheet>
