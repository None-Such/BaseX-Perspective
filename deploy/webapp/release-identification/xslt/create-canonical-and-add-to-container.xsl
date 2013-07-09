<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   exclude-result-prefixes="xs"
   version="2.0">
   
   <!-- Imported by generate-canonical.xsl: <xsl:import href="import/debug-support.xsl"/>-->
   
   <xsl:import href="import/generate-canonical.xsl"/>

   <xsl:variable name="transformVersion" select="'0.1.0'"/>
   
   <xsl:variable name="transformDescription">
      <description>
         <xsl:text>Adds canonical version of message to message container. </xsl:text>
         <xsl:text>Removes original message unless $debug='true'.</xsl:text>
      </description>
   </xsl:variable>
   
   <xsl:param name="debug" select="'false'"/>
   <xsl:param name="showProvenance" select="'true'"/>
   <xsl:param name="provider" select="(/sx-container/sx-manifest/provider,'[PROVIDER-NOT-GIVEN]')[1]"/>

   <xsl:variable name="transformParameters" as="element()*">
      <param name="debug"><xsl:value-of select="$debug"/></param>
      <param name="showProvenance"><xsl:value-of select="$showProvenance"/></param>
      <param name="provider"><xsl:value-of select="$provider"/></param>
   </xsl:variable>
   
   <xsl:variable name="xsltFilename" select="replace(document-uri(document('')),'.*/','')"/>
   
   <xsl:variable name="debugging" select="$debug='true'"/>

   <xsl:template match="/sx-container" priority="5">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:copy-of select="sx-manifest"/>
         <xsl:apply-templates select="provider-message" mode="generate-canonical"/>
         <xsl:copy-of select="provider-message[$debugging]"/>
         <xsl:apply-templates select="." mode="debug"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="provider-message" mode="generate-canonical">
      <xsl:apply-templates mode="generate-canonical"/>
   </xsl:template>
   
   <xsl:template match="/*">
      <EXCEPTION>
         <xsl:text>EXCEPTION: sx-container element expected by add-canonical-to-container.xsl; </xsl:text>
         <xsl:value-of select="name()"/>
         <xsl:text> was found.</xsl:text>
      </EXCEPTION>
   </xsl:template>
   
   
</xsl:stylesheet>