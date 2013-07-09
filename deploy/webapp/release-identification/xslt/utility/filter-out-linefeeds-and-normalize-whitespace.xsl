<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0">
  
  
  <!-- Removes all comments and PIs and collapses whitespace in
       data, changing all LF and TAB to SPACE. NOT SAFE to use on mixed content. -->
  
  <xsl:template match="* | @*" mode="#default safe">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
   <xsl:template match="text()" mode="#default safe">
    <xsl:value-of select="normalize-space()"/>
  </xsl:template>
   
</xsl:stylesheet>