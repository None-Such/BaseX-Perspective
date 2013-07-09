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
   <!--<xsl:output indent="yes"/>-->
   
   <xsl:variable name="transformVersion" select="'0.1.0'"/>
   
   <xsl:variable name="transformDescription">
      <description>
         <xsl:text>Generates intrinsic observations from inspecting release canonical in container.</xsl:text>
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
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:copy-of select="sx-manifest"/>
         <xsl:variable name="observations">
            <observations>
               <!-- copying through any observations that happen already to be present -->
               <xsl:copy-of select="observations/*"/>
               <!-- generating intrinsic observations by applying templates to canonical -->
               <xsl:apply-templates select="canonical"/>
            </observations>
         </xsl:variable>
         <xsl:apply-templates select="$observations" mode="renumber"/>            
         <xsl:copy-of select="* except (sx-manifest | observations)"/>
         <xsl:apply-templates select="." mode="debug"/>
      </xsl:copy>
   </xsl:template>

   <!--  TODO: 
      - Need to either generate an observation that states:
         no intrinsic observations OR no intrinsic.observations processed
   -->

   <xsl:template match="/canonical" priority="5">
      <observations>
         <xsl:next-match/>
      </observations>
   </xsl:template>

   <xsl:template match="canonical">
      <xsl:variable name="tests" as="element()*">
         <sxx:intrinsic.canonical.observations-performed/>
         <sxx:intrinsic.canonical.shares-container/>
         <sxx:intrinsic.canonical.missing-release/>
         <sxx:intrinsic.canonical.contains-multiple-releases/>
      </xsl:variable>
      <xsl:apply-templates select="$tests">
         <xsl:with-param name="context" select="." tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:next-match/>
   </xsl:template>

   <!-- 
     *****  Step #3 - Execute Observations  *****
     Implemented in templates matching elements in namespace sxx (each one indicating a test); $field represents the element being tested.
   -->

   <xsl:template priority="10" match="release/* | recording/*">
      <xsl:variable name="tests" as="element()*">
         <sxx:intrinsic.field.missing-value/>
         <sxx:intrinsic.field.compounded-value/>
         <sxx:intrinsic.field.value-translation-failed/>
         <sxx:intrinsic.field.value-not-mapped/>
      </xsl:variable>
      <xsl:apply-templates select="$tests">
         <xsl:with-param name="context" select="." tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:next-match/>
   </xsl:template>

   <xsl:template match="EXCEPTION">
      <xsl:variable name="tests" as="element()*">
         <sxx:intrinsic.generic.processing-exception/>
      </xsl:variable>
      <xsl:apply-templates select="$tests">
         <xsl:with-param name="context" select="." tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:next-match/>
   </xsl:template>

   <!-- 
     *****  Step #2 - Choreograph Observations  *****
     Implemented in templates matching elements in namespace sxx (each one indicating a test); $field represents the element being tested.
   -->

   <!--<xsl:template match="canonical/release">
      <xsl:variable name="tests" as="element()*"/>
      <xsl:apply-templates select="$tests">
         <xsl:with-param name="context" select="." tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:next-match/>
   </xsl:template>-->
   
   <xsl:template match="canonical/recording">
      <xsl:variable name="tests" as="element()*">
         <sxx:intrinsic.recording.repeats-isrc/>
      </xsl:variable>
      <xsl:apply-templates select="$tests">
         <xsl:with-param name="context" select="." tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:next-match/>
   </xsl:template>
   
   <!-- Will perform in Solr
   <xsl:template match="canonical//title">
      <xsl:variable name="tests" as="element()*">
         <sxx:intrinsic.field.all-upper-case/>
         <sxx:intrinsic.field.all-lower-case/>
         <sxx:intrinsic.field.contains-no-letters/>
         <sxx:intrinsic.field.contains-suspicious-punctuation/>
         <sxx:intrinsic.field.contains-diacritic/>
         <sxx:intrinsic.field.contains-other-nonenglish-character/>
      </xsl:variable>
      <xsl:apply-templates select="$tests">
         <xsl:with-param name="context" select="." tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:next-match/>
   </xsl:template>-->

   <!-- Will perform in Solr
   <xsl:template match="canonical//artists">
      <xsl:variable name="tests" as="element()*">
         <sxx:intrinsic.field.all-upper-case/>
         <sxx:intrinsic.field.all-lower-case/>
         <sxx:intrinsic.field.contains-no-letters/>
         <sxx:intrinsic.field.contains-suspicious-punctuation/>
         <sxx:intrinsic.field.contains-diacritic/>
         <sxx:intrinsic.field.contains-other-nonenglish-character/>
      </xsl:variable>
      <xsl:apply-templates select="$tests">
         <xsl:with-param name="context" select="." tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:next-match/>
   </xsl:template> -->
   
   <xsl:template match="isrc">
      <xsl:variable name="tests" as="element()*">
         <sxx:intrinsic.isrc.invalid-isrc/>
      </xsl:variable>
      <xsl:apply-templates select="$tests">
         <xsl:with-param name="context" select="." tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:next-match/>
   </xsl:template>
   
   <xsl:template match="duration">
      <xsl:variable name="tests" as="element()*">
         <sxx:intrinsic.field.not-numeric/>
      </xsl:variable>
      <xsl:apply-templates select="$tests">
         <xsl:with-param name="context" select="." tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:next-match/>
   </xsl:template>
   
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
       
      OR call make-intrinsic-observation, which calls make-observation, passing $content as follows:
      
      <xsl:with-param name="content">
         <content-provided>
            <xsl:value-of select="$context"/>
         </content-provided>
      </xsl:with-param>

   -->
   
   <xsl:template name="make-intrinsic-observation">
      <xsl:param name="context" tunnel="yes" select="."/>
      <xsl:param name="test" as="xs:boolean" required="yes"/>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="test" select="$test"/>
         <xsl:with-param name="observationType" select="local-name()"/>
         <xsl:with-param name="content">
            <content-provided>
               <xsl:value-of select="$context"/>
            </content-provided>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template match="sxx:intrinsic.canonical.observations-performed">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:call-template name="make-observation"/>
   </xsl:template>

   <xsl:template match="sxx:intrinsic.generic.processing-exception">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:call-template name="make-intrinsic-observation">
         <xsl:with-param name="test" select="exists($context/self::EXCEPTION)"/>
      </xsl:call-template>
   </xsl:template>

   <xsl:template match="sxx:intrinsic.canonical.shares-container">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="test" select="count($context/../canonical) ne 1"/>
      </xsl:call-template>
   </xsl:template>

   <xsl:template match="sxx:intrinsic.canonical.missing-release">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="test" select="empty($context/release)"/>
      </xsl:call-template>
   </xsl:template>

   <xsl:template match="sxx:intrinsic.canonical.contains-multiple-releases">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="test" select="count($context/release) gt 1"/>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template match="sxx:intrinsic.recording.repeats-isrc">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="test" select="$context/isrc = ($context/../recording except $context)/isrc"/>
      </xsl:call-template>
   </xsl:template>

   <!--
   @latent values (where $n is the item()* provided to populate a value):   
   <xsl:when test="count($n) gt 1">MULTIPLE-NODES-PROVIDED</xsl:when>
         <xsl:when test="empty($n)">NODE-NOT-PROVIDED-FOR-VALUE</xsl:when>
         <!- - there is one item - ->
   <xsl:when test="$n instance of xs:boolean and not($n)">DEBUG.VALUE-NOT-MAPPED</xsl:when>
   <xsl:when test="string($n)=''">VALUE-NOT-PROVIDED</xsl:when>
   <xsl:when test="replace(string($n),'\s','')=''">VALUE-WAS-WHITESPACE</xsl:when>
   <xsl:when test="empty($translation)">VALUE-FAILED-TRANSLATION</xsl:when>
   <xsl:otherwise/>-->
   
   <xsl:template match="sxx:intrinsic.field.missing-value">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:variable name="missingValueIndicators" as="element()+">
         <i>NODE-NOT-PROVIDED-FOR-VALUE</i>
         <i>VALUE-NOT-PROVIDED</i>
         <i>VALUE-WAS-WHITESPACE</i>
      </xsl:variable>
      <xsl:call-template name="make-intrinsic-observation">
         <xsl:with-param name="test" select="$context/@latent = $missingValueIndicators"/>
      </xsl:call-template>
   </xsl:template>

   <xsl:template match="sxx:intrinsic.field.compounded-value">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:variable name="multipleValueIndicators" as="element()">
         <i>MULTIPLE-NODES-PROVIDED</i>
      </xsl:variable>
      <xsl:call-template name="make-intrinsic-observation">
         <xsl:with-param name="test" select="$context/@latent = $multipleValueIndicators"/>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template match="sxx:intrinsic.field.value-translation-failed">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:variable name="translationFailureIndicators" as="element()">
         <i>VALUE-FAILED-TRANSLATION</i>
      </xsl:variable>
      <xsl:call-template name="make-intrinsic-observation">
         <xsl:with-param name="test" select="$context/@latent = $translationFailureIndicators"/>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template match="sxx:intrinsic.field.value-not-mapped">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:variable name="notMappedIndicators" as="element()">
         <i>DEBUG.VALUE-NOT-MAPPED</i>
      </xsl:variable>
      <xsl:call-template name="make-intrinsic-observation">
         <xsl:with-param name="test" select="$context/@latent = $notMappedIndicators"/>
      </xsl:call-template>
   </xsl:template>
   
   
   <!--<xsl:template match="sxx:intrinsic.field.all-upper-case">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:call-template name="make-intrinsic-observation">
         <!-\- omits non-letters, then tests to see if all are upper-case -\->
         <xsl:with-param name="test" select="matches(replace($context,'\P{L}',''), '^\p{Lu}*$') and not(sxx:exception($context,.))"/>
      </xsl:call-template>
   </xsl:template>-->

   <!--<xsl:template match="sxx:intrinsic.field.all-lower-case">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:call-template name="make-intrinsic-observation">
         <!-\- omits non-letters, then tests to see if all are lower-case -\->
         <xsl:with-param name="test" select="matches(replace($context,'\P{L}',''), '^\p{Ll}*$') and not(sxx:exception($context,.))"/>
      </xsl:call-template>
   </xsl:template>-->

   <!--<xsl:template match="sxx:intrinsic.field.contains-no-letters">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:call-template name="make-intrinsic-observation">
         <xsl:with-param name="test" select="matches($context, '^[^a-zA-Z]+$') and not(sxx:exception($context,.))"/>
      </xsl:call-template>
   </xsl:template>-->

   <!-- TODO: Need write translation (as part of generate-canonical.xsl) to translate brackets and curly brackets to parenthesis -->

   <!-- TODO: Need to check for unbalanced parenthesis (only has opening or closing) -->

   <!--<xsl:template match="sxx:intrinsic.field.contains-suspicious-punctuation">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:call-template name="make-intrinsic-observation">
         <xsl:with-param name="test"
            select="matches($context, '[&#x0023;-&#x0025;&#x002A;-&#x002B;&#x003C;-&#x003E;&#x0040;&#x005E;-&#x0060;&#x007C;&#x007E;&#x00A1;-&#x00BF;&#x00D7;&#x00F7;]') and not(sxx:exception($context,.))"
         />
      </xsl:call-template>
   </xsl:template>-->

   <!--<xsl:template match="sxx:intrinsic.field.contains-diacritic">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:call-template name="make-intrinsic-observation">
         <xsl:with-param name="test" select="matches($context, '[&#x00C0;-&#x00D6;&#x00D8;-&#x00F6;&#x00F8;-&#x00FF;]')"/>
      </xsl:call-template>
   </xsl:template>-->

   <!--<xsl:template match="sxx:intrinsic.field.contains-other-nonenglish-character">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:call-template name="make-intrinsic-observation">
         <xsl:with-param name="test" select="matches($context, '[&#x0250;-&#x09FB;]')"/>
      </xsl:call-template>
   </xsl:template>-->

   <xsl:template match="sxx:intrinsic.field.not-numeric">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:call-template name="make-intrinsic-observation">
         <xsl:with-param name="test" select="not($context castable as xs:decimal)"/>
      </xsl:call-template>
   </xsl:template>
   
   
   <!-- Valid ISRC is CCXXXYYNNNNN where
        CC is country code (letters)
        XXX is registrant (3 letters or numerals)
        YY is 2-digit year (numerals)
        NNNNN is 5 numerals

        TODO: Check CC against a gazetteer instead of accepting any [A-Z]{2} -->
   <xsl:template match="sxx:intrinsic.isrc.invalid-isrc">
      <xsl:param name="context" tunnel="yes" required="yes"/>
      <xsl:variable name="isrc-regex">'^[A-Z]{2}\w{3}\d{7}$'</xsl:variable>
      <xsl:call-template name="make-intrinsic-observation">
         <xsl:with-param name="test" select="not(matches($context,$isrc-regex))"/>
      </xsl:call-template>
   </xsl:template>
   
   
   <!--<!-\- Permits an element that fails a test to pass it instead, in particular cases. -\->
   <xsl:function name="sxx:exception" as="xs:boolean">
      <xsl:param name="context" as="element()"/>
      <xsl:param name="testVisited" as="element()"/>
      <xsl:apply-templates select="$context" mode="sxx:exception">
         <xsl:with-param name="test" select="$testVisited"/>
      </xsl:apply-templates>
   </xsl:function>

   <xsl:template match="title" mode="sxx:exception" as="xs:boolean">
      <!-\- Not presently allowing any titles -\->
      <xsl:sequence select="false()"/>
   </xsl:template>

   <xsl:template match="artists" mode="sxx:exception" as="xs:boolean">
      <!-\- Not presently allowing any artists -\->
      <xsl:sequence select="false()"/>
   </xsl:template>-->

</xsl:stylesheet>
