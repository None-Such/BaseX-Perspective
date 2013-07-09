<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:sxx="http://www.SoundExchange/ns/xslt/util" exclude-result-prefixes="#all"
   version="2.0">
   
   <xsl:import href="../import/debug-support.xsl"/>
   
   <xsl:import href="../import/make-observations.xsl"/>
   
   <xsl:strip-space elements="*"/>
   <!--<xsl:output indent="yes"/>-->
   
   <xsl:variable name="transformVersion" select="'0.1.0'"/>
   
   <xsl:variable name="transformDescription">
      <description>
         <xsl:text>Generates observations identifying a container within a comparison sequence.</xsl:text>
      </description>
   </xsl:variable>
   
   <xsl:param name="debug" select="'false'"/>
   
   <xsl:variable name="transformParameters" as="element()*">
      <param name="debug"><xsl:value-of select="$debug"/></param>
   </xsl:variable>
   
   <xsl:variable name="xsltFilename" select="replace(document-uri(document('')),'.*/','')"/>
   
   <xsl:variable name="debugging" select="$debug='true'"/>

   <!-- suppressing all output in the default traversal -->
   <xsl:template match="text() | @*"/>
   
   <!-- but we are examining attributes -->
   <xsl:template match="*/*" priority="-0.5">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template match="/container-sequence" priority="5">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>
    
   <xsl:template match="sx-container">
      <xsl:variable name="observations">
         <observations>
            <xsl:copy-of select="observations/*"/>
            <xsl:apply-templates select="." mode="observe-comparison-sequence"/>
         </observations>
      </xsl:variable>
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:copy-of select="sx-manifest"/>
         <xsl:apply-templates select="$observations" mode="renumber"/>
         <xsl:copy-of select="canonical, provider-message"/>
         <xsl:apply-templates select="." mode="debug"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="sx-container" mode="observe-comparison-sequence">
      <xsl:variable name="tests" as="element()*">
         <sxx:debug.comparative.comparison-sequence.location/>
         <sxx:debug.comparative.comparison-sequence.is-last/>
      </xsl:variable>
      <xsl:apply-templates select="$tests">
         <xsl:with-param name="context" select="." tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>
   
   <xsl:template match="sxx:debug.comparative.comparison-sequence.location">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="test" select="true()"/>
         <xsl:with-param name="itemAddress" select="()"/>
         <xsl:with-param name="itemContext" select="()"/>
         <xsl:with-param name="content">
            <observation-detail type="position">
               <xsl:value-of select="count($context|$context/preceding-sibling::*)"/>
            </observation-detail>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template match="sxx:debug.comparative.comparison-sequence.is-last">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="itemAddress" select="()"/>
         <xsl:with-param name="itemContext" select="()"/>
         <xsl:with-param name="test" select="empty($context/following-sibling::*)"/>
      </xsl:call-template>
   </xsl:template>
   
</xsl:stylesheet>