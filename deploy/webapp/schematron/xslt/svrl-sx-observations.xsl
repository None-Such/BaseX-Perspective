<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   exclude-result-prefixes="#all"
   xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
   xmlns:sx="http://soundexchange/ns/schematron/util"
   version="2.0">
   
   <xsl:strip-space elements="*"/>
   
   <xsl:template match="/">
       <observations>
          <xsl:apply-templates/>
       </observations>
   </xsl:template>
   
   <xsl:template match="svrl:successful-report | svrl:failed-assert">
      <observation type="_._" context="{@location}">
         <xsl:apply-templates/>
      </observation>
   </xsl:template>
   
   <xsl:template match="sx:*">
      <xsl:element name="{local-name()}">
      <xsl:copy-of select="@*"/>
         <xsl:apply-templates/>
      </xsl:element>
   </xsl:template>
</xsl:stylesheet>