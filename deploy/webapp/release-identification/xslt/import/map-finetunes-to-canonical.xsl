<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:sxx="http://www.SoundExchange/ns/xslt/util" exclude-result-prefixes="#all"
   version="2.0">

   <!-- Module mapping Finetunes messages into Release ID Canonical (definitively comparable) format.
      
        NOT FOR STANDALONE USE! Called in by generate-canonical.xsl -->
   
   <xsl:template match="feed[$provider='Finetunes']" mode="generate-canonical" priority="1">
      <xsl:apply-templates select="bundle[1]" mode="release">
         <xsl:with-param tunnel="yes" name="messageID" select="MessageHeader/MessageId"/>
         <xsl:with-param tunnel="yes" name="messageLanguage" select="'de'"/>
         <xsl:with-param tunnel="yes" name="messageIntent" select="UpdateIndicator"/>
      </xsl:apply-templates>
      <xsl:call-template name="exception">
         <xsl:with-param name="test" select="empty(bundle)"/>
         <xsl:with-param name="msg">OpenSDX message gives no bundle. </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="exception">
         <xsl:with-param name="test" select="count(bundle) gt 1"/>
         <xsl:with-param name="msg">OpenSDX message has more than one bundle. (Only the first is processed.)</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   
   
   
   <!-- Finetunes release -->
   <xsl:template match="bundle[$provider='Finetunes']" mode="release" priority="1">
      <xsl:call-template name="generate-canonical">
         <xsl:with-param tunnel="yes" name="messageID" select="../feedinfo/feedid"/>
         <xsl:with-param tunnel="yes" name="messageLanguage" select="'de'"/>
         <!-- false() comes through as '' with @latent='VALUE-NOT-MAPPED' -->
         <xsl:with-param tunnel="yes" name="messageIntent" select="false()"/>
         <xsl:with-param tunnel="yes" name="releaseType" select="if (count(items/item) gt 1) then 'album' else 'single'"/>
         <xsl:with-param tunnel="yes" name="releaseUPC" select="ids/upc"/>
         <xsl:with-param tunnel="yes" name="releaseTitle" select="name"/>
         <xsl:with-param tunnel="yes" name="releaseArtists" select="display_artistname"/>
         <xsl:with-param tunnel="yes" name="releaseLabel" select="contributors/contributor[type='label']/name"/>
         <xsl:with-param tunnel="yes" name="releaseOriginalDate" select="information/physical_release_datetime"/>
         <xsl:with-param tunnel="yes" name="releaseGenre" select="tags/genres/genre"/>
         <xsl:with-param name="recordings" select="items/item"/>
      </xsl:call-template>
   </xsl:template>
   
   <!-- Finetunes Recording -->
   <xsl:template match="bundle[$provider='Finetunes']//item" mode="recording">
      <xsl:call-template name="generate-recording">
         <xsl:with-param tunnel="yes" name="recordingISRC" select="ids/isrc"/>
         <xsl:with-param tunnel="yes" name="recordingTitle" select="displayname"/>
         <xsl:with-param tunnel="yes" name="recordingArtists" select="display_artistname"/>
         <xsl:with-param tunnel="yes" name="recordingLabel" select="contributors/contributor[type='label']/name"/>
         <!-- overriding implicit position -->
         <xsl:with-param tunnel="yes" name="recordingComponent" select="information/setnum"/>
         <xsl:with-param tunnel="yes" name="recordingPosition" select="information/num"/>
         <xsl:with-param tunnel="yes" name="recordingDuration" select="information/playlength"/>
         <xsl:with-param tunnel="yes" name="recordingGenre" select="tags/genres/genre"/>
      </xsl:call-template>
   </xsl:template>
   
   <!-- Value normalization for Finetunes. -->
   
   <xsl:template mode="translate" match="information/physical_release_datetime" as="text()?">
      <!-- converting time-and-date stamp to just the date
           e.g. 2003-12-31 23:00:00 GMT+00:00 becomes 2003-12-31 -->
      <xsl:variable name="regex">\d{4}-\d{2}-\d{2}</xsl:variable>
      <xsl:if test="matches(.,$regex)">
         <xsl:analyze-string select="." regex="{$regex}">
            <xsl:matching-substring>
               <xsl:value-of select="regex-group(0)"/>
            </xsl:matching-substring>
         </xsl:analyze-string>
      </xsl:if>
   </xsl:template>
   
   
</xsl:stylesheet>
