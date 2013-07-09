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
   
   <!--<xsl:template match="/sx-container" priority="5">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:copy-of select="sx-manifest"/>
         <observations>
            <!-\- copying through any observations that happen already to be present -\->
            <xsl:copy-of select="observations/*"/>
            <!-\- generating ref observations by applying templates to canonical -\->
            <xsl:apply-templates select="observations"/>
         </observations>
         <xsl:copy-of select="canonical, provider-message"/>
         <xsl:apply-templates select="." mode="debug"/>
      </xsl:copy>
   </xsl:template>-->

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
         <sxx:reflective-refinement.canonical.no-intrinsic-observations/>
         <sxx:reflective-refinement.canonical.no-comparison-performed/>
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
   
   
   <!--  TODO: 
      - Need to either generate an observation that states:
         no intrinsic observations OR no intrinsic.observations processed
   -->

   
   
   <!--
      Observations registering latent observations
      <sxx:intrinsic.field.missing-value/>
      <sxx:intrinsic.field.compounded-value/>
      <sxx:intrinsic.field.value-translation-failed/>
      <sxx:intrinsic.field.value-not-mapped/> -->

   <!-- These matches should be mutually exclusive to avoid duplication of observations -->
   
   <xsl:template match="observation">
      <xsl:copy-of select="."/>
   </xsl:template>
   
   <xsl:template match="observation[@type = ('intrinsic.field.missing-value','intrinsic.field.value-not-mapped')]">
      <xsl:copy-of select="."/>
      <xsl:variable name="tests" as="element()*">
         <!--<sxx:reflective-refinement.field.critical-value-missing/>-->
         <sxx:reflective-refinement.release-upc.value-missing/>
         <sxx:reflective-refinement.release-title.value-missing/>
         <sxx:reflective-refinement.release-artists.value-missing/>
         <sxx:reflective-refinement.release-label.value-missing/>
         <sxx:reflective-refinement.recording-isrc.value-missing/>
         <sxx:reflective-refinement.recording-title.value-missing/>
         <sxx:reflective-refinement.recording-artists.value-missing/>
      </xsl:variable>
      <xsl:apply-templates select="$tests">
         <xsl:with-param name="context" select="." tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>
   
   <xsl:template match="observation[@type='comparative.field.value-changed']">
      <xsl:copy-of select="."/>
      <xsl:variable name="tests" as="element()*">
         <sxx:reflective-refinement.release-upc.value-changed/>
         <sxx:reflective-refinement.release-title.value-changed/>
         <sxx:reflective-refinement.release-artists.value-changed/>
         <sxx:reflective-refinement.release-label.value-changed/>
         <sxx:reflective-refinement.recording-title.value-changed/>
         <sxx:reflective-refinement.recording-artists.value-changed/>
         
         <sxx:reflective-refinement.field.value-extended/>
         <sxx:reflective-refinement.field.value-truncated/>
         <sxx:reflective-refinement.recording-duration.changed-by-15/>
      </xsl:variable>
      <xsl:apply-templates select="$tests">
         <xsl:with-param name="context" select="." tunnel="yes"/>
      </xsl:apply-templates>
   </xsl:template>
   
   
   <!-- 
     *****  Step #3 - Execute Observations  *****
     Implemented in templates matching elements in namespace sxx (each one indicating a test); $field represents the element being tested.
   -->


   <!-- 
     *****  Step #2 - Choreograph Observations  *****
     Implemented in templates matching elements in namespace sxx (each one indicating a test); $field represents the element being tested.
   -->


   <!-- 
     *****  Step #1 - Define Observations  *****
     Implemented in templates matching elements in namespace sxx (each one indicating a test); $context represents the element being tested.
   -->

   <!-- Call make-observation with this signature:
      
      <xsl:param name="context" tunnel="yes" select="."/>       The node being tested
      <xsl:param name="observationType" select="local-name()"/> The type of the observation (name of the observation element)
      <xsl:param name="contextLevels" select="2"/>              How many levels up to report canonical-context
      <xsl:param name="test" select="true()"/>                  The test to perform
      <xsl:param name="content" select="()"/>                   The contents of the 'observation' element emitted

      $content should be zero or more of the following elements:
         content-provided          - contents of the element under observation
         observation-detail[@type] - any other information (with its @type indicated)
       
      OR call make-reflective-observation, which calls make-observation, passing $content as follows:
      
      <xsl:with-param name="content">
         <content-provided>
            <xsl:value-of select="$context"/>
         </content-provided>
      </xsl:with-param>

   -->
   
   <xsl:template match="sxx:reflective-refinement.canonical.no-intrinsic-observations">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="test" select="empty($context/observation[starts-with(@type,'intrinsic.')])"/>
         <xsl:with-param name="itemAddress" select="()"/>
         <xsl:with-param name="itemContext" select="()"/>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template match="sxx:reflective-refinement.canonical.no-comparison-performed">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="test" select="empty($context/observation[@type='comparative.canonical.observations-performed'])"/>
         <xsl:with-param name="itemAddress" select="()"/>
         <xsl:with-param name="itemContext" select="()"/>
      </xsl:call-template>
   </xsl:template>

   <!--<xsl:variable name="critical-fields" as="element()+">
      <c>release/upc</c>
      <c>release/title</c>
      <c>release/artists</c>
      <c>release/label</c>
      <c>recording/isrc</c>
      <c>recording/title</c>
      <c>recording/artists</c>
   </xsl:variable>-->

   <!--<xsl:template match="sxx:reflective-refinement.field.critical-value-missing">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="test"
            select="$context/@item-context = $critical-fields"/>
         <xsl:with-param name="itemAddress" select="$context/@item-address"/>
         <xsl:with-param name="itemContext" select="$context/@item-context"/>
         <xsl:with-param name="oi-c" select="string($context/@oi)"/>
      </xsl:call-template>
   </xsl:template>-->

   <xsl:template match="sxx:reflective-refinement.release-upc.value-missing |
      sxx:reflective-refinement.release-title.value-missing |
      sxx:reflective-refinement.release-artists.value-missing |
      sxx:reflective-refinement.release-label.value-missing |
      sxx:reflective-refinement.recording-isrc.value-missing |
      sxx:reflective-refinement.recording-title.value-missing |
      sxx:reflective-refinement.recording-artists.value-missing |
      sxx:reflective-refinement.recording-duration.value-missing |
      
      sxx:reflective-refinement.release-upc.value-changed |
      sxx:reflective-refinement.release-title.value-changed |
      sxx:reflective-refinement.release-artists.value-changed |
      sxx:reflective-refinement.release-label.value-changed |
      sxx:reflective-refinement.recording-title.value-changed |
      sxx:reflective-refinement.recording-artists.value-changed">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:variable name="implicated-item-context">
         <xsl:apply-templates select="." mode="map-context"/>
      </xsl:variable>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="test"
            select="$context/@item-context = $implicated-item-context"/>
         <xsl:with-param name="itemAddress" select="$context/@item-address"/>
         <xsl:with-param name="itemContext" select="$context/@item-context"/>
         <xsl:with-param name="oi-c" select="string($context/@oi)"/>
      </xsl:call-template>
   </xsl:template>
   
   
   <!--<xsl:template match="sxx:reflective-refinement.field.critical-value-changed">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="test"
            select="$context/@item-context = $critical-fields"/>
         <xsl:with-param name="itemAddress" select="$context/@item-address"/>
         <xsl:with-param name="itemContext" select="$context/@item-context"/>
         <xsl:with-param name="oi-c" select="string($context/@oi)"/>
      </xsl:call-template>
   </xsl:template>-->
   
   <xsl:template match="sxx:reflective-refinement.field.value-extended">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:variable name="providedValue"   select="$context/content-provided"/>
      <xsl:variable name="attestedValue" select="$context/content-attested"/>
      <xsl:variable name="lengthDifference" select="string-length($providedValue) - string-length($attestedValue)"/>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="test" select="$lengthDifference gt 0"/>
         <xsl:with-param name="itemAddress" select="$context/@item-address"/>
         <xsl:with-param name="itemContext" select="$context/@item-context"/>
         <xsl:with-param name="content">
            <observation-detail type="length-difference">
               <xsl:value-of select="$lengthDifference"/>
            </observation-detail>
         </xsl:with-param>
         <xsl:with-param name="oi-c" select="$context/@oi"/>
      </xsl:call-template>
   </xsl:template>
 
   <xsl:template match="sxx:reflective-refinement.field.value-truncated">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:variable name="providedValue"   select="$context/content-provided"/>
      <xsl:variable name="attestedValue" select="$context/content-attested"/>
      <xsl:variable name="lengthDifference" select="string-length($attestedValue) - string-length($providedValue)"/>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="test" select="$lengthDifference gt 0"/>
         <xsl:with-param name="itemAddress" select="$context/@item-address"/>
         <xsl:with-param name="itemContext" select="$context/@item-context"/>
         <xsl:with-param name="content">
            <observation-detail type="length-difference">
               <xsl:value-of select="$lengthDifference"/>
            </observation-detail>
         </xsl:with-param>
         <xsl:with-param name="oi-c" select="$context/@oi"/>
      </xsl:call-template>
   </xsl:template>
   
   
   <xsl:template match="sxx:reflective-refinement.recording-duration.changed-by-15">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:variable name="providedValue" select="$context/content-provided"/>
      <xsl:variable name="attestedValue" select="$context/content-attested"/>
      <xsl:variable name="timeDifference" select="abs(number($providedValue) - number($attestedValue))"/>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="test" select="$context/@item-context='recording/duration' and            
            $timeDifference >= 15"/>
         <xsl:with-param name="itemAddress" select="$context/@item-address"/>
         <xsl:with-param name="itemContext" select="$context/@item-context"/>
         <xsl:with-param name="content">
            <observation-detail type="time-difference">
               <xsl:value-of select="$timeDifference"/>
            </observation-detail>
         </xsl:with-param>
         <xsl:with-param name="oi-c" select="$context/@oi"/>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template mode="map-context" as="xs:string" match="sxx:reflective-refinement.release-upc.value-missing">
      <xsl:text>release/upc</xsl:text>
   </xsl:template>
   
   <xsl:template mode="map-context" as="xs:string" match="sxx:reflective-refinement.release-title.value-missing">
      <xsl:text>release/title</xsl:text>
   </xsl:template>
   
   <xsl:template mode="map-context" as="xs:string"
      match="sxx:reflective-refinement.release-artists.value-missing | sxx:reflective-refinement.release-artists.value-changed">
      <xsl:text>release/artists</xsl:text></xsl:template>
   
   <xsl:template mode="map-context" as="xs:string"
      match="sxx:reflective-refinement.release-label.value-missing | sxx:reflective-refinement.release-label.value-changed">
      <xsl:text>release/label</xsl:text></xsl:template>
   
   <xsl:template mode="map-context" as="xs:string"
      match="sxx:reflective-refinement.recording-isrc.value-missing | sxx:reflective-refinement.recording-isrc.value-changed">
      <xsl:text>recording/isrc</xsl:text></xsl:template>
   
   <xsl:template mode="map-context" as="xs:string"
      match="sxx:reflective-refinement.recording-title.value-missing | sxx:reflective-refinement.recording-title.value-changed">
      <xsl:text>recording/title</xsl:text></xsl:template>
   
   <xsl:template mode="map-context" as="xs:string"
      match="sxx:reflective-refinement.recording-artists.value-missing | sxx:reflective-refinement.recording-artists.value-changed">
      <xsl:text>recording/artists</xsl:text></xsl:template>
   
   <xsl:template mode="map-context" as="xs:string"
      match="sxx:reflective-refinement.recording-duration.value-missing">
      <xsl:text>recording/duration</xsl:text></xsl:template>
   
   
</xsl:stylesheet>
