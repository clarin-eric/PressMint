<?xml version='1.0' encoding='UTF-8'?>
<!-- Xtra validation of PressMint corpus -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  exclude-result-prefixes="tei xi">

  <xsl:import href="pressmint-lib.xsl"/>
  
  <xsl:output method="text"/>

  <xsl:variable name="fileName" select="replace(base-uri(), '^.*?([^/]+\.xml)$', '$1')"/>
  <xsl:variable name="id" select="/tei:*/@xml:id"/>
  <xsl:variable name="idTemplate" select="'PressMint-[A-Z]{2}(-[A-Z0-9]{1,3})?(-[a-z]{2,3})?'"/>
  
  <!-- Is this an MTed corpus? Set $mt to name of MTed language (or empty, if not) -->
  <xsl:variable name="MT">
    <xsl:if test="matches($id, 'PressMint-[A-Z]{2}(-[A-Z0-9]{1,3})?-[a-z]{2,3}')">
      <xsl:value-of select="replace($id, 'PressMint-[A-Z]{2}(-[A-Z0-9]{1,3})?-([a-z]{2,3}).*', '$2')"/>
    </xsl:if>
  </xsl:variable>
  
  <xsl:variable name="type">
    <xsl:choose>
      <xsl:when test="matches($fileName, concat($idTemplate,'\.ana\.xml$'))">ana</xsl:when>
      <xsl:when test="matches($fileName, concat($idTemplate,'_.+\.ana\.xml$'))">ana</xsl:when>
      <xsl:when test="matches($fileName, concat($idTemplate,'\.xml$'))">txt</xsl:when>
      <xsl:when test="matches($fileName, concat($idTemplate,'_.+\.xml$'))">txt</xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="error">
          <xsl:with-param name="msg" select="concat('Bad filename ', $fileName)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="level">
    <xsl:choose>
      <xsl:when test="matches($fileName, concat($idTemplate,'_'))">component</xsl:when>
      <xsl:when test="matches($fileName, concat($idTemplate,'(\.ana)?\.xml$'))">root</xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="error">
          <xsl:with-param name="msg" select="concat('Bad filename ', $fileName)"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:template match="tei:teiCorpus">
    <xsl:if test="not($fileName = concat($id, '.xml'))">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">teiCorpus/@xml:id does not match filename</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$level != 'root'">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">Wrong ID of teiCorpus</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$type = 'txt' and not(matches($id, $idTemplate))">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">teiCorpus ID should match PressMint-{ISO3166}(-{ISO639})?</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$type = 'ana' and not(matches($id, concat($idTemplate,'\.ana')))">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">teiCorpus ID should match PressMint-{ISO3166}(-{ISO639})?.ana</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="rootHeader">
      <xsl:apply-templates mode="expand" select="//tei:teiHeader"/>
    </xsl:variable>
    <xsl:for-each select="./tei:teiHeader//xi:include">
      <xsl:variable name="incl">
        <xsl:apply-templates mode="expand" select="."/>
      </xsl:variable>
      <xsl:variable name="incl-id"><xsl:value-of select="$incl/tei:*/@xml:id"/></xsl:variable>
      <xsl:variable name="incl-lang"><xsl:value-of select="$incl/tei:*/@xml:lang"/></xsl:variable>
      <xsl:if test="not(@href = concat($incl-id,'.xml'))">
        <xsl:call-template name="error">
          <xsl:with-param name="msg">
            <xsl:value-of select="concat(@href,'/@xml:id=&quot;',$incl-id,'&quot; does not match filename')"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="$incl-lang=''">
        <xsl:call-template name="error">
          <xsl:with-param name="msg">
            <xsl:value-of select="concat(@href,'/@xml:lang is missing')"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>

    </xsl:for-each>
    <xsl:apply-templates select="$rootHeader"/>
  </xsl:template>
  
  <xsl:template match="tei:TEI">
    <xsl:if test="not($fileName = concat($id, '.xml'))">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">TEI/@xml:id does not match filename</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$level != 'component'">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">Wrong TEI ID</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="not(matches($id, concat('^',$idTemplate,'_[0-9]{4}-[01][0-9]-[0123][0-9](-[-a-zA-Z0-9]+)?(\.ana)?$')))">
        <xsl:call-template name="error">
          <xsl:with-param name="msg">
            <xsl:text>TEI ID should match PressMint-{ISO3166}(-{ISO639})?_{YYYY-MM-DD}(-[-a-zA-Z0-9]+)?(\.ana)?</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="matches($id, '_.+_')">
        <xsl:call-template name="error">
          <xsl:with-param name="severity">WARN</xsl:with-param>
          <xsl:with-param name="msg">
            <xsl:text>TEI ID should have only one underscore</xsl:text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates/>
  </xsl:template>
    
  <xsl:template match="tei:titleStmt">
    <xsl:variable name="title" select="tei:title
                                       [ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'en']"/>
    <xsl:variable name="title-prefix">[^ ]+( [^ ]+)? historical newspaper corpus <xsl:value-of select="$idTemplate"/></xsl:variable>
    <xsl:variable name="title-suffix">
      <xsl:choose>
        <xsl:when test="not(/tei:TEI) and $type = 'txt'"> \[PressMint(-[a-z]{2,3})?( SAMPLE)?\]$</xsl:when> <!-- teiHeader context when testing teiCorpus header -->
        <xsl:when test="not(/tei:TEI) and $type = 'ana'"> \[PressMint(-[a-z]{2,3})?\.ana( SAMPLE)?\]$</xsl:when>
        <xsl:when test="/tei:TEI and $type = 'txt'">,? .+ \[PressMint(-[a-z]{2,3})?( SAMPLE)?\]$</xsl:when>
        <xsl:when test="/tei:TEI and $type = 'ana'">,? .+ \[PressMint(-[a-z]{2,3})?\.ana( SAMPLE)?\]$</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="title-pattern" select="concat($title-prefix, $title-suffix)"/>
    <xsl:if test="not(matches($title, $title-pattern))">
      <xsl:call-template name="error">
        <xsl:with-param name="msg" select="concat('Bad title ', $title, 
                                           ' (should match ', $title-pattern, ')')"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:extent">
    <xsl:if test="not(tei:measure[@unit='paragraphs'])">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">Missing extent/measure[@unit='paragraphs'] in titleStmt</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="not(tei:measure[@unit='words'])">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">Missing extent/measure[@unit='words'] in titleStmt</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:sourceDesc/tei:bibl[tei:date]">
    <xsl:variable name="date" select="replace($id, '-+_(\d\d\d\d-\d\d-\d\d).*', '$1')"/>
    <xsl:if test="$date != $id and tei:date/@when != $date">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">sourceDesc//date does not match date in filename</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:idno">
    <xsl:if test="matches(., 'hdl.handle.net') and 
                  not(@type='handle' or @subtype='handle')">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">handle URLs should be idno[@(sub)type='handle']</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:date | tei:time">
    <xsl:if test="not(@when or @from or @to or @ana)">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">Missing temporal or pointing attribute on date</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
    
  <xsl:template match="tei:teiCorpus//tei:classDecl">
    <!-- We don't yet have topics -->
    <!--xsl:if test="not(tei:taxonomy[tei:desc/tei:term = 'Topics'])">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">Missing 'Topics' taxonomy</xsl:with-param>
      </xsl:call-template>
    </xsl:if-->
    <xsl:if test="$type = 'ana'">
      <xsl:if test="not(tei:taxonomy[tei:desc/tei:term = 'Named entities'])">
        <xsl:call-template name="error">
          <xsl:with-param name="msg">Missing 'Named entities' taxonomy</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Check if necessary prefixes are defined -->
  <xsl:template match="tei:teiCorpus//tei:listPrefixDef">
    <!-- Check if Topics have their prefix defined -->
    <!-- We don't yet have topics -->
    <!-- xsl:if test="not(tei:prefixDef[@ident = 'topic'])">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">Missing Topic prefixDef</xsl:with-param>
      </xsl:call-template>
    </xsl:if-->
    <xsl:if test="$type = 'ana'">
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="tei:*[@to &lt; @from]">
    <xsl:call-template name="error">
      <xsl:with-param name="msg">
        <xsl:text>attribute to=</xsl:text>
        <xsl:value-of select="@to"/>
        <xsl:text> is before from=</xsl:text>
        <xsl:value-of select="@from"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- If we have words, at least one of them should have a @join -->
  <xsl:template match="tei:body">
    <xsl:if test="$type = 'ana' and .//tei:w and not(.//tei:w[@join])">
      <xsl:call-template name="error">
        <xsl:with-param name="msg">No w/@join attribute in body</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:w | tei:pc">
    <xsl:if test="@msd and not(starts-with(@msd, 'UPosTag='))">
      <xsl:call-template name="error">
        <xsl:with-param name="msg" select="concat('Token @msd value should start with UPosTag= in ', 
                                           @xml:id)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="text()">
    <xsl:if test="not(parent::tei:p or parent::tei:change) and normalize-space(.)">
      <xsl:if test="not(preceding-sibling::tei:*) and matches(., '^ ')">
        <xsl:call-template name="error">
          <xsl:with-param name="severity">WARN</xsl:with-param>
          <xsl:with-param name="msg" select="concat('Leading space in ', ../name(), ': ', .)"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="not(following-sibling::tei:*) and matches(., ' $')">
        <xsl:call-template name="error">
          <xsl:with-param name="severity">WARN</xsl:with-param>
          <xsl:with-param name="msg" select="concat('Trailing space in ', ../name(), ': ', .)"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="error">
    <xsl:param name="msg">???</xsl:param>
    <xsl:param name="severity">ERROR</xsl:param>
    <xsl:message>
      <xsl:value-of select="$severity"/>
      <xsl:text>&#32;</xsl:text>
      <xsl:value-of select="/tei:*/@xml:id"/>
      <xsl:text>: </xsl:text>
      <xsl:value-of select="$msg"/>
    </xsl:message>
  </xsl:template>
  
</xsl:stylesheet>
