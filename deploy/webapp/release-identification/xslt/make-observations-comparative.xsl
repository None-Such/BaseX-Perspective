<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:sxx="http://www.SoundExchange/ns/xslt/util" exclude-result-prefixes="#all" version="2.0">

   <xsl:import href="import/debug-support.xsl"/>

   <xsl:import href="import/make-observations.xsl"/>

   <xsl:strip-space elements="*"/>
   <!--<xsl:output indent="yes"/> -->

   <xsl:variable name="transformVersion" select="'0.1.0'"/>

   <xsl:variable name="transformDescription">
      <description>
         <xsl:text>Generates observations comparing a canonical provided with a canonical attested.</xsl:text>
      </description>
   </xsl:variable>

   <xsl:param name="debug" select="'false'"/>

   <xsl:variable name="transformParameters" as="element()*">
      <param name="debug">
         <xsl:value-of select="$debug"/>
      </param>
   </xsl:variable>

   <xsl:variable name="xsltFilename" select="replace(document-uri(document('')),'.*/','')"/>

   <xsl:variable name="debugging" select="$debug = 'true'"/>

   <!--
   
Compares a pair of containers

Assumptions:
   containers are siblings inside the document element
   each container contains a single canonical, valid to canonical.rnc
   canonicals contain no mixed content, and are structurally isomorphic and regular
   (no element types are repeated within their parents)
   
   -->

   <!-- suppressing all output in the default traversal -->
   <xsl:template match="text() | @*" mode="#default test-attested"/>

   <!-- but we are examining attributes -->
   <xsl:template match="*/*" priority="-0.5" mode="#default test-attested">
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="#current"/>
   </xsl:template>

   <xsl:template match="/*">
      <xsl:for-each select="sx-container[@purpose='repertoire-provided'][1]">
         <xsl:variable name="observations">
            <observations>
               <xsl:copy-of select="observations/*"/>
               <xsl:call-template name="generate-comparative-observations"/>
            </observations>
         </xsl:variable>
         <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="sx-manifest"/>
            <xsl:apply-templates select="$observations" mode="renumber"/>            
            <xsl:copy-of select="* except (sx-manifest | observations)"/>
            <xsl:apply-templates select="." mode="debug"/>
         </xsl:copy>
      </xsl:for-each>
      <xsl:if test="empty(sx-container[@purpose='repertoire-provided'])">
         <EXCEPTION>EXCEPTION - no sx-container[@purpose='repertoire-provided'] was given to compare -
            generate-observations-comparative.xsl</EXCEPTION>
      </xsl:if>
   </xsl:template>

   <xsl:template name="generate-comparative-observations">
      <xsl:if test="$debugging">
         <xsl:attribute name="transform-version" select="$transformVersion"/>
      </xsl:if>
      <xsl:variable name="provided" select="/*/sx-container[@purpose='repertoire-provided']/canonical"/>
      <xsl:variable name="attested" select="/*/sx-container[@purpose='repertoire-attested']/canonical"/>
      <xsl:choose>
         <xsl:when test="count($provided) eq 1 and count($attested) eq 1">
            <xsl:call-template name="compare-canonicals">
               <xsl:with-param name="providedCanonical" select="/*/sx-container[@purpose='repertoire-provided']/canonical[1]"/>
               <xsl:with-param name="attestedCanonical" select="/*/sx-container[@purpose='repertoire-attested']/canonical[1]"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <EXCEPTION>
               <xsl:text>EXCEPTION - No comparison was performed between sx-container elements - a pair with </xsl:text>
               <xsl:text>@purpose='repertoire-provided','repertoire-attested' is expected, while </xsl:text>
               <xsl:value-of select="string-join(/*/sx-canonical/@purpose/concat('''',.,''''),',')"/>
               <xsl:text>was given - generate-observations-comparative.xsl</xsl:text>
            </EXCEPTION>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <xsl:template name="compare-canonicals">
      <xsl:param name="providedCanonical" as="element(canonical)" required="yes"/>
      <xsl:param name="attestedCanonical" as="element(canonical)" required="yes"/>
      <xsl:variable name="canonicalsComparable" select="sxx:canonical-comparable($providedCanonical) and sxx:canonical-comparable($attestedCanonical)"/>
      <xsl:variable name="tests" as="element()*">
         <sxx:comparative.canonical.observations-performed/>
         <sxx:comparative.canonical.observations-failed/>
         <sxx:comparative.canonical.observed-identical/>
      </xsl:variable>
      <xsl:apply-templates select="$tests">
         <xsl:with-param name="providedCanonical" select="$providedCanonical"/>
         <xsl:with-param name="attestedCanonical" select="$attestedCanonical"/>
         <xsl:with-param name="canonicalsComparable" select="$canonicalsComparable"/>
      </xsl:apply-templates>
      <xsl:if test="$canonicalsComparable">
         <xsl:apply-templates select="$providedCanonical" mode="gateway">
            <xsl:with-param name="attestedCanonical" tunnel="yes" select="$attestedCanonical"/>
         </xsl:apply-templates>
         <xsl:apply-templates select="$attestedCanonical" mode="test-attested">
            <xsl:with-param name="providedCanonical" tunnel="yes" select="$providedCanonical"/>
         </xsl:apply-templates>
      </xsl:if>
   </xsl:template>
   
   <xsl:template match="provider-manifest" mode="gateway"/>
   
   <!-- This is the 'gateway' comparison: if it generates observations no other tests will be performed. -->
   <xsl:template match="release | recording" mode="gateway">
      <xsl:param name="attestedCanonical" required="yes" tunnel="yes" as="element()"/>
      <xsl:variable name="attestedComponent"
         select="self::release/$attestedCanonical/release[upc = current()/upc] |
                 self::recording/$attestedCanonical/recording[isrc = current()/isrc]"/>
      <xsl:variable name="tests" as="element()*">
         <sxx:comparative.component.missing-comparable/>
         <sxx:comparative.component.repeated-comparable/>
      </xsl:variable>
      <xsl:variable name="observed-anomalies" as="element()*">
         <xsl:apply-templates select="$tests">
            <xsl:with-param name="component" select="."/>
            <xsl:with-param name="comparable" select="$attestedComponent"/>
         </xsl:apply-templates>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="exists($observed-anomalies)">
            <xsl:copy-of select="$observed-anomalies"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select=".">
               <xsl:with-param name="providedComponent" tunnel="yes" select="."/>
               <xsl:with-param name="attestedComponent" tunnel="yes" select="$attestedComponent"/>
            </xsl:apply-templates>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <xsl:template match="recording | release" mode="test-attested">
      <xsl:param name="providedCanonical" tunnel="yes" as="element()"/>
      <xsl:variable name="providedComponent"
         select="self::release/$providedCanonical/release[upc = current()/upc] |
                 self::recording/$providedCanonical/recording[isrc = current()/isrc]"/>
      <xsl:variable name="tests" as="element()*">
         <sxx:comparative.component.missing-comparable/>
         <sxx:comparative.component.repeated-comparable/>
      </xsl:variable>
      <xsl:apply-templates select="$tests">
         <xsl:with-param name="component" select="."/>
         <xsl:with-param name="comparable" select="$providedComponent"/>
      </xsl:apply-templates>
   </xsl:template>

   <xsl:template match="release/*[not(self::EXCEPTION)] |
                        recording/*[not(self::EXCEPTION)]">
      <xsl:param name="attestedComponent" tunnel="yes" as="element()"/>
      <xsl:variable name="tests" as="element()*">
         <sxx:comparative.field.value-changed/>
      </xsl:variable>
      <xsl:apply-templates select="$tests">
         <xsl:with-param name="providedField" select="."/>
         <xsl:with-param name="attestedField" select="$attestedComponent/*[name() = name(current())]"/>
      </xsl:apply-templates>
      <xsl:next-match/>
   </xsl:template>

   <!-- Here begynneth the observation implementations -->

   <xsl:template match="sxx:comparative.canonical.observations-performed">
      <xsl:param name="providedCanonical" as="element(canonical)" required="yes"/>
      <xsl:param name="attestedCanonical" as="element(canonical)" required="yes"/>
      <xsl:param name="canonicalsComparable" as="xs:boolean" required="yes"/>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="context" tunnel="yes" select="$providedCanonical"/>
         <xsl:with-param name="test" select="$canonicalsComparable"/>
         <xsl:with-param name="content">
            <observation-detail type="attested-canonical-compared-to">
               <xsl:value-of select="sxx:xpath($attestedCanonical)"/>
            </observation-detail>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template match="sxx:comparative.canonical.observations-failed">
      <xsl:param name="providedCanonical" as="element(canonical)" required="yes"/>
      <xsl:param name="attestedCanonical" as="element(canonical)" required="yes"/>
      <xsl:param name="canonicalsComparable" as="xs:boolean" required="yes"/>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="context" tunnel="yes" select="$providedCanonical"/>
         <xsl:with-param name="test" select="not($canonicalsComparable)"></xsl:with-param>
         <xsl:with-param name="content">
            <xsl:if test="not(sxx:canonical-comparable($providedCanonical))">
               <observation-detail type="rationale">Provided canonical not comparable</observation-detail>
            </xsl:if>
            <xsl:if test="not(sxx:canonical-comparable($attestedCanonical))">
               <observation-detail type="rationale">
                  <xsl:text>Attested canonical </xsl:text>
                  <xsl:value-of select="sxx:xpath($attestedCanonical)"/>
                  <xsl:text> not comparable</xsl:text>
               </observation-detail>
            </xsl:if>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template match="sxx:comparative.canonical.observed-identical">
      <xsl:param name="providedCanonical" as="element(canonical)" required="yes"/>
      <xsl:param name="attestedCanonical" as="element(canonical)" required="yes"/>
      <xsl:variable name="cleanProvided">
         <xsl:apply-templates select="$providedCanonical" mode="clean"/>
      </xsl:variable>
      <xsl:variable name="cleanAttested">
         <xsl:apply-templates select="$attestedCanonical" mode="clean"/>
      </xsl:variable>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="context" tunnel="yes" select="$providedCanonical"/>
         <xsl:with-param name="test" select="deep-equal($cleanProvided,$cleanAttested)"/>
      </xsl:call-template>
   </xsl:template>

   <xsl:template match="sxx:comparative.component.missing-comparable">
      <xsl:param name="component" required="yes"/>
      <xsl:param name="comparable" required="yes"/>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="context" tunnel="yes" select="$component"/>
         <xsl:with-param name="test" select="empty($comparable)"/>
      </xsl:call-template>
   </xsl:template>

   <xsl:template match="sxx:comparative.component.repeated-comparable">
      <xsl:param name="component" required="yes"/>
      <xsl:param name="comparable" required="yes"/>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="context" tunnel="yes" select="$component"/>
         <xsl:with-param name="test" select="count($comparable) gt 1"/>
      </xsl:call-template>
   </xsl:template>
   
   <xsl:template match="sxx:comparative.field.value-changed">
      <xsl:param name="providedField" required="yes" as="element()"/>
      <xsl:param name="attestedField" required="yes" as="element()"/>
      <xsl:call-template name="make-observation">
         <xsl:with-param name="context" tunnel="yes" select="$providedField"/>
         <xsl:with-param name="test" select="not($providedField eq $attestedField)"/>
         <xsl:with-param name="content">
            <content-provided>
               <xsl:value-of select="$providedField"/>
            </content-provided>
            <content-attested>
               <xsl:value-of select="$attestedField"/>
            </content-attested>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>

   
   <!-- A canonical is considered comparable if has been not been flagged as not comparable. -->
   <xsl:function name="sxx:canonical-comparable">
      <xsl:param name="canonical" as="element(canonical)"/>
      <xsl:sequence select="not($canonical/../observations/observation/@type = 'reflective-comparability.canonical.is-not-comparable')"/>
   </xsl:function>
   


   <!-- Overriding the template from xpath-write.xsl for this application. -->
   <xsl:template match="/*" mode="sxx:xpath-step"/>

   <xsl:template match="sx-container[@purpose='repertoire-attested']" mode="sxx:xpath-step">
      <xsl:text>/sx-container[sx-manifest/location-received='</xsl:text>
      <xsl:value-of select="sx-manifest/location-received"/>
      <xsl:text>']</xsl:text>
   </xsl:template>

   <xsl:template match="sx-container[@purpose='repertoire-provided']" mode="sxx:xpath-step">
      <xsl:text>/sx-container</xsl:text>
   </xsl:template>

   <!-- Mode "clean" removes insignificant text nodes defensively along with
        any elements expected to be different between different canonicals even
        representing the same release. -->
   <xsl:template mode="clean" match="provider-manifest"/>

   <xsl:template mode="clean" match="canonical/text() | release/text() | recording/text()"/>

   <xsl:template mode="clean" match="node() | @*">
      <xsl:copy>
         <xsl:apply-templates mode="clean" select="node() | @*"/>
      </xsl:copy>
   </xsl:template>

</xsl:stylesheet>
