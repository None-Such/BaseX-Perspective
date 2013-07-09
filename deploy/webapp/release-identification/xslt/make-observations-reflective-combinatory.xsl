<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:sxx="http://www.SoundExchange/ns/xslt/util" exclude-result-prefixes="#all"
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
         <xsl:text>Generates intrinsic observations from inspecting canonical message in container.</xsl:text>
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
         <sxx:reflective-combinatory.release.multiple-critical-values-missing/>
         <sxx:reflective-combinatory.release.multiple-critical-values-changed/>
         <sxx:reflective-combinatory.recording.multiple-critical-values-missing/>
         <sxx:reflective-combinatory.recording.multiple-critical-values-changed/>
      </xsl:variable>
      <xsl:copy>
         <xsl:apply-templates/>
         <xsl:apply-templates select="$tests">
            <xsl:with-param name="context" tunnel="yes" select="."/>
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
   
   <!--  TODO: 
      - Need to either generate an observation that states:
         no intrinsic observations OR no intrinsic.observations processed
   -->
  
   <xsl:template match="observation">
      <xsl:copy-of select="."/>
   </xsl:template>
   
   <xsl:template match="sxx:reflective-combinatory.release.multiple-critical-values-missing |
      sxx:reflective-combinatory.release.multiple-critical-values-changed |
      sxx:reflective-combinatory.recording.multiple-critical-values-missing |
      sxx:reflective-combinatory.recording.multiple-critical-values-changed">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <!-- Context is the observations element -->
      <xsl:variable name="observationType" select="local-name()"/>
      <xsl:variable name="relevantObservations" as="element()*">
         <xsl:apply-templates select="." mode="relevant-combination"/>  
      </xsl:variable>
      <xsl:for-each-group select="$context/observation[@type=$relevantObservations/local-name()]"
         group-by="sxx:observed-field-parent(.)">
         <xsl:variable name="observedFieldParentName" select="replace(current-grouping-key(),'^(release|recording).+$','$1')"/>
         <xsl:call-template name="make-observation">
            <xsl:with-param name="test" select="count(current-group()) gt 1"/>
            <xsl:with-param name="observationType" select="$observationType"/>
            <xsl:with-param name="itemAddress" select="string-join(('/sx-container/canonical',current-grouping-key()),'/')"/>
            <xsl:with-param name="itemContext" select="string-join(('canonical',$observedFieldParentName),'/')"/>
            <xsl:with-param name="oi-c" select="current-group()/@oi/string()"/>
            <xsl:with-param name="content">
               <xsl:for-each select="current-group()">
                  <observation-detail type="implicated-context">
                     <xsl:value-of select="@item-context"/>
                  </observation-detail>
               </xsl:for-each>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:for-each-group>
   </xsl:template>
   
   
   <xsl:function name="sxx:observed-field-parent" as="xs:string?">
      <!-- returns the element name of the parent of the context of an observation -->
      <xsl:param name="o" as="element(observation)"/>
      <xsl:sequence select="tokenize($o/@item-address,'/')[last() - 1]"/>
   </xsl:function>
   
   <xsl:template mode="relevant-combination" match="sxx:reflective-combinatory.release.multiple-critical-values-missing">
      <sxx:reflective-refinement.release-upc.value-missing/>
      <sxx:reflective-refinement.release-title.value-missing/>
      <sxx:reflective-refinement.release-artists.value-missing/>
      <sxx:reflective-refinement.release-label.value-missing/>
   </xsl:template>
   
   <xsl:template mode="relevant-combination" match="sxx:reflective-combinatory.release.multiple-critical-values-changed">
      <sxx:reflective-refinement.release-upc.value-changed/>
      <sxx:reflective-refinement.release-title.value-changed/>
      <sxx:reflective-refinement.release-artists.value-changed/>
      <sxx:reflective-refinement.release-label.value-changed/>
   </xsl:template>
   
   <xsl:template mode="relevant-combination" match="sxx:reflective-combinatory.recording.multiple-critical-values-missing">
      <sxx:reflective-refinement.recording-isrc.value-missing/>
      <sxx:reflective-refinement.recording-title.value-missing/>
      <sxx:reflective-refinement.recording-artists.value-missing/>
   </xsl:template>
   
   <xsl:template mode="relevant-combination" match="sxx:reflective-combinatory.recording.multiple-critical-values-changed">
      <sxx:reflective-refinement.recording-isrc.value-changed/>
      <sxx:reflective-refinement.recording-title.value-changed/>
      <sxx:reflective-refinement.recording-artists.value-changed/>
      <sxx:reflective-refinement.recording-duration.changed-by-15/>
   </xsl:template>
   
</xsl:stylesheet>
