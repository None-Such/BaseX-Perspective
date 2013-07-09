<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:sxx="http://www.SoundExchange/ns/xslt/util"
   exclude-result-prefixes="#all"
   version="2.0">

   <!-- Module mapping Excel XML messages into Release ID Canonical (definitively comparable) format.
      
        NOT FOR STANDALONE USE! Called in by generate-canonical.xsl -->
   
   <!-- MS EXCEL 'virtual release' wrapper -->
   <xsl:template match="aggregate[$provider='Excel']" mode="generate-canonical" priority="1">
      <xsl:apply-templates select="canonical" mode="release">
         <!-- false() comes through as '' with @latent='VALUE-NOT-MAPPED' -->
         <xsl:with-param tunnel="yes" name="messageID" select="false()"/>
         <xsl:with-param tunnel="yes" name="messageLanguage" select="'en'"/>
         <xsl:with-param tunnel="yes" name="messageIntent" select="false()"/>
      </xsl:apply-templates>
   </xsl:template>
   
   <!-- MS EXCEL release -->   
   <xsl:template match="canonical[$provider='Excel']" mode="release" priority="1">
      <xsl:call-template name="generate-canonical">
         <xsl:with-param tunnel="yes" name="releaseType" select="if (count(recording) gt 1) then 'album' else 'single'"/>
         <xsl:with-param tunnel="yes" name="releaseUPC" select="sxx:unify-nodes(release/upc/v)"/>
         <xsl:with-param tunnel="yes" name="releaseTitle" select="sxx:unify-nodes(release/title/v)"/>
         <xsl:with-param tunnel="yes" name="releaseArtists" select="sxx:unify-nodes(release/artists/v)"/>
         <xsl:with-param tunnel="yes" name="releaseLabel" select="sxx:unify-nodes(release/label/v)"/>
         <xsl:with-param tunnel="yes" name="releaseOriginalDate" select="sxx:unify-nodes(release/date-originated/v)"/>
         <xsl:with-param tunnel="yes" name="releaseGenre" select="sxx:unify-nodes(release/genre/v)"/>
         <xsl:with-param name="recordings" select="recording"/>
      </xsl:call-template>
   </xsl:template>
   
   <!-- MS EXCEL recording -->
   <xsl:template match="recording[$provider='Excel']" mode="recording" priority="1">
      <xsl:call-template name="generate-recording">
         <xsl:with-param tunnel="yes" name="recordingISRC" select="isrc"/>
         <xsl:with-param tunnel="yes" name="recordingTitle" select="title"/>
         <xsl:with-param tunnel="yes" name="recordingArtists" select="artists"/>
         <xsl:with-param tunnel="yes" name="recordingLabel" select="label"/>
         <xsl:with-param tunnel="yes" name="recordingComponent" select="component"/>
         <xsl:with-param tunnel="yes" name="recordingPosition" select="position"/>
         <xsl:with-param tunnel="yes" name="recordingDuration" select="duration"/>
         <xsl:with-param tunnel="yes" name="recordingGenre" select="genre"/>
      </xsl:call-template>
   </xsl:template>
   
   <!-- Value normalization for Excel. -->
   
   <!--<xsl:template mode="value" match="recording[$provider='Excel']/duration">
      <xsl:call-template name="mmmss-convert"/>
   </xsl:template>-->
   
   <!--<xsl:template mode="value" match="release[$provider='Excel']/date-originated/v">
      <xsl:call-template name="ddmonyyyy-convert"/>
   </xsl:template>-->
   
</xsl:stylesheet>
