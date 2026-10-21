<?xml version="1.0"?>
<!-- Transform one PressMint .ana file to plain text -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xsl tei"
  version="2.0">

  <xsl:output method="text"/>
  
  <!-- Element corresponds to one line -->
  <xsl:param name="element">p</xsl:param>

  <xsl:template match="/">
    <xsl:message select="concat('INFO: converting ', tei:TEI/@xml:id, ' to text file')"/>
    <xsl:apply-templates select="//tei:text//tei:*[local-name() = $element]"/>
  </xsl:template>
  
  <xsl:template match="tei:text//tei:*[local-name() = $element]">
    <xsl:variable name="text">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:if test="not(@xml:id)">
      <xsl:message select="concat('WARN: ', local-name(), ' without ID, first column will be empty!')"/>
    </xsl:if>
    <xsl:value-of select="concat(@xml:id, '&#9;', 
                          normalize-space($text), '&#10;')"/>
  </xsl:template>

  <xsl:template match="tei:text//tei:note">
    <xsl:variable name="text">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:variable>
    <xsl:value-of select="concat('[[', normalize-space($text), ']]')"/>
  </xsl:template>

  <xsl:template match="tei:s[tei:w | tei:pc]//text()"/>

  <xsl:template match="tei:w | tei:pc">
    <xsl:message select="concat('DEBUG2: ', local-name())"/>
    <xsl:value-of select="normalize-space(.)"/> <!-- space normalization fixes indentation inside orthographical tokes -->
    <xsl:if test="not(@join = 'right')">
      <xsl:text>&#32;</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:*">
    <xsl:message select="concat('DEBUG: ', local-name())"/>
    <xsl:apply-templates/>
  </xsl:template>

</xsl:stylesheet>
