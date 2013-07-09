<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:sxx="http://www.SoundExchange/ns/xslt/util" exclude-result-prefixes="#all"
   version="2.0">

   <!-- Generates intrinsic observations from canonicals
       - Accepts as input either an sx-container, or a discrete canonical.
       - If an sx-container, returns the container with intrinsic observations of its canonical(s) added.
       - If a canonical, generates just the observations.
   -->

   <xsl:import href="import/debug-support.xsl"/>
   
   <xsl:import href="import/make-observations.xsl"/>
   
   <xsl:strip-space elements="*"/>
   <!--<xsl:output indent="yes"/> -->
   
   <xsl:variable name="transformVersion" select="'0.1.0'"/>
   
   <xsl:variable name="transformDescription">
      <description>
         <xsl:text>Generates new (reflective) observations by refining intrinsic observations already made.</xsl:text>
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
         <sxx:here/>
      </xsl:variable>
      <xsl:copy>
         <!-- copying, then applying templates to particular observation elements -->
         <xsl:apply-templates/>
         <!-- then performing tests -->
         <xsl:apply-templates select="$tests">
            <xsl:with-param name="context" tunnel="yes" select="."/>
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
   
   
   <xsl:template match="observation">
      <xsl:copy-of select="."/>
   </xsl:template>
   
   <xsl:template match="observation[matches(@type,'intrinsic\.')]">
      <xsl:copy-of select="."/>
      <xsl:variable name="tests" as="element()*">
         <sxx:reflective-observe-unrefined.field.unrefined-intrinsic-observation/>
      </xsl:variable>
      <xsl:apply-templates select="$tests">
         <xsl:with-param name="context" select="." tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>
   
   <xsl:template match="sxx:reflective-observe-unrefined.field.unrefined-intrinsic-observation">
      <xsl:param name="context" required="yes" tunnel="yes"/>
      <xsl:variable name="oi" select="$context/@oi"/>
      <xsl:call-template name="make-observation">
         <!-- This (intrinsic) observation's @oi appears among no sibling observation's @oi-c values -->
         <xsl:with-param name="test"
            select="not($oi = ../observation/@oi-c/tokenize(.,'\s+'))"/>
         <xsl:with-param name="itemAddress" select="$context/@item-address"/>
         <xsl:with-param name="itemContext" select="$context/@item-context"/>
         <xsl:with-param name="oi-c" select="$context/@oi"></xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   
   
   
</xsl:stylesheet>
