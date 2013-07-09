<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
   version="2.0">

   <!-- Composes a default sx-manifest for a message. -->

   <xsl:param name="provider" required="yes"/>
   <xsl:param name="transmissionMedium" select="'HYDRATION'"/>
   <xsl:param name="debug" select="'false'"/>

   <xsl:variable name="transformVersion" select="'0.1.0'"/>

   <xsl:variable name="debugging" select="$debug = 'true'"/>

   <xsl:template match="/">
      <sx-manifest type="release-canonical">
         <xsl:if test="$debugging">
            <xsl:attribute name="transform-version" select="$transformVersion"/>
         </xsl:if>
         <provider>
            <xsl:value-of select="$provider"/>
         </provider>
         <date-time-received>
            <xsl:value-of select="current-dateTime()"/>
         </date-time-received>
         <transmission-medium>
            <xsl:value-of select="$transmissionMedium"/>
         </transmission-medium>
         <location-archived>
            <xsl:value-of select="document-uri(/)"/>
         </location-archived>
         <location-received>
            <xsl:value-of select="document-uri(/)"/>
         </location-received>
         <release-sxic/>
         <format>
            <media-type>application/xml</media-type>
            <xsl:apply-templates mode="assign-schema"/>
            <xsl:apply-templates mode="assign-schema-variant"/>
         </format>
      </sx-manifest>
   </xsl:template>

   <xsl:template match="*[$provider=('Ingrooves','Warner','Orchard')]" mode="assign-schema">
      <schema>DDEX</schema>
   </xsl:template>
   
   <xsl:template match="*[$provider=('Universal','Sony')]" mode="assign-schema">
      <schema>
         <xsl:value-of select="$provider"/>
         <xsl:text> proprietary</xsl:text>
      </schema>
   </xsl:template>
   
   <xsl:template match="*[$provider=('Excel')]" mode="assign-schema">
      <schema>MS Excel export XML</schema>
   </xsl:template>
   
   <xsl:template match="*[$provider=('Finetunes')]" mode="assign-schema">
      <schema>OpenSDX</schema>
   </xsl:template>
   
   <xsl:template match="*" mode="assign-schema">
      <EXCEPTION>
         <xsl:text>EXCEPTION: provider '</xsl:text>
         <xsl:value-of select="$provider"/>
         <xsl:text>' is NOT MAPPED by compose-provisional-sx-manifest.xsl (matching </xsl:text>
         <xsl:value-of select="name()"/>
         <xsl:text>)</xsl:text>
      </EXCEPTION>
   </xsl:template>

   <xsl:template match="*[$provider=('Ingrooves','Warner','Orchard')]" mode="assign-schema-variant">
      <schema-variant>
         <xsl:value-of select="@MessageSchemaVersionId/concat(.,' ')"/>
         <xsl:text>(</xsl:text>
         <xsl:value-of select="$provider"/>
         <xsl:text>)</xsl:text>
      </schema-variant>
   </xsl:template>

   <xsl:template match="*[$provider=('Universal','Sony')]" mode="assign-schema-variant">
      <schema-variant>
         <xsl:value-of select="$provider"/>
      </schema-variant>
   </xsl:template>
   
   <!--TODO: pass a better value through the pipeline. -->
   <xsl:template match="*[$provider='Excel']" mode="assign-schema-variant">
      <schema-variant>
         <xsl:value-of select="$provider"/>
      </schema-variant>
   </xsl:template>
   
   <xsl:template match="*[$provider=('Finetunes')]" mode="assign-schema-variant">
      <schema-variant>
         <xsl:value-of select="string-join((replace(/feed/@*:noNamespaceSchemaLocation,'.*/',''),'(Finetunes)'), ' ')"/>
      </schema-variant>
   </xsl:template>
   
   <xsl:template match="*" mode="assign-schema-variant">
      <EXCEPTION>
         <xsl:text>EXCEPTION: provider '</xsl:text>
         <xsl:value-of select="$provider"/>
         <xsl:text>' is NOT MAPPED by compose-provisional-sx-manifest.xsl</xsl:text>
      </EXCEPTION>
   </xsl:template>

</xsl:stylesheet>
