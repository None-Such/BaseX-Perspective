<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:sxx="http://www.SoundExchange/ns/xslt/util" exclude-result-prefixes="#all"
   version="2.0">

   <!-- Module mapping Universal messages into Release ID Canonical (definitively comparable) format.
      
        NOT FOR STANDALONE USE! Called in by generate-canonical.xsl -->
   
   <!-- Universal release -->
   <xsl:template match="product[$provider='Universal']" mode="generate-canonical" priority="1">
      <xsl:call-template name="generate-canonical">
         <!-- false() comes through as '' with @latent='VALUE-NOT-MAPPED' -->
         <xsl:with-param tunnel="yes" name="messageID" select="false()"/>
         <xsl:with-param tunnel="yes" name="messageLanguage" select="'en'"/>
         <xsl:with-param tunnel="yes" name="messageIntent" select="type"/>
         <xsl:with-param tunnel="yes" name="releaseType" select="if (count(tracks/track) gt 1) then 'album' else 'single'"/>
         <xsl:with-param tunnel="yes" name="releaseUPC" select="@upc"/>
         <xsl:with-param tunnel="yes" name="releaseTitle" select="prd_title"/>
         <xsl:with-param tunnel="yes" name="releaseArtists" select="prd_contributors/artist_name"/>
         <xsl:with-param tunnel="yes" name="releaseLabel" select="prd_label_name"/>
         <xsl:with-param tunnel="yes" name="releaseOriginalDate" select="release_date"/>
         <xsl:with-param tunnel="yes" name="releaseGenre" select="genre"/>
         <xsl:with-param name="recordings" select="tracks/track"/>
         <!-- Currently mapping all tracks, even those with type='delete' -->
      </xsl:call-template>
   </xsl:template>
   
   <!-- Universal Recording -->
   <xsl:template match="product[$provider='Universal']//track" mode="recording">
      <xsl:call-template name="generate-recording">
         <xsl:with-param tunnel="yes" name="recordingISRC" select="@isrc"/>
         <xsl:with-param tunnel="yes" name="recordingTitle" select="track_title"/>
         <xsl:with-param tunnel="yes" name="recordingArtists" select="track_contributors/artist_name"/>
         <xsl:with-param tunnel="yes" name="recordingLabel" select="track_label"/>
         <!-- overriding implicit position -->
         <xsl:with-param tunnel="yes" name="recordingComponent" select="volume"/>
         <xsl:with-param tunnel="yes" name="recordingPosition" select="track_number"/>
         <xsl:with-param tunnel="yes" name="recordingDuration" select="track_length"/>
         <xsl:with-param tunnel="yes" name="recordingGenre" select="track_genre"/>
      </xsl:call-template>
   </xsl:template>
   
   <!-- ** TRANSLATIONS (Provider Specific) ** -->
   
   <xsl:template mode="translate" match="product//track/track_length" as="text()?">
      <!-- Universal track_length is expected as HH:MM:SS -->
      <xsl:call-template name="hhmmss-convert"/>
   </xsl:template>
   
   <xsl:template mode="translate" match="product//release_date" as="text()?">
      <!-- Universal dates are expected as DD-Mon-YYYY -->
      <xsl:call-template name="ddmonyyyy-convert"/>
   </xsl:template>
   
</xsl:stylesheet>
