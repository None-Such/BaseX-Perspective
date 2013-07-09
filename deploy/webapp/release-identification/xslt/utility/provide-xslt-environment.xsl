<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version='2.0'
  xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>
  
  <xsl:output method="xml" indent="yes"/>
  
  <xsl:template match="/" name="report-xslt-environment">
    <xslt-environment>
      <xsl:for-each select="('version','vendor','vendor-url','product-name','product-version')">
        <xsl:element name="{.}">
          <xsl:value-of select="system-property(string-join(('xsl',.),':'))"/>
        </xsl:element>
      </xsl:for-each>
    </xslt-environment>
  </xsl:template>
   
</xsl:stylesheet>