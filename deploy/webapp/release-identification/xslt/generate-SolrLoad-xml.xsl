<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:sxx="http://www.SoundExchange/ns/xslt/util" exclude-result-prefixes="#all"
   version="2.0">
   
   <xsl:import href="utility/filter-out-linefeeds-and-normalize-whitespace.xsl"/>
   
   <xsl:strip-space elements="*"/>
   <xsl:output indent="yes"/>
   
   <xsl:variable name="serialization-format" as="element()">
      <output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
         <output:indent value="no"/>
      </output:serialization-parameters>
   </xsl:variable>
   
   <xsl:template match="/sx-container" priority="5">
      <xsl:variable name="sx-manifest" select="sx-manifest"/>
      <xsl:variable name="canonical"   select="canonical[@content-type='repertoire-release']"/>
      <xsl:variable name="observations" select="observations"/>
      <xsl:variable name="provider-manifest"   select="$canonical/provider-manifest"/>
      <xsl:variable name="release"   select="$canonical/release"/>
      <xsl:variable name="recordings"   select="$canonical/recording"/>
      <xsl:variable name="container-safe">
         <xsl:apply-templates select="." mode="safe"/>
      </xsl:variable>

      <Solr-Load messageID="{($provider-manifest/message-id[normalize-space(.)],'none')[1]}">
         <xsl:call-template name="string-value">
            <xsl:with-param name="name">sxm_provider</xsl:with-param>
            <xsl:with-param name="n" select="$sx-manifest/provider"/>
         </xsl:call-template>
         <xsl:call-template name="string-value">
            <xsl:with-param name="name">sxm_location_received</xsl:with-param>
            <xsl:with-param name="n" select="$sx-manifest/location-received"/>
         </xsl:call-template>
         <xsl:call-template name="string-value">
            <xsl:with-param name="name">sxm_date_time_received</xsl:with-param>
            <xsl:with-param name="n" select="$sx-manifest/date-time-received"/>
         </xsl:call-template>
         <xsl:call-template name="string-value">
            <xsl:with-param name="name">sxm_release_sxic</xsl:with-param>
            <xsl:with-param name="n">
               <xsl:value-of select="sxx:fake-sxic(.)"/>
            </xsl:with-param>
         </xsl:call-template>
         <xsl:call-template name="string-value">
            <xsl:with-param name="name">sxm_schema</xsl:with-param>
            <xsl:with-param name="n" select="$sx-manifest/format/schema"/>
         </xsl:call-template>
         <xsl:call-template name="string-value">
            <xsl:with-param name="name">sxm_schema_variant</xsl:with-param>
            <xsl:with-param name="n" select="$sx-manifest/format/schema-variant"/>
         </xsl:call-template>
         <xsl:call-template name="string-value">
            <xsl:with-param name="name">pm_message_id</xsl:with-param>
            <xsl:with-param name="n" select="$provider-manifest/message-id"/>
         </xsl:call-template>
         <xsl:call-template name="string-value">
            <xsl:with-param name="name">pm_message_language</xsl:with-param>
            <xsl:with-param name="n" select="$provider-manifest/message-language"/>
         </xsl:call-template>
         <xsl:call-template name="string-value">
            <xsl:with-param name="name">pm_message_intent</xsl:with-param>
            <xsl:with-param name="n" select="$provider-manifest/message-intent"/>
         </xsl:call-template>
         <xsl:call-template name="string-value">
            <xsl:with-param name="name">release_upc</xsl:with-param>
            <xsl:with-param name="n" select="$release/upc"/>
         </xsl:call-template>
         <xsl:call-template name="string-value">
            <xsl:with-param name="name">release_title</xsl:with-param>
            <xsl:with-param name="n" select="$release/title"/>
         </xsl:call-template>
         <xsl:call-template name="string-value">
            <xsl:with-param name="name">release_artists</xsl:with-param>
            <xsl:with-param name="n" select="$release/artists"/>
         </xsl:call-template>
         <xsl:call-template name="string-value">
            <xsl:with-param name="name">release_label</xsl:with-param>
            <xsl:with-param name="n" select="$release/label"/>
         </xsl:call-template>
         <xsl:call-template name="string-value">
            <xsl:with-param name="name">release_genre</xsl:with-param>
            <xsl:with-param name="n" select="$release/genre"/>
         </xsl:call-template>
         <xsl:call-template name="string-value">
            <xsl:with-param name="name">release_original_date</xsl:with-param>
            <xsl:with-param name="n" select="$release/date-originated"/>
         </xsl:call-template>
         <xsl:call-template name="multi-value">
            <xsl:with-param name="name">recording_isrc</xsl:with-param>
            <xsl:with-param name="n" select="$recordings/isrc"/>
         </xsl:call-template>
         <xsl:call-template name="multi-value">
            <xsl:with-param name="name">recording_title</xsl:with-param>
            <xsl:with-param name="n" select="$recordings/title"/>
         </xsl:call-template>
         <xsl:call-template name="multi-value">
            <xsl:with-param name="name">recording_artists</xsl:with-param>
            <xsl:with-param name="n" select="$recordings/artists"/>
         </xsl:call-template>
         <xsl:call-template name="multi-numeric-value">
            <xsl:with-param name="name">recording_duration</xsl:with-param>
            <xsl:with-param name="n" select="$recordings/duration"/>
         </xsl:call-template>
         <xsl:call-template name="multi-value">
            <xsl:with-param name="name">recording_component</xsl:with-param>
            <xsl:with-param name="n" select="$recordings/component"/>
         </xsl:call-template>
         <xsl:call-template name="multi-value">
            <xsl:with-param name="name">recording_position</xsl:with-param>
            <xsl:with-param name="n" select="$recordings/position"/>
         </xsl:call-template>
         <xsl:call-template name="multi-value">
            <xsl:with-param name="name">recording_genre</xsl:with-param>
            <xsl:with-param name="n" select="$recordings/genre"/>
         </xsl:call-template>
         <xsl:call-template name="multi-value">
            <xsl:with-param name="name">observation</xsl:with-param>
            <xsl:with-param name="n" select="$observations/observation/
               string-join((@type,@item-address,string-join(*,' | ')[normalize-space()]),' &#x25B7; ')"/>
            <xsl:with-param name="fallback">[no observations]</xsl:with-param>
         </xsl:call-template>
         <xsl:call-template name="multi-value">
            <xsl:with-param name="name">observation_type</xsl:with-param>
            <xsl:with-param name="n" select="$observations/observation/@type"/>
            <xsl:with-param name="fallback">[no observations]</xsl:with-param>
         </xsl:call-template>
         <xsl:call-template name="multi-value">
            <xsl:with-param name="name">observation_item_address</xsl:with-param>
            <xsl:with-param name="n" select="$observations/observation/@item-address"/>
            <xsl:with-param name="fallback">[no observations]</xsl:with-param>
         </xsl:call-template>
         <xsl:call-template name="multi-value">
            <xsl:with-param name="name">observation_item_context</xsl:with-param>
            <xsl:with-param name="n" select="$observations/observation/@item-context"/>
            <xsl:with-param name="fallback">[no observations]</xsl:with-param>
         </xsl:call-template>
         
         <xsl:call-template name="multi-value">
            <xsl:with-param name="name">observation_content_before_after</xsl:with-param>
            <xsl:with-param name="n" select="$observations/observation[exists(content-provided) and exists(content-attested)]/
               string-join((content-attested,content-provided),' &#x25B7; ')"/>
            <xsl:with-param name="fallback">[no observations]</xsl:with-param>
         </xsl:call-template>
         <xsl:call-template name="multi-value">
            <!-- TODO: extend to cover reoccuring tokens -->
            <xsl:with-param name="name">observation_token_added</xsl:with-param>
            <xsl:with-param name="n" as="element()*">
               <xsl:apply-templates select="$observations/observation[exists(content-provided) and exists(content-attested)]"
                  mode="tokens-added"/>
            </xsl:with-param>
            <xsl:with-param name="fallback">[no tokens added]</xsl:with-param>
         </xsl:call-template>
         <xsl:call-template name="multi-value">
            <!-- TODO: extend to cover reoccuring tokens -->
            <xsl:with-param name="name">observation_token_removed</xsl:with-param>
            <xsl:with-param name="n" as="element()*">
               <xsl:apply-templates select="$observations/observation[exists(content-provided) and exists(content-attested)]"
                  mode="tokens-removed"/>
            </xsl:with-param>
            <xsl:with-param name="fallback">[no tokens removed]</xsl:with-param>
         </xsl:call-template>
         
         <xsl:call-template name="string-value">
            <xsl:with-param name="name">comparison_sequence_position</xsl:with-param>
            <xsl:with-param name="n" select="$observations/observation[@type='debug.comparative.comparison-sequence.location']"/>
            <xsl:with-param name="fallback">0</xsl:with-param>
         </xsl:call-template>
         <xsl:call-template name="string-value">
            <xsl:with-param name="name">comparison_last_in_sequence</xsl:with-param>
            <xsl:with-param name="n" select="$observations/observation[@type='debug.comparative.comparison-sequence.is-last']/'true'"/>
            <xsl:with-param name="fallback">false</xsl:with-param>
         </xsl:call-template>
         <xsl:call-template name="xml-value">
            <xsl:with-param name="name">container</xsl:with-param>
            <xsl:with-param name="n" select="$container-safe"/>
         </xsl:call-template>
         <provider_message_stored type="string">
            <xsl:choose>
               <xsl:when test="exists(self::sx-container/provider-message)">true</xsl:when>
               <xsl:otherwise>false</xsl:otherwise>
            </xsl:choose>
         </provider_message_stored>
      </Solr-Load>
   </xsl:template>
   
   <xsl:template match="/*">
      <EXCEPTION>
         <xsl:text>EXCEPTION: sx-container element expected by generate-SolrLoad-xml.xsl; </xsl:text>
         <xsl:value-of select="name()"/>
         <xsl:text> was found.</xsl:text>
      </EXCEPTION>
   </xsl:template>
   
   <!-- <xsl:when test="empty($n)">[NODE-NOT-PROVIDED-FOR-VALUE]</xsl:when>
        <xsl:when test="string-length($n)=0">[VALUE-NOT-PROVIDED]</xsl:when>
        <xsl:otherwise>[VALUE-WAS-WHITESPACE]</xsl:otherwise>  -->
   <xsl:template name="string-value" as="element()">
      <xsl:param name="name"/>
      <xsl:param name="n" as="item()*"/>
      <xsl:param name="fallback" select="()"/>
      <xsl:element name="{$name}">
         <xsl:attribute name="type">string</xsl:attribute>
         <xsl:choose>
            <xsl:when test="exists($n)">
               <xsl:sequence select="string-join($n,' ')"/>
            </xsl:when>
            <xsl:when test="exists($fallback)">
               <xsl:value-of select="$fallback"/>
            </xsl:when>
            <!--<xsl:when test="string($value)">[VALUE-WAS-WHITESPACE]</xsl:when>-->
            <xsl:otherwise/>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   
   <xsl:template name="multi-value" as="element()">
      <xsl:param name="name" as="xs:string"/>
      <xsl:param name="n" as="item()*"/>
      <xsl:param name="fallback" select="()"/>
      <xsl:element name="{$name}">
         <xsl:attribute name="type">multi-value</xsl:attribute>
         <xsl:for-each select="$n">
            <v>
               <xsl:value-of select="normalize-space(.)"/>
            </v>
         </xsl:for-each>
         <xsl:if test="empty($n)">
            <v>
               <xsl:value-of select="$fallback"/>
            </v>
         </xsl:if>
      </xsl:element>
   </xsl:template>
   
   <xsl:template name="multi-numeric-value" as="element()">
      <xsl:param name="name" as="xs:string"/>
      <xsl:param name="n" as="item()*"/>
      <xsl:param name="fallback" select="()"/>
      <xsl:element name="{$name}">
         <xsl:attribute name="type">multi-value</xsl:attribute>
         <xsl:for-each select="$n">
            <v>
               <xsl:value-of select="if (. castable as xs:decimal) then . else -1"/>
            </v>
         </xsl:for-each>
         <xsl:if test="empty($n)">
            <v>
               <xsl:value-of select="$fallback"/>
            </v>
         </xsl:if>
      </xsl:element>
   </xsl:template>
   
   <xsl:template name="xml-value" as="element()">
      <xsl:param name="name" as="xs:string"/>
      <xsl:param name="n" as="node()"/>
      <xsl:param name="fallback" select="()"/>
      <xsl:element name="{$name}">
         <xsl:attribute name="type">xml</xsl:attribute>
         <!--<xsl:value-of select="serialize($n)"/>-->
         <xsl:copy-of select="$n"/>
         <!--<xsl:value-of select="serialize($n,$serialization-format)"/>-->
      </xsl:element>
   </xsl:template>
   
   <xsl:template match="observation" mode="tokens-added" as="element()*">
      <!-- TODO: extend to cover reoccuring tokens -->
      <xsl:variable name="old-tokens" select="tokenize(content-attested,'\s+')"/>
      <xsl:variable name="new-tokens" select="tokenize(content-provided,'\s+')"/>
      <xsl:for-each select="$new-tokens[not(. = $old-tokens)]">
         <new>
            <xsl:value-of select="."/>
         </new>
      </xsl:for-each>
   </xsl:template>
   
   <xsl:template match="observation" mode="tokens-removed" as="element()*">
      <!-- TODO: extend to cover reoccuring tokens -->
      <xsl:variable name="old-tokens" select="tokenize(content-attested,'\s+')"/>
      <xsl:variable name="new-tokens" select="tokenize(content-provided,'\s+')"/>
      <xsl:for-each select="$old-tokens[not(. = $new-tokens)]">
         <old>
            <xsl:value-of select="."/>
         </old>
      </xsl:for-each>
   </xsl:template>
   
   <xsl:template match="*" mode="tokens-added">
      <EXCEPTION>
         <xsl:text>Element </xsl:text>
         <xsl:value-of select="name()"/>
         <xsl:text> unexpectedly matched in mode 'tokens-added' (generate-SolrLoad-xml.xsl)</xsl:text>
      </EXCEPTION>
   </xsl:template>

   <xsl:template match="*" mode="tokens-removed">
      <EXCEPTION>
         <xsl:text>Element </xsl:text>
         <xsl:value-of select="name()"/>
         <xsl:text> unexpectedly matched in mode 'tokens-removed' (generate-SolrLoad-xml.xsl)</xsl:text>
      </EXCEPTION>
   </xsl:template>
   
   <xsl:function name="sxx:fake-sxic" as="xs:string">
      <!-- fake sxic will be 'upc' followed by the upc, all prefixed with zeros
           to make 20 characters total -->
      <xsl:param name="container" as="element(sx-container)"/>
      <xsl:variable name="provider" select="$container/sx-manifest/provider"/>
      <xsl:variable name="upc" select="$container/canonical/release/upc"/>
      <xsl:variable name="p" select="($container//observation[@type='debug.comparative.comparison-sequence.location']/observation-detail[@type='position']/string(),'1')[1]"/>
      <xsl:variable name="l" select="'L'[exists($container//observation[@type='debug.comparative.comparison-sequence.is-last'])]"/>
      <xsl:value-of select="concat($provider,'-upc',$upc,'-',format-number(number($p),'000'),$l)"/>
   </xsl:function>
   
</xsl:stylesheet>