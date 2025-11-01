<?xml version="1.0"?>
<!-- Library of templates for import into other PressMint scripts -->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:mk="http://ufal.mff.cuni.cz/matyas-kopp"
  xmlns:et="http://nl.ijs.si/et"
  exclude-result-prefixes="#all"
  version="2.0">

  <!-- In which language the metadata should be output (where there is a choice)
       Legal values are:
       - xx (language of the corpus or fall-back option)
       - en (English or fall-back option)
  -->
  <xsl:param name="out-lang">xx</xsl:param>
  
  <!-- Filename of corpus root containing the corpus-wide metadata -->
  <xsl:param name="meta"/>

  <!-- Separator for multi-valued attributes in vertical and TSV files; must have only one char! --> 
  <xsl:param name="multi-separator">|</xsl:param>

  <!-- Label for multilingual paragraphs -->
  <!-- Note that this label should be ideally translated into all (or at least those that have multilingual utterances, e.g. UA) 
       the PressMint languages as well, i.e. "mul" should be in their langUsage -->
  <xsl:param name="multilingual-label">Multilingual</xsl:param>
  
  <xsl:param name="corpus-language" select="/tei:*/@xml:lang"/>
  <xsl:param name="text_id" select="replace(/tei:*/@xml:id, '\.ana', '')"/>
  <xsl:param name="country-code" select="replace($text_id, '.*?-([^._]+).*', '$1')"/>
  
  <!-- Key in value of element ID -->
  <xsl:key name="id" match="*" use="@xml:id"/>
  <!-- Key which directly finds local references -->
  <xsl:key name="idr" match="*" use="concat('#', @xml:id)"/>

  <xsl:variable name="component" select="/tei:TEI"/>
  
  <!-- Current date in ISO format -->
  <xsl:variable name="today-iso" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  
  <!-- Date of a corpus component -->
  <xsl:variable name="at-date" select="mk:at-date($component)"/>
  <xsl:function name="mk:at-date">
    <xsl:param name="element"/>
    <xsl:variable name="TEI" select="$element/ancestor-or-self::tei:TEI"/>
    <xsl:variable name="date" select="$TEI/tei:teiHeader//tei:setting/tei:date"/>
    <xsl:if test="not($date/@when)">
      <xsl:message terminate="yes">
        <xsl:text>FATAL ERROR: Can't find TEI date/@when in setting of input file </xsl:text>
        <xsl:value-of select="$TEI/@xml:id"/>
      </xsl:message>
    </xsl:if>
    <xsl:value-of select="$date/@when"/>
  </xsl:function>
  
  <!-- Localised title of a corpus component: subtitle, if exists, otherwise main title -->
  <xsl:variable name="title" select="mk:title($component)"/>
  <xsl:function name="mk:title">
    <xsl:param name="element"/>
    <xsl:variable name="TEI" select="$element/ancestor-or-self::tei:TEI"/>
    <xsl:variable name="titles">
      <xsl:apply-templates mode="expand" select="$TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
    </xsl:variable>
    <xsl:variable name="subtitles" select="et:l10n($corpus-language, $titles/tei:title[@type='sub'])"/>
    <xsl:variable name="main-title" select="et:l10n($corpus-language, $titles/tei:title[@type='main'])"/>
    <xsl:choose>
      <!-- Several subtitles in same language -->
      <xsl:when test="normalize-space($subtitles[2])">
        <xsl:variable name="joined-subtitles">
          <xsl:variable name="j-s">
            <xsl:for-each select="$subtitles/self::tei:*">
              <xsl:value-of select="concat(., $multi-separator)"/>
            </xsl:for-each>
          </xsl:variable>
          <xsl:value-of select="replace($j-s, '.$', '')"/>
        </xsl:variable>
        <xsl:message select="concat('INFO: Joining subtitles: ', $joined-subtitles, ' in ', $TEI/@xml:id)"/>
        <xsl:value-of select="$joined-subtitles"/>
      </xsl:when>
      <xsl:when test="normalize-space($subtitles)">
        <xsl:value-of select="normalize-space($subtitles)"/>
      </xsl:when>
      <xsl:when test="normalize-space($main-title)">
        <!-- Remove [PressMint] stamp -->
        <xsl:value-of select="replace(normalize-space($main-title), '\s*\[.+\]$', '')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="concat('ERROR: cant find title for ', $text_id)"/>
        <xsl:text>-</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:variable name="rootHeader">
    <xsl:choose>
      <xsl:when test="normalize-space($meta)">
        <xsl:if test="not(doc-available($meta))">
          <xsl:message terminate="yes">
            <xsl:text>FATAL ERROR: root document </xsl:text>
            <xsl:value-of select="$meta"/>
            <xsl:text> given as "meta" parameter not found !</xsl:text>
          </xsl:message>
        </xsl:if>
        <xsl:apply-templates mode="expand" select="document($meta)//tei:teiHeader">
          <xsl:with-param name="lang" select="document($meta)/tei:*/@xml:lang"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="/tei:teiCorpus/tei:teiHeader">
        <xsl:apply-templates mode="expand" select="/tei:teiCorpus/tei:teiHeader"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  
  <!-- TEMPLATES WITH SPECIAL MODES -->

  <!-- Copy input element to output but XInclude files and 
       put @xml:lang on all elements; the value is taken from the closest ancestor 
       or given as a parameter if the input does not have ancestor with @xml:lang -->
  <xsl:template mode="expand" match="tei:*">
    <xsl:param name="lang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
    <xsl:variable name="thisLang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
    <xsl:copy>
      <xsl:apply-templates mode="expand" select="@*"/>
      <!-- Copy over language to every element, so we can immediatelly know which langauge it is in -->
      <xsl:attribute name="xml:lang">
        <xsl:choose>
          <xsl:when test="normalize-space($thisLang)">
            <xsl:value-of select="$thisLang"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$lang"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates mode="expand">
        <xsl:with-param name="lang" select="$lang"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="expand" match="xi:include">
    <xsl:param name="lang" select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
    <xsl:apply-templates mode="expand" select="document(@href)">
      <xsl:with-param name="lang" select="$lang"/>
    </xsl:apply-templates>
  </xsl:template>
  <xsl:template mode="expand" match="@*">
    <xsl:copy/>
  </xsl:template>
  <xsl:template mode="expand" match="text()">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- NAMED TEMPLATES -->

  <!-- FUNCTIONS -->

  <!-- Format the name of a person from persName -->
  <xsl:function name="et:format-name">
    <xsl:param name="persName"/>
    <xsl:choose>
      <xsl:when test="$persName/tei:forename[normalize-space(.)] or $persName/tei:surname[normalize-space(.)]">
        <xsl:value-of select="normalize-space(
                              string-join(
                              (
                              string-join(
                                (
                                  $persName/tei:surname[not(@type='patronym')]
                                  |
                                  $persName/tei:nameLink[following-sibling::tei:*[1][local-name()='surname' or local-name()='nameLink']]
                                )/normalize-space(.),
                                ' '),
                              concat(
                              string-join($persName/tei:forename/normalize-space(.),' '),
                              ' ',
                              string-join($persName/tei:surname[@type='patronym']/normalize-space(.),' ')
                              )
                              )[normalize-space(.)],
                              ', ' ))"/>
      </xsl:when>
      <xsl:when test="$persName/tei:term">
        <xsl:value-of select="concat('@', $persName/tei:term, '@')"/>
      </xsl:when>
      <xsl:when test="normalize-space($persName)">
        <xsl:value-of select="$persName"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="concat('ERROR: empty persName for ', $persName/@xml:id)"/>
        <xsl:text>-</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Format number-->
  <xsl:function name="et:format-number" as="xs:string">
    <xsl:param name="lang" as="xs:string"/>
    <xsl:param name="quant"/>
    <xsl:variable name="form" select="format-number($quant, '###,###,###,###')"/>
    <xsl:choose>
      <xsl:when test="$lang = 'fr' or $lang = 'cs'">
        <xsl:value-of select="replace($form, ',', ' ')"/>
      </xsl:when>
      <xsl:when test="$lang = 'bg' or 
                      $lang = 'hr' or
                      $lang = 'hu' or
                      $lang = 'is' or
                      $lang = 'it' or
                      $lang = 'lt' or
                      $lang = 'lv' or
                      $lang = 'pl' or
                      $lang = 'ro' or
                      $lang = 'sl' or
                      $lang = 'tr'
                      ">
        <xsl:value-of select="replace($form, ',', '.')"/>
      </xsl:when>
      <!-- Comma for thousands separator by default -->
      <xsl:otherwise>
        <xsl:value-of select="$form"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Normalize too long or too short dates 
       a la "2013-10-26T14:00:00" or "2018" to xs:date e.g. 2018-01-01 -->
  <!-- If date is empty, returns emptry string -->
  <xsl:function name="et:norm-date">
    <xsl:param name="date"/>
    <xsl:choose>
      <xsl:when test="not(normalize-space($date))"/>
      <xsl:when test="matches($date, '^\d\d\d\d-\d\d-\d\dT.+$')">
        <xsl:value-of select="substring-before($date, 'T')"/>
      </xsl:when>
      <xsl:when test="matches($date, '^\d\d\d\d-\d\d-\d\d$')">
        <xsl:value-of select="$date"/>
      </xsl:when>
      <xsl:when test="matches($date, '^\d\d\d\d-\d\d$')">
        <xsl:message>
          <xsl:text>WARN: short date </xsl:text>
          <xsl:value-of select="$date"/>
        </xsl:message>
        <xsl:value-of select="concat($date, '-01')"/>
      </xsl:when>
      <xsl:when test="matches($date, '^\d\d\d\d$')">
        <!--xsl:message>
          <xsl:text>WARN: short date </xsl:text>
          <xsl:value-of select="$date"/>
        </xsl:message-->
        <xsl:value-of select="concat($date, '-01-01')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:text>ERROR: bad date </xsl:text>
          <xsl:value-of select="$date"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Output $toks as multivalued columns -->
  <xsl:function name="et:join-annotations">
    <xsl:param name="toks"/>
    <xsl:variable name="last" select="count($toks/tei:list)"/>
    <xsl:variable name="result">
      <!-- Counter through items -->
      <xsl:for-each select="$toks/tei:list[1]/tei:item">
        <xsl:variable name="i" select="position()"/>
        <xsl:variable name="feat">
          <xsl:for-each select="$toks/tei:list/tei:item[position() = $i]">
            <xsl:value-of select="."/>
            <xsl:text>|</xsl:text>
          </xsl:for-each>
        </xsl:variable>
        <!-- Snip off last | and remove duplicates (works only for 2 norm words) -->
        <xsl:value-of select="replace(
                              replace($feat, '\|$', ''),
                              '^(.+?)\|\1$', '$1')
                              "/>
        <xsl:text>&#9;</xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="replace($result, '&#9;$', '')"/>
  </xsl:function>
    
  <xsl:function name="et:output-annotations">
    <xsl:param name="token"/>
    <xsl:variable name="n" select="replace($token/@xml:id, '.+\.([^.]+)$', '$1')"/>
    <xsl:variable name="lemma">
      <xsl:choose>
        <xsl:when test="$token/@lemma">
          <xsl:value-of select="$token/@lemma"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring($token,1,1)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="ud-pos">
      <xsl:choose>
        <xsl:when test="$token/@msd">
          <xsl:value-of select="replace(replace($token/@msd, 'UPosTag=', ''), '\|.+', '')"/>
        </xsl:when>
        <xsl:otherwise>-</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="ud-feats">
      <xsl:variable name="fs" select="replace($token/@msd, 'UPosTag=[^|]+\|?', '')"/>
      <xsl:choose>
        <xsl:when test="normalize-space($fs)">
          <!-- Change source pipe to whatever we have for multivalued attributes -->
          <xsl:value-of select="replace($fs, '\|', ' ')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>-</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="concat($lemma, '&#9;', $ud-pos, '&#9;', $ud-feats, '&#9;')"/>
  </xsl:function>

  <!-- Output the sibling element in $elements that is appropriate for output language (global $out-lang)
       The asssumption is that all elements in $elements have @xml:lang, i.e. have been processed with XInclude mode
  -->
  <xsl:function name="et:l10n">
    <xsl:param name="lang"/>
    <xsl:param name="elements"/>
    <!-- Should never happen, as all meta elements should be marked for @xml:lang -->
    <xsl:if test="$elements[not(@xml:lang)]">
      <xsl:message terminate="yes" select="concat('FATAL ERROR: no @xml:lang at least in ', 
                                           $elements[not(@xml:lang)][1])"/>
    </xsl:if>
    <!--xsl:message select="concat('DEBUG: out-lang = ', $out-lang, ', corpus language = ', $lang)"/-->
    <!-- Original language -->
    <xsl:variable name="element-xx" select="$elements[@xml:lang = $lang]"/>
    <!-- Latin spelling -->
    <xsl:variable name="element-lt" select="$elements[ends-with(@xml:lang, '-Latn')]"/>
    <!-- English -->
    <xsl:variable name="element-en" select="$elements[@xml:lang = 'en']"/>
    <!-- For (the only example in PressMint) the French spelling of a name in GR. -->
    <!-- Note that corpus-language can be "en" for MTed corpora, so we need to choose only one result -->
    <xsl:variable name="element-yy" select="$elements[not(@xml:lang = 'en' or
                                            @xml:lang = $lang or ends-with(@xml:lang, '-Latn'))][1]"/>
    <!-- If nothing else serves we take first element as fall-back -->
    <xsl:variable name="element-fb" select="$elements[1]"/>
    <xsl:choose>
      <xsl:when test="$out-lang = 'xx'">
        <xsl:choose>
          <xsl:when test="normalize-space($element-xx[1])">
            <xsl:copy-of select="$element-xx"/>
          </xsl:when>
          <xsl:when test="normalize-space($element-lt[1])">
            <xsl:copy-of select="$element-lt"/>
          </xsl:when>
          <xsl:when test="normalize-space($element-yy[1])">
            <xsl:copy-of select="$element-yy"/>
          </xsl:when>
          <xsl:when test="normalize-space($element-en[1])">
            <xsl:copy-of select="$element-en"/>
          </xsl:when>
          <xsl:when test="normalize-space($element-fb[1])">
            <xsl:copy-of select="$element-fb"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- It is legitimate to get an empty $elements! -->
            <xsl:text></xsl:text>
            <!--xsl:message select="concat('ERROR: l10n cant find element in given parameter elements: ', 
                                 $elements[1]/name(), ' / ', $elements)"/-->
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$out-lang = 'en'">
        <xsl:choose>
          <xsl:when test="normalize-space($element-en[1])">
            <xsl:copy-of select="$element-en"/>
          </xsl:when>
          <xsl:when test="normalize-space($element-lt[1])">
            <xsl:copy-of select="$element-lt"/>
          </xsl:when>
          <xsl:when test="normalize-space($element-yy[1])">
            <xsl:copy-of select="$element-yy"/>
          </xsl:when>
          <xsl:when test="normalize-space($element-fb[1])">
            <xsl:copy-of select="$element-fb"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- It is legitimate to get an empty $elements! -->
            <xsl:text></xsl:text>
            <!--xsl:message select="concat('ERROR: l10n cant find element in given parameter elements for language ', 
                                 $out-lang, ' and element ', $elements/name(), ':', $elements)"/-->
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes"
                     select="concat('FATAL ERROR: parameter out-lang should be xx or en, not ',
                             '&quot;', $out-lang, '&quot;')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Return value of $input, if it exists, otherwise '-' -->
  <xsl:function name="et:tsv-value">
    <xsl:param name="input"/>
    <xsl:choose>
      <xsl:when test="normalize-space($input)">
        <xsl:value-of select="normalize-space($input)"/>
      </xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
