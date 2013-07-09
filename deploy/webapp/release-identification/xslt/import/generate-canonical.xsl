<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:sxx="http://www.SoundExchange/ns/xslt/util" exclude-result-prefixes="#all"
   version="2.0">

   <!-- Purpose: accepts a SoundExchange Repertoire message and generates a canonical version of it (reduced to a definitively comparable element set). -->
   <!-- NOTE: This transformation generates XML results in *no namespace*. Foreign namespaces are not welcome, since we expect to process in a namespace unaware environment. -->

   <xsl:import href="provide-xpath.xsl"/>
   <xsl:import href="debug-support.xsl"/>
   
   <xsl:output indent="yes"/>
 
   <xsl:variable name="transformVersion" select="'0.1.0'"/>
   
   <xsl:variable name="transformDescription">
      <description>
         <xsl:text>Maps provider messages into canonical format. (Each provider is mapped in an included module.)</xsl:text>
      </description>
   </xsl:variable>
   
   <xsl:param name="debug" select="'false'"/>
   <xsl:param name="showProvenance" select="'true'"/>
   <xsl:param name="provider" select="if (exists(/sx-container)) then /sx-container/sx-manifest/provider else '[PROVIDER-NOT-GIVEN]'"/>
   
   <xsl:variable name="transformParameters" as="element()*">
      <param name="debug"><xsl:value-of select="$debug"/></param>
      <param name="showProvenance"><xsl:value-of select="$showProvenance"/></param>
      <param name="provider"><xsl:value-of select="$provider"/></param>
   </xsl:variable>
   
   <xsl:variable name="xsltFilename" select="replace(document-uri(document('')),'.*/','')"/>
   
   <xsl:variable name="debugging" select="$debug = 'true'"/>

   <!-- KEY DECLARATION for linking DDEX recordings from their releases  -->
   <xsl:key name="DDEX-Recording-by-ResourceNumber" match="SoundRecording" use="ResourceReference"/>
   
   <!-- ======================================================================================= -->

   <!-- Included modules declare specific mappings. -->

   <!-- Releases passed in through the Excel pathway are mapped in module map-excel-to-canonical.xsl -->
   <xsl:include href="map-excel-xml-to-canonical.xsl"/>
   
   <!-- Finetunes releases are mapped in module map-finetunes-to-canonical.xsl -->
   <xsl:include href="map-finetunes-to-canonical.xsl"/>
   
   <!-- Ingrooves message, release and recording elements are in module map-ingrooves-to-canonical.xsl.  -->
   <xsl:include href="map-ingrooves-to-canonical.xsl"/>
   
   <!-- Orchard message, release and recording elements are in module map-orchard-to-canonical.xsl.  -->
   <xsl:include href="map-orchard-to-canonical.xsl"/>
   
   <!-- Sony "virtual releases" are mapped in module map-sony-to-canonical.xsl -->
   <xsl:include href="map-sony-to-canonical.xsl"/>
   
   <!-- Universal release and recording elements are in module map-universal-to-canonical.xsl.
        (Univeral messages map directly to releases.) -->
   <xsl:include href="map-universal-to-canonical.xsl"/>
   
   <!-- Warner message, release and recording elements are in module map-warner-to-canonical.xsl.  -->
   <xsl:include href="map-warner-to-canonical.xsl"/>
   
   <!-- ======================================================================================= -->

   <!-- Parameters in the main 'generate-canonical' and 'generate-recording' templates are declared as *required* to expose incomplete mappings as runtime errors.         
        Ordinarily a parameter will be bound to a node (singleton node sequence), namely the location in the source message where the value is to be found.
        More than one node may also be bound; in the result, their values will be concatenated with delimiters along with a latent observation of multiple values mapped.
        Parameters may also be provided as strings (when the mapping should be a fixed, literal value).
        Mappings to boolean false() will result in a latent observation of no mapping.
        Other atomic types are rendered as strings.
     -->
   
   <!-- #1 ** MAPPING CHOREOGRAPHY ** -->

   <xsl:template name="generate-canonical">
      <xsl:param tunnel="yes" required="yes" name="messageID"/>
      <xsl:param tunnel="yes" required="yes" name="messageLanguage"/>
      <xsl:param tunnel="yes" required="yes" name="messageIntent"/>
      <xsl:param tunnel="yes" required="yes" name="releaseType"/>
      <xsl:param tunnel="yes" required="yes" name="releaseUPC"/>
      <xsl:param tunnel="yes" required="yes" name="releaseTitle"/>
      <xsl:param tunnel="yes" required="yes" name="releaseArtists"/>
      <xsl:param tunnel="yes" required="yes" name="releaseLabel"/>
      <xsl:param tunnel="yes" required="yes" name="releaseOriginalDate"/>
      <xsl:param tunnel="yes" required="yes" name="releaseGenre"/>

      <xsl:param name="recordings" select="()"/>
      
      <canonical content-type="repertoire-release" purpose="compare-definitively">

         <provider-manifest provider="{$provider}">
            <xsl:call-template name="emit">
               <xsl:with-param name="label">message-id</xsl:with-param>
               <xsl:with-param name="value" select="$messageID"/>
            </xsl:call-template>
            <xsl:call-template name="emit">
               <xsl:with-param name="label">message-language</xsl:with-param>
               <xsl:with-param name="value" select="$messageLanguage"/>
            </xsl:call-template>
            <xsl:call-template name="emit">
               <xsl:with-param name="label">message-intent</xsl:with-param>
               <xsl:with-param name="value" select="$messageIntent"/>
            </xsl:call-template>
         </provider-manifest>

         <release>
            <xsl:attribute name="type">
               <xsl:choose>
                  <xsl:when test="$releaseType instance of xs:boolean and not($releaseType)">debug.not-mapped</xsl:when>
                  <xsl:when test="$releaseType instance of xs:string">
                     <xsl:value-of select="lower-case($releaseType)"/>
                  </xsl:when>
                  <xsl:when test="$releaseType instance of node()">
                     <xsl:apply-templates select="$releaseType" mode="value"/>
                  </xsl:when>
                  <xsl:otherwise>debug.erroneous-mapping</xsl:otherwise>
               </xsl:choose>
            </xsl:attribute>
            <!-- TODO : define policy for when more than one release type is given -->
            <xsl:call-template name="emit">
               <xsl:with-param name="label">upc</xsl:with-param>
               <xsl:with-param name="value" select="$releaseUPC"/>
            </xsl:call-template>
            <xsl:call-template name="emit">
               <xsl:with-param name="label">title</xsl:with-param>
               <xsl:with-param name="value" select="$releaseTitle"/>
            </xsl:call-template>
            <xsl:call-template name="emit">
               <xsl:with-param name="label">artists</xsl:with-param>
               <xsl:with-param name="value" select="$releaseArtists"/>
            </xsl:call-template>
            <xsl:call-template name="emit">
               <xsl:with-param name="label">label</xsl:with-param>
               <xsl:with-param name="value" select="$releaseLabel"/>
            </xsl:call-template>
            <xsl:call-template name="emit">
               <xsl:with-param name="label">date-originated</xsl:with-param>
               <xsl:with-param name="value" select="$releaseOriginalDate"/>
            </xsl:call-template>
            <xsl:call-template name="emit">
               <xsl:with-param name="label">genre</xsl:with-param>
               <xsl:with-param name="value" select="$releaseGenre"/>
            </xsl:call-template>
         </release>

         <!--  Loops through recordings, using an included XSL  -->
         <xsl:for-each select="$recordings">
            <xsl:variable name="position" select="position()"/>
            <xsl:apply-templates select="." mode="recording">
               <!-- ASSUMED HANDLING OF IMPLICIT INFORMATION: In case $position and component cannot be bound from the data, we provide defaults based on position. -->
               <xsl:with-param tunnel="yes" name="recordingComponent" select="'1'"/>
               <xsl:with-param tunnel="yes" name="recordingPosition" select="$position"/>
            </xsl:apply-templates>
         </xsl:for-each>

      </canonical>
   </xsl:template>

   <!-- Main generate-recording utility template. -->
   
   <xsl:template name="generate-recording">
      <xsl:param tunnel="yes" required="yes" name="recordingISRC"/>
      <xsl:param tunnel="yes" required="yes" name="recordingTitle"/>
      <xsl:param tunnel="yes" required="yes" name="recordingArtists"/>
      <xsl:param tunnel="yes" required="yes" name="recordingLabel"/>
      <xsl:param tunnel="yes" required="yes" name="recordingComponent"/>
      <xsl:param tunnel="yes" required="yes" name="recordingPosition"/>
      <xsl:param tunnel="yes" required="yes" name="recordingDuration"/>
      <xsl:param tunnel="yes" required="yes" name="recordingGenre"/>

      <recording>
         <xsl:call-template name="emit">
            <xsl:with-param name="label">isrc</xsl:with-param>
            <xsl:with-param name="value" select="$recordingISRC"/>
         </xsl:call-template>
         <xsl:call-template name="emit">
            <xsl:with-param name="label">title</xsl:with-param>
            <xsl:with-param name="value" select="$recordingTitle"/>
         </xsl:call-template>
         <xsl:call-template name="emit">
            <xsl:with-param name="label">artists</xsl:with-param>
            <xsl:with-param name="value" select="$recordingArtists"/>
         </xsl:call-template>
         <xsl:call-template name="emit">
            <xsl:with-param name="label">label</xsl:with-param>
            <xsl:with-param name="value" select="$recordingLabel"/>
         </xsl:call-template>
         <xsl:call-template name="emit">
            <xsl:with-param name="label">component</xsl:with-param>
            <xsl:with-param name="value" select="$recordingComponent"/>
         </xsl:call-template>
         <xsl:call-template name="emit">
            <xsl:with-param name="label">position</xsl:with-param>
            <xsl:with-param name="value" select="$recordingPosition"/>
         </xsl:call-template>
         <xsl:call-template name="emit">
            <xsl:with-param name="label">duration</xsl:with-param>
            <xsl:with-param name="value" select="$recordingDuration"/>
         </xsl:call-template>
         <xsl:call-template name="emit">
            <xsl:with-param name="label">genre</xsl:with-param>
            <xsl:with-param name="value" select="$recordingGenre"/>
         </xsl:call-template>
      </recording>
   </xsl:template>

   <!-- ** MAP A FIELD ** -->

   <xsl:template name="emit">
      <xsl:param name="label" as="xs:string" required="yes"/>
      <xsl:param name="value" as="item()*" required="yes"/>

      <!-- We make a field even if we have no value for it. -->
      <xsl:element name="{$label}">
         <!-- switching context to a string returned by sxx:latent-check if there is one -->
         <xsl:for-each select="sxx:latent-issue($value)">
            <xsl:attribute name="latent" select="."/>
         </xsl:for-each>
         <xsl:choose>
            <!-- If the value is set to false(), we give nothing.
                 (A latent observation of "no mapping" is generated.) -->
            <xsl:when test="not($value) and $value instance of xs:boolean"/>
            
            <!-- Ordinarily, the value is given as a binding to a node (using XPath);
                 when several nodes are bound, we will compound (flatten) the value.
                 We also get a latent observation. -->
            <xsl:when test="$value instance of node()+">
               <xsl:if test="$showProvenance='true'">
                  <xsl:attribute name="provenance">
                     <xsl:for-each select="$value">
                        <xsl:if test="not(position() eq 1)"> | </xsl:if>
                        <xsl:apply-templates select="." mode="sxx:xpath"/>
                     </xsl:for-each>
                  </xsl:attribute>
               </xsl:if>
               <xsl:for-each select="$value">
                  <xsl:sort order="ascending"/>
                  <xsl:if test="not(position() eq 1)">
                     <!-- delimiting multiple values with diamond (U+2666) -->
                     <xsl:text> &#x2666; </xsl:text>
                  </xsl:if>
                  <!-- Go get the value -->
                  <xsl:apply-templates mode="value" select="."/>
               </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
               <!-- The value is provided as a string literal, or no
                    value is provided. -->
               <xsl:value-of select="$value"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>

   <!-- MODE 'value' provides a translated (normalized) value if one exists. -->
   
   <xsl:template mode="value" match="*">
      <xsl:variable name="translated-value" as="text()?">
         <xsl:apply-templates select="." mode="translate"/>
      </xsl:variable>
      <xsl:value-of select="normalize-space(if (exists($translated-value)) then $translated-value else string(.))"/>
   </xsl:template>

   <!-- ** TRANSLATIONS ** -->

   <!-- By default, anything matched in mode 'translate' returns its own string value as a string.
        
        To translate (normalize) anything, override this template with a template returning an EMPTY SEQUENCE when normalization fails.
        (This effect is detectable for a latent observation.)
        In the results, mode "value" will fall back to the untranslated value when a translation fails. -->
   <xsl:template match="*" mode="translate" as="text()?">
      <xsl:value-of select="."/>
   </xsl:template>
   
   <!-- ** TRANSLATIONS (DDEX specific) ** -->
   
   <xsl:template mode="translate" match="*:NewReleaseMessage//ReleaseType" as="text()?">
      <xsl:if test="string(.)">
        <xsl:value-of select="lower-case(.)"/>
      </xsl:if>
   </xsl:template>

   <xsl:template mode="translate" match="*:NewReleaseMessage//Duration" as="text()?">
      <!-- DDEX duration comes as xs:duration; we report seconds. -->
      <xsl:if test=". castable as xs:duration">
         <xsl:variable name="days" select="days-from-duration(xs:duration(.))"/>
         <xsl:variable name="hours" select="hours-from-duration(xs:duration(.))"/>
         <xsl:variable name="minutes" select="minutes-from-duration(xs:duration(.))"/>
         <xsl:variable name="seconds" select="seconds-from-duration(xs:duration(.))"/>
         <xsl:value-of select="($days * 86400) + ($hours * 3600) + ($minutes * 60) + $seconds"/>
      </xsl:if>
   </xsl:template>

   <!-- Converts HH:MM:SS duration into seconds. -->
   <xsl:template name="hhmmss-convert">
      <!-- Universal track_length is expected as HH:MM:SS -->
      <xsl:variable name="regex">^(\d+):(\d\d):(\d\d)$</xsl:variable>
      <xsl:if test="matches(.,$regex)">
         <xsl:analyze-string select="." regex="{$regex}">
            <xsl:matching-substring>
               <xsl:value-of select="(number(regex-group(1)) * 3600) + (number(regex-group(2)) * 60) + number(regex-group(3))"/>
            </xsl:matching-substring>
         </xsl:analyze-string>
      </xsl:if>
   </xsl:template>
   
   <!-- Converts M+:SS duration into seconds. -->
   <xsl:template name="mmmss-convert">
      <xsl:variable name="regex">^(\d+):(\d\d)$</xsl:variable>
      <xsl:if test="matches(.,$regex)">
         <xsl:analyze-string select="." regex="{$regex}">
            <xsl:matching-substring>
               <xsl:value-of select="(number(regex-group(1)) * 60) + number(regex-group(2))"/>
            </xsl:matching-substring>
         </xsl:analyze-string>
      </xsl:if>
   </xsl:template>
   
   <xsl:variable name="months" as="element()+">
      <month n="01" abbr="Jan" name="January"/>
      <month n="02" abbr="Feb" name="February"/>
      <month n="03" abbr="Mar" name="March"/>
      <month n="04" abbr="Apr" name="Apr"/>
      <month n="05" abbr="May" name="May"/>
      <month n="06" abbr="Jun" name="June"/>
      <month n="07" abbr="Jul" name="July"/>
      <month n="08" abbr="Aug" name="August"/>
      <month n="09" abbr="Sep" name="September"/>
      <month n="10" abbr="Oct" name="October"/>
      <month n="11" abbr="Nov" name="November"/>
      <month n="12" abbr="Dec" name="December"/>
   </xsl:variable>

   <!-- Converts DD-Mon-YYYY into YYYY-MM-DD (ISO format). -->
   <xsl:template name="ddmonyyyy-convert">
      <xsl:variable name="regex">^(\d\d?)\-(\p{L}{3})\-(\d{4})$</xsl:variable>
      <xsl:if test="matches(.,$regex)">
         <!-- xsl:if test="regex-group(2) = $months/@abbr" ? to catch when not a known month-->
         <xsl:analyze-string select="." regex="{$regex}">
            <xsl:matching-substring>
               <xsl:value-of
                  select="string-join(
                     (regex-group(3),$months[@abbr=regex-group(2)]/@n,format-number(number(regex-group(1)),'00')),
                     '-')"/>
            </xsl:matching-substring>
         </xsl:analyze-string>
      </xsl:if>
   </xsl:template>
   
   <!-- Converts YYYYMMDD into YYYY-MM-DD (ISO format). -->
   <xsl:template name="yyyymmdd-convert">
      <xsl:variable name="regex">^(\d{4})(\d{2})(\d{2})$</xsl:variable>
      <xsl:if test="matches(.,$regex)">
         <xsl:analyze-string select="." regex="{$regex}">
            <xsl:matching-substring>
               <xsl:value-of select="string-join(
                     (regex-group(1),regex-group(2),regex-group(3)), '-')"/>
            </xsl:matching-substring>
         </xsl:analyze-string>
      </xsl:if>
   </xsl:template>

   <!-- ** LATENT OBSERVATIONS ** -->

   <xsl:function name="sxx:latent-issue" as="xs:string?">
      <!-- Performs an integrity check of the data, reporting latent
           issues (observations) as a string. No latent issues returns
           an empty sequence. -->
      <xsl:param name="n" as="item()*"/>
      <xsl:variable name="translation" as="xs:string?">
         <xsl:choose>
            <xsl:when test="$n instance of node()*">
               <!-- a fallback template in mode 'translate' provides the node's
                    value as its own translation; elements with templates matching
                    in mode 'translate' generating no results (because translations
                    fail) will get nothing back. -->
               <xsl:apply-templates select="$n" mode="translate"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$n"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      
      <xsl:choose>
         <xsl:when test="count($n) gt 1">MULTIPLE-NODES-PROVIDED</xsl:when>
         <xsl:when test="empty($n)">NODE-NOT-PROVIDED-FOR-VALUE</xsl:when>
         <!-- there is one item -->
         <xsl:when test="$n instance of xs:boolean and not($n)">DEBUG.VALUE-NOT-MAPPED</xsl:when>
         <xsl:when test="string($n)=''">VALUE-NOT-PROVIDED</xsl:when>
         <xsl:when test="replace(string($n),'\s','')=''">VALUE-WAS-WHITESPACE</xsl:when>
         <xsl:when test="empty($translation)">VALUE-FAILED-TRANSLATION</xsl:when>
         <xsl:otherwise/>
      </xsl:choose>
   </xsl:function>

   <xsl:function name="sxx:unify-nodes" as="node()*">
      <!-- Accepts a sequence of nodes; if all have the same value, the first
        is returned, otherwise all are returned. -->
      <xsl:param name="nodes" as="node()*"/>
      <xsl:choose>
         <xsl:when test="$nodes != $nodes">
            <xsl:sequence select="$nodes"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="$nodes[1]"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   

   <!-- ** FALLBACK LOGIC ** -->
   <!-- For generating exceptions when mappings are incorrect.  -->

   <!-- The following template is called only when this stylesheet is invoked standalone
        (i.e. not imported into generate-canonical-and-add-to-container.xsl);
        it simply assumes a canonical should be generated from the source document,
        considered to be a message without a container. -->
   <xsl:template match="/*">
      <xsl:apply-templates select="." mode="generate-canonical"/>
   </xsl:template>
   
   <!-- We generate an error message when the provider gives us no better match on provider-message -->
   <xsl:template match="*" mode="generate-canonical">
      <xsl:call-template name="exception">
         <xsl:with-param name="test" select="true()"/>
         <xsl:with-param name="msg">
            <xsl:text>Provider '</xsl:text>
            <xsl:value-of select="$provider"/>
            <xsl:text>' is not a recognized provider for messages of type '</xsl:text>
            <xsl:value-of select="name()"/>
            <xsl:text>'.</xsl:text>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   
   <!-- mode 'release' is for generating the release level (when needed); elements corresponding to releases should be matched explicitly in a mapping module. -->
   <xsl:template match="*" mode="release">
      <xsl:call-template name="exception">
         <xsl:with-param name="test" select="true()"/>
         <xsl:with-param name="msg">
            <xsl:text>Element </xsl:text>
            <xsl:value-of select="name()"/>
            <xsl:text> unexpectedly matched in mode 'release'; provider is </xsl:text>
            <xsl:value-of select="$provider"/>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   
   <!-- mode 'recording' is for generating the recording level; elements corresponding to releases should be matched explicitly in a mapping module. -->
   <xsl:template match="*" mode="recording">
      <xsl:call-template name="exception">
         <xsl:with-param name="test" select="true()"/>
         <xsl:with-param name="msg">
            <xsl:text>Element </xsl:text>
            <xsl:value-of select="name()"/>
            <xsl:text> unexpectedly matched in mode 'recording'; provider is </xsl:text>
            <xsl:value-of select="$provider"/>
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>

   <!-- Utility function for generating EXCEPTION elements in the results. -->
   
   <xsl:template name="exception">
      <xsl:param name="test" select="false()"/>
      <xsl:param name="msg">(no message given)</xsl:param>
      <xsl:if test="$test">
         <EXCEPTION>
            <xsl:text>EXCEPTION - </xsl:text>
            <xsl:copy-of select="$msg"/>
         </EXCEPTION>
      </xsl:if>
   </xsl:template>
   
</xsl:stylesheet>
