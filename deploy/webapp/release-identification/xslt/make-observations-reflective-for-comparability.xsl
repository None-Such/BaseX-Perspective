<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:sxx="http://www.SoundExchange/ns/xslt/util"
   exclude-result-prefixes="#all"
   version="2.0">
   
   <!-- Assesses whether a canonical meets integrity requirements for comparability
        by examining observations; if any are detected that preclude comparability,
        they are reported; otherwise an observation is made that comparability may be assumed. -->
   
   <!-- Source document should be either an sx-container or an observations element. -->

   <xsl:import href="import/debug-support.xsl"/>
   
   <xsl:import href="import/make-observations.xsl"/>
   
   <xsl:strip-space elements="*"/>
   <!--<xsl:output indent="yes"/>-->
   
   <xsl:variable name="transformVersion" select="'0.1.0'"/>
   
   <xsl:variable name="transformDescription">
      <description>
         <xsl:text>Generates observations regarding canonical comparability by inspecting (intrinsic) observations in container.</xsl:text>
      </description>
   </xsl:variable>

   <xsl:param name="debug" select="'false'"/>
   
   <xsl:variable name="transformParameters" as="element()*">
      <param name="debug"><xsl:value-of select="$debug"/></param>
   </xsl:variable>
   
   <xsl:variable name="xsltFilename" select="replace(document-uri(document('')),'.*/','')"/>
   
   <xsl:variable name="debugging" select="$debug = 'true'"/>
   
   <!-- Suppressing all output in the default traversal. -->
   <xsl:template match="text() | @*"/>
   
   <!-- But we are examining attributes -->
   <!-- This template does not match an element at the top level; if not matched by a
        template below, a template in import/make-observations.xsl will catch it
        (and generate an exception). -->
   <xsl:template match="*/*" priority="-0.5">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template match="/sx-container" priority="5">
      <xsl:variable name="observations">
         <xsl:apply-templates select="observations"/>
      </xsl:variable>
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:copy-of select="sx-manifest"/>
         <xsl:apply-templates select="$observations" mode="renumber"/>            
         <xsl:copy-of select="* except (sx-manifest | observations)"/>
         <xsl:apply-templates select="." mode="debug"/>
      </xsl:copy>
    </xsl:template>
   
   <xsl:template match="observations">
      <xsl:variable name="tests" as="element()*">
         <sxx:reflective-for-comparability.canonical.is-comparable/>
      </xsl:variable>
      <xsl:copy>
         <!-- generating observations by applying templates to observations -->
         <xsl:apply-templates/>
         <xsl:apply-templates select="$tests">
            <xsl:with-param name="context" tunnel="yes" select="."/>
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
   
   <xsl:template match="observation">
      <xsl:copy-of select="."/>
      <xsl:variable name="tests" as="element()*">
         <sxx:reflective-for-comparability.canonical.is-not-comparable/>
      </xsl:variable>
      <xsl:apply-templates select="$tests">
         <xsl:with-param name="context" tunnel="yes" select="."/>
      </xsl:apply-templates>
   </xsl:template>

   <xsl:variable name="comparabilityDisqualifiers" as="element()+">
      <sxx:intrinsic.canonical.missing-release/>
      <sxx:intrinsic.canonical.contains-multiple-releases/>
      <sxx:intrinsic.recording.repeats-isrc/>
   </xsl:variable>
   
   <xsl:template match="sxx:reflective-for-comparability.canonical.is-comparable">
      <xsl:param name="context" required="yes" tunnel="yes"/>
      <!-- $context is an observations element (with observation children) -->
      <xsl:call-template name="make-observation">
         <xsl:with-param name="test"
            select="not($context/observation/@type = $comparabilityDisqualifiers/local-name(.))"/>
         <xsl:with-param name="itemAddress" select="sxx:xpath($context/../canonical)"/>
         <xsl:with-param name="itemContext" select="sxx:structural-context($context/../canonical)"/>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template match="sxx:reflective-for-comparability.canonical.is-not-comparable">
      <xsl:param name="context" required="yes" tunnel="yes"/>
      <!-- $context is an observation element. -->
      <xsl:call-template name="make-observation">
         <xsl:with-param name="test"
            select="$context/@type = $comparabilityDisqualifiers/local-name(.)"/>
         <xsl:with-param name="itemAddress" select="$context/@item-address"/>
         <xsl:with-param name="itemContext" select="$context/@item-context"/>
         <xsl:with-param name="oi-c" select="$context/@oi"></xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   
   
</xsl:stylesheet>