<?xml version="1.0"?>
<!-- Transform one PressMint file to a TSV file with its metadata. -->
<!-- Includes header row, cf. template for tei:TEI -->
<!-- Needs the file with corpus teiHeader giving the speaker, party etc. info as the "meta" parameter -->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:et="http://nl.ijs.si/et"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    exclude-result-prefixes="et tei xs xi"
    version="2.0">

  <xsl:import href="pressmint-lib.xsl"/>
  
  <xsl:output method="text" encoding="utf-8"/>
  
  <xsl:template match="tei:TEI">
    <xsl:message select="concat('INFO: Converting ', @xml:id, ' to metadata TSV')"/>
    <xsl:text>Text_ID&#9;</xsl:text>
    <xsl:text>ID&#9;</xsl:text>
    <xsl:text>Date&#9;</xsl:text>
    <xsl:text>Newspaper&#9;</xsl:text>
    <xsl:text>Article&#9;</xsl:text>
    <xsl:text>Publisher&#9;</xsl:text>
    <xsl:text>Volume&#9;</xsl:text>
    <xsl:text>Issue&#9;</xsl:text>
    <xsl:text>URN&#9;</xsl:text>
    <xsl:text>URL&#9;</xsl:text>
    <xsl:text>Lang&#9;</xsl:text>
    <xsl:text>Quality&#9;</xsl:text>
    <xsl:text>Image&#9;</xsl:text>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates select="tei:text//tei:p"/>
  </xsl:template>
  
  <xsl:template match="tei:text//tei:p">
    <xsl:variable name="lang-code" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
    <xsl:variable name="lang" select="et:l10n($corpus-language, 
                                       $rootHeader//tei:langUsage/tei:language[@ident = $lang-code])"/>
    <xsl:variable name="bibl" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl"/>
    <xsl:variable name="date" select="$bibl/tei:date/@when"/>
    <xsl:variable name="year" select="replace($date, '-.+', '')"/>
    <xsl:variable name="newspaper" select="$bibl/tei:title[@level='j']"/>
    <xsl:variable name="article" select="$bibl/tei:title[@level='a']"/>
    <xsl:variable name="publisher" select="$bibl/tei:publisher"/>
    <xsl:variable name="volume" select="$bibl/tei:biblScope[@unit='volume']"/>
    <xsl:variable name="issue" select="$bibl/tei:biblScope[@unit='issue']"/>
    <xsl:variable name="URN" select="$bibl/tei:idno[@type='URN']"/>
    <xsl:variable name="URL" select="$bibl/tei:idno[@type='URI']"/>
    
    <xsl:variable name="quality" select="et:l10n($corpus-language, key('idr', @ana, $rootHeader)/tei:catDesc)"/>
    <xsl:variable name="img-url" select="key('idr', preceding::tei:pb[1]/@facs)/tei:graphic/@url"/>

    <!-- Text metadata -->
    <xsl:value-of select="concat($text_id, '&#9;')"/>
    <xsl:value-of select="concat(@xml:id, '&#9;')"/>
    <xsl:value-of select="concat($date, '&#9;')"/>
    <xsl:value-of select="concat($newspaper, '&#9;')"/>
    <xsl:value-of select="concat($article, '&#9;')"/>
    <xsl:value-of select="concat($publisher, '&#9;')"/>
    <xsl:value-of select="concat($volume, '&#9;')"/>
    <xsl:value-of select="concat($issue, '&#9;')"/>
    <xsl:value-of select="concat($URN, '&#9;')"/>
    <xsl:value-of select="concat($URL, '&#9;')"/>
    <!-- Paragraph metadata -->
    <xsl:value-of select="concat($lang, '&#9;')"/>
    <xsl:value-of select="concat($quality, '&#9;')"/>
    <xsl:value-of select="concat($img-url, '&#10;')"/>
  </xsl:template>
  
</xsl:stylesheet>
