<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:sxx="http://www.SoundExchange/ns/xslt/util" exclude-result-prefixes="#all"
   version="2.0">

   <!-- Module mapping Warner DDEX messages into Release ID Canonical (definitively comparable) format.
      
        NOT FOR STANDALONE USE! Called in by generate-canonical.xsl -->
 
   <!-- Warner message -->
   <xsl:template match="*:NewReleaseMessage[$provider='Warner']" mode="generate-canonical" priority="1">
      <xsl:apply-templates select="(ReleaseList/Release[ReleaseType=('Single','Album')])[1]" mode="release">
         <xsl:with-param tunnel="yes" name="messageID" select="MessageHeader/MessageId"/>
         <xsl:with-param tunnel="yes" name="messageLanguage" select="@LanguageAndScriptCode"/>
         <xsl:with-param tunnel="yes" name="messageIntent" select="UpdateIndicator"/>
      </xsl:apply-templates>
      <xsl:call-template name="exception">
         <xsl:with-param name="test" select="empty(ReleaseList/Release[ReleaseType=('Single','Album')])"/>
         <xsl:with-param name="msg">DDEX message gives no Release of type 'Single' or 'Album'. </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="exception">
         <xsl:with-param name="test" select="count(ReleaseList/Release[ReleaseType=('Single','Album')]) gt 1"/>
         <xsl:with-param name="msg">DDEX message more than one Release of type 'Single' or 'Album'. (Only the first is processed.)</xsl:with-param>
      </xsl:call-template>
   </xsl:template>
   
   
   
   <!-- Warner release -->
   <xsl:template match="*:NewReleaseMessage[$provider='Warner']//Release" mode="release" priority="1">
      <xsl:variable name="Release_Details" select="ReleaseDetailsByTerritory[1]"/>
      <xsl:call-template name="generate-canonical">
         <xsl:with-param tunnel="yes" name="releaseType" select="ReleaseType"/>
         <xsl:with-param tunnel="yes" name="releaseUPC" select="ReleaseId/ICPN"/>
         <xsl:with-param tunnel="yes" name="releaseTitle" select="ReferenceTitle/TitleText"/>
         <xsl:with-param tunnel="yes" name="releaseArtists" select="$Release_Details/DisplayArtistName"/>
         <xsl:with-param tunnel="yes" name="releaseLabel" select="$Release_Details/LabelName[not(@LabelNameType='MajorLabel')]"/>
         <xsl:with-param tunnel="yes" name="releaseOriginalDate" select="$Release_Details/OriginalReleaseDate"/>
         <xsl:with-param tunnel="yes" name="releaseGenre" select="$Release_Details/Genre/GenreText"/>
         
         <xsl:with-param name="recordings" select="key('DDEX-Recording-by-ResourceNumber',ReleaseResourceReferenceList/ReleaseResourceReference)"/>
      </xsl:call-template>
   </xsl:template>
   
   <!-- Warner recording -->
   <xsl:template match="SoundRecording[$provider='Warner']" mode="recording">
      <xsl:variable name="Recording_Details" select="SoundRecordingDetailsByTerritory[1]"/>
      <xsl:call-template name="generate-recording">
         <xsl:with-param tunnel="yes" name="recordingISRC" select="SoundRecordingId/ISRC"/>
         <xsl:with-param tunnel="yes" name="recordingTitle" select="ReferenceTitle/TitleText"/>
         <xsl:with-param tunnel="yes" name="recordingArtists" select="$Recording_Details/DisplayArtist/PartyName"/>
         <xsl:with-param tunnel="yes" name="recordingLabel" select="$Recording_Details/LabelName[not(@LabelNameType='MajorLabel')]"/>
         <xsl:with-param tunnel="yes" name="recordingDuration" select="Duration"/>
         <xsl:with-param tunnel="yes" name="recordingGenre" select="$Recording_Details/Genre/GenreText"/>
      </xsl:call-template>
   </xsl:template>
   
</xsl:stylesheet>
