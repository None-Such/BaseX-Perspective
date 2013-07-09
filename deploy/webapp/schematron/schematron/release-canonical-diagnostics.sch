<?xml version="1.0" encoding="UTF-8"?>
<schema queryBinding="xslt2"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns="http://purl.oclc.org/dsdl/schematron"
   xmlns:sx="http://soundexchange/ns/schematron/util">
   

<!-- Schematron for diagnosing issues in SoundExchange Release Canonical (definitively comparable) -->
   
   <ns prefix="sx" uri="http://soundexchange/ns/schematron/util"/>
   
   <pattern>
      <rule context="canonical//title |
                     canonical//artists">
         <report test=". = upper-case(.)">
            <xsl:sequence select="sx:local-context(.,2)"/> '<value-of select="."/>' is in <sx:observe>all upper case</sx:observe>
         </report>
         <!-- <assert test="string-length(.) gt 3">short</assert> -->
      </rule>
   </pattern>

   <!-- Returns an element sx:context reporting names of element $e and ancestors
        to levels specified by $levels -->
   <xsl:function name="sx:local-context" as="element(sx:local-context)">
      <xsl:param name="e" as="element()"/>
      <xsl:param name="levels" as="xs:integer"/>
      <sx:local-context>
         <xsl:value-of select="string-join($e/ancestor-or-self::*[position() = (1 to $levels)]/name(),'/')"/>
      </sx:local-context>
   </xsl:function>

   <!-- Returns an element sx:instance containing the string value of $i -->
   <xsl:function name="sx:instance" as="element(sx:instance)">
      <xsl:param name="i" as="item()"/>
      <sx:instance>
         <xsl:value-of select="$i"/>
      </sx:instance>
   </xsl:function>
   
</schema>