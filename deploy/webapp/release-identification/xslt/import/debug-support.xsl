<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   exclude-result-prefixes="xs"
   version="2.0">

   <!-- All variable declarations should be overridden in the calling stylesheet -->

   <xsl:variable name="debugging" select="true()"/>
   <xsl:variable name="transformDescription">
      <Description>[No description given]</Description>
   </xsl:variable>
   <xsl:variable name="transformVersion">X</xsl:variable>
   <xsl:variable name="xsltFilename">X</xsl:variable>
   <xsl:variable name="transformParameters" select="()"/>
   
   <xsl:template match="sx-container" mode="debug">
      <xsl:if test="$debugging or exists(debug)">
         <debug>
            <xsl:if test="$debugging">
               <step xslt-processor="{system-property('xsl:vendor')}" processor-version="{system-property('xsl:product-version')}">
                  <xslt version="{$transformVersion}">
                     <xsl:value-of select="$xsltFilename"/>
                  </xslt>
                  <xsl:copy-of select="$transformDescription"/>
                  <params>
                     <xsl:copy-of select="$transformParameters"/>
                  </params>
               </step>
            </xsl:if>
            <xsl:copy-of select="debug/*"/>
         </debug>
      </xsl:if>
   </xsl:template>
   
   <xsl:template match="*" mode="debug">
      <EXCEPTION>
         <xsl:text>EXCEPTION: element '</xsl:text>
         <xsl:value-of select="name()"/>
         <xsl:text>' unexpectedly matched in 'debug' mode. In debug-support.xsl called by </xsl:text>
         <xsl:value-of select="$xsltFilename"/>
      </EXCEPTION>
   </xsl:template>
   
</xsl:stylesheet>