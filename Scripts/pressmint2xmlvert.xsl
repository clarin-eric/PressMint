<?xml version="1.0"?>
<!-- Transform one PressMint file to CQP vertical format.
     Note that the output is still in XML, and needs another polish. -->
<!-- Needs the file with corpus teiHeader as the value of the "meta" parameter (cf. pressmint-lib.xsl) -->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" 
    xmlns:et="http://nl.ijs.si/et"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    exclude-result-prefixes="fn et tei xs xi"
    version="2.0">

  <xsl:import href="pressmint-lib.xsl"/>
  
  <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>

  <!-- Do we want the syntactic dependency and head attributes? -->
  <xsl:param name="nosyntax">true</xsl:param>

  <!-- This is inserted via the registry file, so image URLs have to be without this prefix -->
  <xsl:param name="url_template">https://nl.ijs.si/inz/speriodika/</xsl:param>
  
  <xsl:template match="@*"/>
  <xsl:template match="text()"/>
  <xsl:template match="tei:*">
    <xsl:message>
      <xsl:text>WARN: unexpected element </xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:value-of select="concat(' in ', ancestor::tei:TEI/@xml:id, ' : ', @xml:id)"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="tei:TEI">
    <xsl:message select="concat('INFO: Converting ', @xml:id, ' to vertical')"/>
    <xsl:variable name="lang-code" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
    <xsl:variable name="lang" select="et:l10n($corpus-language, 
                                       $rootHeader//tei:langUsage/tei:language[@ident = $lang-code])"/>
    <xsl:variable name="bibl" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl"/>
    <xsl:variable name="date" select="$bibl/tei:date/@when"/>
    <xsl:variable name="year" select="replace($date, '-.+', '')"/>
    <xsl:variable name="newspaper" select="$bibl/tei:title[@level='j']"/>
    <xsl:variable name="article" select="$bibl/tei:title[@level='a']"/>
    <xsl:variable name="publisher" select="$bibl/tei:publisher"/>
    <xsl:variable name="volume" select="$bibl/tei:biblScope[@unit='volume']"/>
    <xsl:variable name="issue" select="$bibl/tei:biblScope[@unit='issue']"/>
    <xsl:variable name="urn" select="$bibl/tei:idno[@type='URN']"/>
    <xsl:variable name="url" select="$bibl/tei:idno[@type='URI']"/>
    <text id="{$text_id}" lang="{$lang}" date="{$date}" year="{$year}"
          newspaper="{$newspaper}" publisher="{$publisher}" source_url="{$url}">
      <xsl:if test="normalize-space($article)">
        <xsl:attribute name="article" select="$article"/>
      </xsl:if>
      <xsl:if test="normalize-space($volume)">
        <xsl:attribute name="volume" select="$volume"/>
      </xsl:if>
      <xsl:if test="normalize-space($issue)">
        <xsl:attribute name="issue" select="$issue"/>
      </xsl:if>
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates  select="tei:text//tei:p"/>
    </text>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:p">
    <xsl:variable name="p_id" select="replace(@xml:id, '\.ana', '')"/>
    <xsl:variable name="lang-code" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
    <xsl:variable name="lang" select="et:l10n($corpus-language, 
                                       $rootHeader//tei:langUsage/tei:language[@ident = $lang-code])"/>
    <xsl:variable name="img-url" select="key('idr', preceding::tei:pb[1]/@facs)/tei:graphic/@url"/>
    <xsl:variable name="img-ref" select="replace($img-url, $url_template, '')"/>
    <xsl:variable name="quality" select="et:l10n($corpus-language, key('idr', @ana, $rootHeader)/tei:catDesc)"/>
    <p id="{$p_id}" lang="{$lang}" quality="{$quality}" image="{$img-ref}">
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates/>
    </p>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:pb"/>
  
  <!-- Conflate head, note into <note> -->
  <xsl:template match="tei:head | tei:note">
    <note>
      <xsl:attribute name="type">
        <xsl:choose>
          <xsl:when test="self::tei:head">head</xsl:when>
          <xsl:when test="self::tei:note[@type]">
            <xsl:value-of select="@type"/>
          </xsl:when>
          <xsl:when test="self::tei:note">-</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat(name(), ':-')"/> 
          </xsl:otherwise>        
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="content">
        <!-- Remove backslashes as these are used for quoting in CQL + quote quotes -->
        <xsl:value-of select="normalize-space(
                              replace(., '\\', '')
                              )"/>
      </xsl:attribute>
    </note>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:s">
    <xsl:copy>
      <xsl:attribute name="id" select="@xml:id"/>
      <xsl:text>&#10;</xsl:text>
      <xsl:apply-templates/>
    </xsl:copy>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="tei:name">
    <xsl:choose>
      <xsl:when test="ancestor::tei:name">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@type"/>
          <xsl:text>&#10;</xsl:text>
          <xsl:apply-templates/>
        </xsl:copy>
        <xsl:text>&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:linkGrp"/>
  
  <!-- We have do deal with syntactic or normalised words, e.g.:

  <w xml:id="u1.p1.s1.w18">abych
    <w xml:id="u1.p1.s1.w19" lemma="aby" msd="UPosTag=SCONJ" norm="aby"/>
    <w xml:id="u1.p1.s1.w20" lemma="být" msd="UPosTag=AUX|Mood=Cnd" norm="bych"/>
  </w>

  <link ana="ud-syn:punct" target="#u1.p1.s1.w21 #u1.p1.s1.w17"/>
  <link ana="ud-syn:mark"  target="#u1.p1.s1.w21 #u1.p1.s1.w19"/>
  <link ana="ud-syn:aux"   target="#u1.p1.s1.w21 #u1.p1.s1.w20"/>

  Solution:
  - introduce normalised column (multi valued)
  - make all attributes multivalued 

  In theory there is also:
    <w norm="najlepši" lemma="lep">
      <w>nar</w>
      <w>lepši</w>
    </w>
   We do not cover this case!
  -->

  <!-- TOKENS -->
  <xsl:template match="tei:pc | tei:w">
    <!-- Output token -->
    <xsl:value-of select="concat(normalize-space(.),'&#9;')"/>
    <xsl:choose>
      <!-- For normalized words e.g.
        <w xml:id="u1.p1.s1.w18">abych
         <w xml:id="u1.p1.s1.w19" lemma="aby" msd="UPosTag=SCONJ" norm="aby"/>
         <w xml:id="u1.p1.s1.w20" lemma="být" msd="UPosTag=AUX|Mood=Cnd" norm="bych"/>
        </w>
      -->
      <xsl:when test="normalize-space(text()[1]) and (tei:w or tei:pc)">
        <xsl:variable name="norms">
          <xsl:for-each select="tei:w | tei:pc">
            <xsl:value-of select="@norm"/>
            <xsl:text>|</xsl:text>
          </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="concat(replace($norms, '\|$', ''),'&#9;')"/>
        <xsl:variable name="toks">
          <xsl:for-each select="tei:w | tei:pc">
            <list>
              <xsl:for-each select="tokenize(et:output-annotations(.), '&#9;')">
                <item>
                  <xsl:value-of select="."/>
                </item>
              </xsl:for-each>
            </list>
          </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="et:join-annotations($toks)"/>
        <xsl:if test="not(normalize-space($nosyntax))">
          <xsl:variable name="deps">
            <xsl:for-each select="tei:w | tei:pc">
              <list>
                <xsl:variable name="annots">
                  <xsl:call-template name="deps">
                    <xsl:with-param name="id" select="@xml:id"/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:for-each select="tokenize($annots, '&#9;')">
                  <item>
                    <xsl:value-of select="."/>
                  </item>
                </xsl:for-each>
              </list>
            </xsl:for-each>
          </xsl:variable>
          <xsl:text>&#9;</xsl:text>
          <xsl:value-of select="et:join-annotations($deps)"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(., '&#9;', et:output-annotations(.))"/>
        <xsl:if test="not(normalize-space($nosyntax))">
          <xsl:text>&#9;</xsl:text>
          <xsl:call-template name="deps"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#10;</xsl:text>
    <xsl:if test="@join = 'right' or @join='both' or
                  following::tei:*[self::tei:w or self::tei:pc][1]/@join = 'left' or
                  following::tei:*[self::tei:w or self::tei:pc][1]/@join = 'both'">
      <g/>
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- NAMED TEMPLATES -->

  <xsl:template name="deps">
    <xsl:param name="type">UD-SYN</xsl:param>
    <xsl:param name="id" select="@xml:id"/>
    <xsl:variable name="s" select="ancestor::tei:s"/>
    <xsl:choose>
      <xsl:when test="$s/tei:linkGrp[@type=$type]">
        <!-- We need to take only the first link, in case of errros in linkGrp (two links with same token in FI) -->
        <xsl:variable name="link"
                      select="$s/tei:linkGrp[@type=$type]/tei:link
                              [ends-with(@target, concat(' #', $id))][1]"/>
        <xsl:choose>
          <xsl:when test="not(normalize-space($link/@ana))">
            <xsl:message>
              <xsl:text>ERROR: no syntactic link for token </xsl:text>
              <xsl:value-of select="concat(ancestor::tei:TEI/@xml:id, ':', @xml:id)"/>
            </xsl:message>
            <xsl:text>-&#9;-&#9;-&#9;-&#9;-</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <!-- Syntactic relation is the English term in the UD-SYN taxonomy -->
            <xsl:variable name="relation" select="substring-after($link/@ana, ':')"/>
            <xsl:value-of select="et:l10n($corpus-language, key('id', $relation, $rootHeader)/tei:catDesc)/tei:term"/>
            <xsl:variable name="target" select="key('id', replace($link/@target,'#(.+?) #.*', '$1'))"/>
            <xsl:choose>
              <xsl:when test="$target/self::tei:s">
                <xsl:text>&#9;-&#9;-&#9;-&#9;-</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('&#9;', et:output-annotations($target))"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>ERROR: no linkGroup for sentence </xsl:text>
          <xsl:value-of select="ancestor::tei:s/@xml:id"/>
        </xsl:message>
        <xsl:text>&#9;-&#9;-&#9;-&#9;-</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
