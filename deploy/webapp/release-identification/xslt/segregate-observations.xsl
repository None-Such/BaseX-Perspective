<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:sxx="http://www.SoundExchange/ns/xslt/util" exclude-result-prefixes="#all" version="2.0">

   <xsl:import href="import/debug-support.xsl"/>
   
   <xsl:import href="import/make-observations.xsl"/>
   
   <xsl:strip-space elements="*"/>
   <!--<xsl:output indent="yes"/>-->

   <xsl:variable name="transformVersion" select="'0.1.0'"/>

   <xsl:variable name="transformDescription">
      <description>
         <xsl:text>Rewrites observation types with qualifications for faceting.</xsl:text>
      </description>
   </xsl:variable>

   <xsl:param name="debug" select="'false'"/>

   <xsl:variable name="transformParameters" as="element()*">
      <param name="debug">
         <xsl:value-of select="$debug"/>
      </param>
   </xsl:variable>

   <xsl:variable name="xsltFilename" select="replace(document-uri(document('')),'.*/','')"/>

   <xsl:variable name="debugging" select="$debug='true'"/>

   <xsl:template match="node() | @*">
      <xsl:copy>
         <xsl:apply-templates select="node() | @*"/>
      </xsl:copy>
   </xsl:template>

   <xsl:template match="observations">
      <xsl:variable name="observations">
         <observations>
            <xsl:apply-templates select="*"/>
         </observations>
      </xsl:variable>
      <xsl:apply-templates select="$observations/observations" mode="renumber"/>
   </xsl:template>
   

   <!-- Rewriting observation/@type attributes as follows:
   
   If an sxx: element is retrieved from variable $qualifications whose local name
   is the observation/@type, the @type is prefixed with the name of the sxx: 
   element's parent. Otherwise the type is preserved. -->
   
   <xsl:template match="observation/@type">
      <xsl:attribute name="type"
         select="string-join(
         (key('qualification-for-type',.,$qualifications)/name(),.),'.')"/>
   </xsl:template>
   
   <!-- The key returns an element containing an element in the sxx namespace
        whose name is the value provided to the key. -->
   <xsl:key name="qualification-for-type" match="*" use="child::sxx:*/local-name()"/>
   
   <xsl:variable name="qualifications">
      <!-- An observation of @type 'comparative.comparison-sequence.location' is
           rewritten to 'debug.comparative.comparison-sequence.location'.
           Etc. -->
      <audit>
         <sxx:intrinsic.canonical.observations-performed/>
         <sxx:comparative.canonical.comparison-performed/>
         <sxx:reflective.canonical.is-comparable/>
         <sxx:reflective-refinement.canonical.no-comparison-performed/>
      </audit>
      <review>
         <sxx:reflective-combinatory.release.multiple-critical-values-missing/>
         <sxx:reflective-combinatory.release.multiple-critical-values-changed/>
         <sxx:reflective-combinatory.recording.multiple-critical-values-missing/>
         <sxx:reflective-combinatory.recording.multiple-critical-values-changed/>
      </review>
   </xsl:variable>

</xsl:stylesheet>
