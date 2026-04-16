<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"                
    exclude-result-prefixes="tei html"
    version="2.0">
    <!-- import base conversion style -->
    <!--xsl:import href="../default/html/to.xsl"/-->
    <xsl:import href="../../Stylesheets/profiles/default/html/to.xsl"/>

   <!-- Indent only for debugging! -->
   <xsl:output method="xhtml" indent="no" omit-xml-declaration="yes"/>
   <xsl:preserve-space elements="head p li span hi"/>

   <!-- Use local copy -->
   <xsl:param name="cssFile">tei.css</xsl:param>
   <xsl:param name="cssPrintFile">tei-print.css</xsl:param>
   <!--xsl:param name="cssFile">https://www.tei-c.org/release/xml/tei/stylesheet/tei.css</xsl:param-->
   <!--xsl:param name="cssPrintFile">https://www.tei-c.org/release/xml/tei/stylesheet/tei-print.css</xsl:param-->

   <xsl:param name="homeURL">https://github.com/clarin-eric/PressMint</xsl:param>
   <xsl:param name="homeLabel">PressMint</xsl:param>

   <xsl:param name="STDOUT">true</xsl:param>
   <!--xsl:param name="STDOUT">false</xsl:param>
   <xsl:param name="outputDir">../docs</xsl:param>
   <xsl:param name="outputName">parla-clarin</xsl:param-->
   
   <!-- Split does not work - produces only top level file!?! -->
   <xsl:param name="splitLevel">-1</xsl:param>
   
   <xsl:param name="autoToc">false</xsl:param>
   <xsl:param name="tocFront">false</xsl:param>
   <xsl:param name="tocBack">true</xsl:param>
   <xsl:param name="tocDepth">4</xsl:param>
   <xsl:param name="subTocDepth">5</xsl:param>
   <xsl:param name="numberFigures"/>
   <xsl:param name="footnoteBackLink">true</xsl:param>
   <xsl:param name="autoEndNotes">true</xsl:param>   
   <xsl:param name="outputEncoding">utf-8</xsl:param>

   <xsl:param name="copyrightStatement"><a href="https://creativecommons.org/licenses/by/4.0/">CC BY 4.0</a></xsl:param>


   <xsl:template match="tei:head">
      <!-- Determine section ID -->
    <xsl:variable name="id">
      <xsl:choose>
        <xsl:when test="../@xml:id"><xsl:value-of select="../@xml:id"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>

    <a class="heading-anchor" href="#{$id}" aria-label="Anchor">⚓</a>

    <!-- TEI’s default heading numbering and content -->
    <xsl:apply-imports/>
  </xsl:template>


  
  <xsl:template match="tei:front">
    <header class="front-header">
        <xsl:apply-templates select="../tei:front/tei:titlePage"/>
    </header>
  
    <aside class="front-sidebar">
        <xsl:apply-templates select="*[not(self::tei:titlePage)]"/>
    </aside>
  </xsl:template>

  <xsl:template match="tei:body">
    <main class="main-text">
        <xsl:apply-templates/>
    </main>
  </xsl:template>

  <xsl:template match="tei:back">
    <footer class="appendix-footer">
        <xsl:apply-templates/>
    </footer>
  </xsl:template>
</xsl:stylesheet>
