<?xml version="1.0"?>
<!-- Takes root file as input, and outputs fixed root and all component files to outDir.
     Input is "plain text" (.TEI) or lingustically analysed (.TEI.ana) corpus root file.
     Output is the corresponding .TEI or .TEI.ana in their final form for a particular release.
     The inserted or fixed data is either given as parameters with default values or 
     computed from the corpus.
     STDERR gives a detailed log of actions.
     The program:
     - sets current date as release date
     - sets version and handles
     - sets correct top level ID so it is the same as filename
     - sets title PressMint stamp
     - sets PressMint English projectDesc
     - gives correct type and subtype to idno
     - calculates paragraph and word extents
     - calculates tagUsage
     - removes spurious spaces
     - sorts XIncluded component files
-->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:et="http://nl.ijs.si/et" 
  xmlns:mk="http://ufal.mff.cuni.cz/matyas-kopp"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xsl tei et mk xs xi"
  version="2.0">

  <xsl:import href="pressmint-lib.xsl"/>
  
  <!-- Directories must have absolute paths! -->
  <xsl:param name="outDir">.</xsl:param>
  <xsl:param name="anaDir">.</xsl:param>
  <xsl:param name="outHeaderDir">.</xsl:param>
  <xsl:param name="anaHeaderDir">.</xsl:param>

  <!-- We give fake values here, the calling program should set these parameters! -->
  <xsl:param name="version">0.1</xsl:param>
  <xsl:param name="handle-txt">http://hdl.handle.net/11356/XXXX</xsl:param>
  <xsl:param name="handle-ana">http://hdl.handle.net/11356/YYYY</xsl:param>

  <!-- parameters for partial processing, root file is processed after processing the last component file -->
  <xsl:param name="chunkStart">0</xsl:param>
  <xsl:param name="chunkSize">0</xsl:param> <!-- 0 means process all -->

  <!-- Is this a linguistically annotated (ana) or plain text corpus (txt)? -->
  <xsl:param name="type">
    <xsl:choose>
      <xsl:when test="contains(/tei:teiCorpus/@xml:id, '.ana')">ana</xsl:when>
      <xsl:otherwise>txt</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="country-code" select="replace(/tei:teiCorpus/@xml:id, 
                                         '.*?-([^._]+).*', '$1')"/>
  <xsl:param name="country-name" select="replace(/tei:teiCorpus/tei:teiHeader/
                                         tei:fileDesc/tei:titleStmt/
                                         tei:title[@type='main' and @xml:lang='en'],
                                         '([^ ]+) .*', '$1')"/>

  <!-- Is this an MTed corpus? $mt should be name of MTed language, or empty, if original corpus -->
  <xsl:param name="mt">
    <xsl:if test="matches($country-code, '-[a-z]{2,3}$')">
      <xsl:value-of select="replace($country-code, '.+-([a-z]{2,3})$', '$1')"/>
    </xsl:if>
  </xsl:param>
  
  <xsl:output method="xml" indent="yes"/>
  <xsl:preserve-space elements="catDesc p"/>

  <!-- GOBAL VARIABLES -->
  
  <!-- Project description for PressMint II -->
  <xsl:variable name="projectDesc-en">
    <p xml:lang="en"><ref target="https://www.clarin.eu/pressmint">PressMint</ref> is a
    project that aims to (1) create a multilingual set of corpora of historical newspapers
    uniformly encoded according to the
    <ref target="https://clarin-eric.github.io/PressMint/">PressMint encoding guidelines</ref>;
    (2) add linguistic annotations to the corpora; and (3) make the corpora available through
    concordancers.</p>
  </xsl:variable>
  
  <!-- Input directory -->
  <xsl:variable name="inDir" select="replace(base-uri(), '(.*)/.*', '$1')"/>
  <!-- The name of the corpus directory to output to, i.e. "PressMint-XX" -->
  <xsl:variable name="corpusDir" select="replace(base-uri(), 
                                         '.*?([^/]+)/[^/]+\.[^/]+$', '$1')"/>

  <xsl:variable name="today" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  <xsl:variable name="outRoot">
    <xsl:value-of select="$outDir"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="$corpusDir"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="replace(base-uri(), '.*/(.+)$', '$1')"/>
  </xsl:variable>

  <!-- Gather URIs of XIncluded files map to new URIs incl. .ana files -->
  <xsl:variable name="docs">
    <xsl:for-each select="//xi:include">
      <item>
	<xsl:attribute name="type">
	  <xsl:choose>
	    <xsl:when test="ancestor::tei:teiHeader">factorised</xsl:when>
	    <xsl:otherwise>component</xsl:otherwise>
	  </xsl:choose>
	</xsl:attribute>
        <xsl:attribute name="position" select="position()"/>
        <xi-orig>
          <xsl:value-of select="@href"/>
        </xi-orig>
        <url-orig>
          <xsl:value-of select="concat($inDir, '/', @href)"/>
        </url-orig>
        <url-new>
          <xsl:value-of select="concat($outDir, '/', $corpusDir, '/', @href)"/>
        </url-new>
	<xsl:if test="not(ancestor::tei:teiHeader)">
          <url-ana>
            <xsl:value-of select="concat($anaDir, '/')"/>
	    <xsl:choose>
              <xsl:when test="$type = 'ana'">
		<xsl:value-of select="@href"/>
	      </xsl:when>
              <xsl:when test="$type = 'txt'">
		<xsl:value-of select="replace(@href, '\.xml', '.ana.xml')"/>
	      </xsl:when>
	    </xsl:choose>
          </url-ana>
          <url-ana-header>
            <xsl:value-of select="concat($anaHeaderDir, '/')"/>
            <xsl:choose>
              <xsl:when test="$type = 'ana'">
	        <xsl:value-of select="replace(@href, '\.ana\.xml', '.ana.header.xml')"/>
	      </xsl:when>
              <xsl:when test="$type = 'txt'">
	        <xsl:value-of select="replace(@href, '\.xml', '.ana.header.xml')"/>
	      </xsl:when>
	    </xsl:choose>
          </url-ana-header>
          <url-header>
            <xsl:value-of select="concat($outHeaderDir, '/', replace(@href, '\.xml', '.header.xml'))"/>
          </url-header>
        </xsl:if>
      </item>
    </xsl:for-each>
  </xsl:variable>
  
  <!-- docs to process in chunk -->
  <xsl:variable name="docsChunk">
  <xsl:message select="concat('INFO: Processing chunk from ', $chunkStart, ' to ', $chunkStart + $chunkSize)"/>
    <xsl:copy-of select="$docs//tei:item[mk:in-chunk(@position)]"/>  
  </xsl:variable>
  <!--
  <xsl:variable name="lastChunk" 
                select="$docsChunk//tei:item[last()]/@position = count($docs//tei:item)"/> -->
  <xsl:variable name="lastChunk" 
                select="$docs//tei:item[last()]/mk:in-chunk(@position)"/>
  <xsl:function name="mk:in-chunk" as="xs:boolean">
    <xsl:param name="position"/>
    <xsl:sequence select="if 
                          (xs:integer($position) gt xs:integer($chunkStart) and (xs:integer($position) le $chunkStart + $chunkSize or $chunkSize = 0)) 
                          then true() 
                          else false()"/>
  </xsl:function>

  <!-- Numbers of words in component files -->
  <xsl:variable name="words">
    <xsl:variable name="id" select="tei:teiCorpus/@xml:id"/>
    <xsl:for-each select="$docs/tei:item[@type = 'component' and ($lastChunk or mk:in-chunk(@position))]">
      <item n="{tei:xi-orig}">
        <xsl:choose>
          <!-- For .ana files, compute number of words -->
          <xsl:when test="$type = 'ana'">
            <xsl:choose>
              <xsl:when test="doc-available(tei:url-header) and
                              document(tei:url-header)//tei:extent/tei:measure[@unit='words']">
                <xsl:message select="concat('INFO: Using words from component header file ', replace(tei:url-header,'.*/',''))"/>
                <xsl:value-of select="document(tei:url-header)//tei:extent/tei:measure[@unit='words'][1]/@quantity"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="document(tei:url-orig)/
                                      count(//tei:w[not(parent::tei:w)])"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <!-- For plain files, take number of words from .ana.header files -->
          <xsl:when test="doc-available(tei:url-ana-header) and document(tei:url-ana-header)//tei:extent/tei:measure[@unit='words']">
            <xsl:message select="concat('INFO: Using words from ana-header file ', replace(tei:url-ana-header,'.*/',''))"/>
            <xsl:value-of select="document(tei:url-ana-header)//tei:extent/tei:measure[@unit='words'][1]/@quantity"/>
          </xsl:when>
          <!-- For plain files, take number of words from .ana files -->
          <xsl:when test="doc-available(tei:url-ana)">
            <xsl:value-of select="document(tei:url-ana)/
                                  count(//tei:w[not(parent::tei:w)])"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message select="concat('ERROR ', $id, 
                                   ': cannot locate .ana file ', tei:url-ana, 
				   ', extents will not be set in TEI!')"/>
              <xsl:value-of select="number('0')"/>
            </xsl:otherwise>
          </xsl:choose>
        </item>
      </xsl:for-each>
  </xsl:variable>
  
  <!-- Numbers of paragraphs in component files -->
  <xsl:variable name="paragraphs">
    <xsl:for-each select="$docs/tei:item[@type = 'component' and ($lastChunk or mk:in-chunk(@position))]">
      <item n="{tei:xi-orig}">
        <xsl:choose>
          <xsl:when test="doc-available(tei:url-header)">
            <xsl:message select="concat('INFO: Using paragraphs from header file ', replace(tei:url-header,'.*/',''))"/>
            <xsl:value-of select="document(tei:url-header)//tei:extent/tei:measure[@unit='paragraphs'][1]/@quantity"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- We don't count paragraphs in teiHeader! -->
            <xsl:value-of select="document(tei:url-orig)/count(//tei:text/tei:p)"/>
          </xsl:otherwise>
        </xsl:choose>
      </item>
    </xsl:for-each>
  </xsl:variable>

  <!-- Calculated tagUsages in component files -->
  <xsl:variable name="tagUsages">
    <xsl:for-each select="$docs/tei:item[@type = 'component' and ($lastChunk or mk:in-chunk(@position))]">
      <item n="{tei:xi-orig}">
        <xsl:variable name="context-node" select="."/>
        <xsl:choose>
          <xsl:when test="doc-available(tei:url-header)">
            <xsl:message select="concat('INFO: Using tagUsage from header file ', replace(tei:url-header,'.*/',''))"/>
            <xsl:copy-of select="document(tei:url-header)//tei:tagUsage"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message select="concat('INFO: Compute tagUsage in ', replace(tei:url-orig,'.*/',''))"/>
            <xsl:for-each select="document(tei:url-orig)/
                                  distinct-values(tei:TEI/tei:text/descendant-or-self::tei:*/name())">
              <xsl:sort select="."/>
              <xsl:variable name="elem-name" select="."/>
              <xsl:element name="tagUsage">
                <xsl:attribute name="gi" select="$elem-name"/>
                <xsl:attribute name="occurs" select="$context-node/document(tei:url-orig)/
                                        count(tei:TEI/tei:text/descendant-or-self::tei:*[name()=$elem-name])"/>
              </xsl:element>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose> 
      </item>
    </xsl:for-each>
  </xsl:variable>

  <!-- TOP LEVEL TEMPLATE -->
  <xsl:template match="/">
    <xsl:message select="concat('INFO: Starting to add common content to ', tei:teiCorpus/@xml:id)"/>
    <!-- Process component files -->
    <xsl:message>
      <xsl:text>INFO Starting to process component files</xsl:text>
      <xsl:if test="xs:integer($chunkSize) = 0 or xs:integer($chunkStart) gt 0">
        <xsl:text> from </xsl:text>
        <xsl:value-of select="$docsChunk//tei:item[1]/@position"/>
        <xsl:text> to </xsl:text>
        <xsl:value-of select="$docsChunk//tei:item[last()]/@position"/> 
      </xsl:if>
    </xsl:message>
    <xsl:for-each select="$docsChunk//tei:item">
      <xsl:variable name="this" select="tei:xi-orig"/>
      <xsl:message select="concat('INFO: Processing [',@position,'] ', $this)"/>
      <xsl:choose>
        <!-- Process factorised parts of corpus root teiHeader as if they were root (to fix spacing) -->
        <xsl:when test="@type = 'factorised'">
          <xsl:result-document href="{tei:url-new}">
            <xsl:apply-templates mode="root" select="document(tei:url-orig)"/>
          </xsl:result-document>
        </xsl:when>
        <!-- Process component -->
        <xsl:when test="@type = 'component'">
          <xsl:variable name="componentContent">
            <xsl:apply-templates mode="comp" select="document(tei:url-orig)/tei:TEI">
              <xsl:with-param name="texts">1</xsl:with-param>
              <xsl:with-param name="paragraphs" select="$paragraphs/tei:item[@n = $this]"/>
              <xsl:with-param name="words" select="$words/tei:item[@n = $this]"/>
              <xsl:with-param name="tagUsages" select="$tagUsages/tei:item[@n = $this]"/>
            </xsl:apply-templates>
          </xsl:variable>
          <xsl:result-document href="{tei:url-new}">
            <xsl:copy-of select="$componentContent"/>
          </xsl:result-document>
          <xsl:result-document href="{tei:url-header}">
            <xsl:apply-templates mode="header" select="$componentContent"/>
          </xsl:result-document>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>

    <xsl:if test="$lastChunk">
      <xsl:text>STATUS: Processed last chunk</xsl:text> <!-- Do not change this message !!! -->
      <!-- Output Root file -->
      <xsl:message>INFO: processing root </xsl:message>
      <xsl:result-document href="{$outRoot}">
        <xsl:apply-templates mode="root"/>
      </xsl:result-document>
    </xsl:if>
  </xsl:template>

  <xsl:template match="* | @*">
    <xsl:message terminate="yes">All templates must have mode comp or root!</xsl:message>
  </xsl:template>
  
  <!-- PROCESSING COMPONENTS -->
  
  <xsl:template mode="comp" match="tei:*">
    <xsl:param name="texts"/>
    <xsl:param name="paragraphs"/>
    <xsl:param name="words"/>
    <xsl:param name="tagUsages"/>
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:apply-templates mode="comp">
        <xsl:with-param name="texts" select="$texts"/>
        <xsl:with-param name="paragraphs" select="$paragraphs"/>
        <xsl:with-param name="words" select="$words"/>
        <xsl:with-param name="tagUsages" select="$tagUsages"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="comp" match="@*">
    <xsl:copy/>
  </xsl:template>

  <xsl:template mode="comp" match="tei:TEI/@xml:id">
    <xsl:variable name="id" select="replace(base-uri(), '^.*?([^/]+)\.xml$', '$1')"/>
    <xsl:attribute name="xml:id" select="$id"/>
    <xsl:if test=". != $id">
      <xsl:message select="concat('WARN ', @xml:id, 
                               ': fixing TEI/@xml:id to ', $id)"/>
    </xsl:if>
  </xsl:template>
  
  <!-- Same as for root -->
  <xsl:template mode="comp" match="tei:teiHeader//text()">
    <xsl:apply-templates mode="root" select="."/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:titleStmt/tei:title">
    <xsl:apply-templates mode="root" select="."/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:publicationStmt">
    <xsl:apply-templates mode="root" select="."/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:idno">
    <xsl:apply-templates mode="root" select="."/>
  </xsl:template>
  <xsl:template mode="comp" match="tei:projectDesc">
    <xsl:apply-templates mode="root" select="."/>
  </xsl:template>
  
  <xsl:template mode="comp" match="tei:titleStmt">
    <xsl:param name="paragraphs"/>
    <xsl:param name="words"/>
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:apply-templates mode="comp"/>
    </xsl:copy>
    <xsl:if test="not(following-sibling::tei:editionStmt)">
      <xsl:message select="concat('WARN ', /tei:*/@xml:id,
                           ': no component editionStmt, inserting with edition ', $version)"/>
      <editionStmt>
        <edition>
          <xsl:value-of select="$version"/>
        </edition>
      </editionStmt>
    </xsl:if>
    <xsl:if test="not(following-sibling::tei:extent)">
      <xsl:message select="concat('WARN ', /tei:*/@xml:id, 
                           ': no component extent, adding extent measures in English only!')"/>
      <extent>
        <measure unit="paragraphs" quantity="{$paragraphs}" xml:lang="en">
          <xsl:value-of select="et:format-number('en', $paragraphs)"/>
          <xsl:text> paragraphs</xsl:text>
        </measure>
        <measure unit="words" quantity="{$words}" xml:lang="en">
          <xsl:value-of select="et:format-number('en', $words)"/>
          <xsl:text> words</xsl:text>
        </measure>
      </extent>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="comp" match="tei:editionStmt">
    <xsl:param name="paragraphs"/>
    <xsl:param name="words"/>
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:if test="$version != tei:edition">
        <xsl:message select="concat('INFO ', /tei:*/@xml:id,
                             ': replacing version ', tei:edition, ' with ', $version)"/>
      </xsl:if>
      <edition>
        <xsl:value-of select="$version"/>
      </edition>
    </xsl:copy>
    <xsl:if test="not(following-sibling::tei:extent)">
      <xsl:message select="concat('WARN ', /tei:*/@xml:id, 
                           ': no component extent, adding extent measures in English only!')"/>
      <extent>
        <measure unit="paragraphs" quantity="{$paragraphs}" xml:lang="en">
          <xsl:value-of select="et:format-number('en', $paragraphs)"/>
          <xsl:text> paragraphs</xsl:text>
        </measure>
        <measure unit="words" quantity="{$words}" xml:lang="en">
          <xsl:value-of select="et:format-number('en', $words)"/>
          <xsl:text> words</xsl:text>
        </measure>
      </extent>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="comp" match="tei:extent/tei:measure[@unit='texts']">
    <xsl:param name="texts"/>
    <xsl:variable name="old-texts" select="@quantity"/>
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:if test="normalize-space($texts) and $texts != '0'">
        <xsl:attribute name="quantity" select="$texts"/>
        <xsl:if test="$old-texts != $texts">
          <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                               ': replacing texts ', $old-texts, ' with ', $texts)"/>
        </xsl:if>
        <xsl:value-of select="replace(., '.+ ', concat(
                              et:format-number(ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang, $texts), 
                              ' '))"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>  

  <xsl:template mode="comp" match="tei:extent/tei:measure[@unit='paragraphs']">
    <xsl:param name="paragraphs"/>
    <xsl:variable name="old-paragraphs" select="@quantity"/>
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:if test="normalize-space($paragraphs) and $paragraphs != '0'">
        <xsl:attribute name="quantity" select="$paragraphs"/>
        <xsl:if test="$old-paragraphs != $paragraphs">
          <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                               ': replacing paragraphs ', $old-paragraphs, ' with ', $paragraphs)"/>
        </xsl:if>
        <xsl:value-of select="replace(., '.+ ', concat(
                              et:format-number(ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang, $paragraphs), 
                              ' '))"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>  

  <xsl:template mode="comp" match="tei:extent/tei:measure[@unit='words']">
    <xsl:param name="words"/>
    <xsl:variable name="old-words" select="@quantity"/>
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:if test="normalize-space($words) and $words != '0'">
        <xsl:attribute name="quantity" select="$words"/>
        <xsl:if test="$old-words != $words">
          <xsl:message select="concat('INFO ', /tei:*/@xml:id,
                               ': replacing words ', $old-words, ' with ', $words)"/>
        </xsl:if>
        <xsl:value-of select="replace(., '.+ ', concat(
                            et:format-number(ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang, $words),
                            ' '))"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>  

  <xsl:template mode="comp" match="tei:encodingDesc">
    <xsl:param name="tagUsages"/>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:apply-templates mode="comp" select="./tei:projectDesc"/>
      <xsl:apply-templates mode="comp" select="./tei:editorialDecl"/>
      <xsl:call-template name="add-tagsDecl">
        <xsl:with-param name="tagUsages" select="$tagUsages"/>
      </xsl:call-template>
      <xsl:apply-templates mode="comp" select="./tei:classDecl"/>
      <xsl:apply-templates mode="comp" select="./tei:listPrefixDef"/>
      <xsl:apply-templates mode="comp" select="./tei:appInfo"/>
    </xsl:copy>
  </xsl:template>

  <!-- Silently give IDs to paragraphs without them -->
  <xsl:template mode="comp" match="tei:p[not(@xml:id)]">
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:attribute name="xml:id">
        <xsl:value-of select="ancestor::tei:TEI/@xml:id"/>
        <xsl:text>.p</xsl:text>
        <xsl:number level="any" from="tei:text"/>
      </xsl:attribute>
      <xsl:apply-templates mode="comp"/>
    </xsl:copy>
  </xsl:template>
      
  <!-- Silently give IDs to some elements -->
  <xsl:template mode="comp" match="tei:head[not(@xml:id)] | 
				   tei:gap[not(@xml:id)] |
				   tei:note[not(@xml:id)]">
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:attribute name="xml:id">
	<xsl:value-of select="ancestor::tei:TEI/@xml:id"/>
        <xsl:text>.</xsl:text>
	<xsl:value-of select="name()"/>
        <xsl:number level="any" from="text"/>
      </xsl:attribute>
      <xsl:apply-templates mode="comp"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- FILTERING COMPONENTS - HEADER -->
  <xsl:template mode="header" match="/tei:TEI/tei:text"/>
  <xsl:template mode="header" match="*">
    <xsl:copy>
      <xsl:apply-templates mode="header" select="@*"/>
      <xsl:apply-templates mode="header"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="header" match="@*">
    <xsl:copy/>
  </xsl:template>  

  <!-- PROCESSING ROOT -->
  
  <xsl:template mode="root" match="*">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:apply-templates mode="root"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="root" match="@*">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template mode="root" match="tei:teiCorpus">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:apply-templates mode="root" select="tei:*"/>
      <xsl:for-each select="xi:include">
        <xsl:sort select="@href"/>
        <xsl:copy-of select="."/>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="root" match="tei:teiCorpus/@xml:id">
    <xsl:variable name="id" select="replace(base-uri(), '^.*?([^/]+)\.xml$', '$1')"/>
    <xsl:attribute name="xml:id" select="$id"/>
    <xsl:if test=". != $id">
      <xsl:message select="concat('WARN ', @xml:id, 
                               ': fixing teiCorpus/@xml:id to ', $id)"/>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="root" match="tei:titleStmt">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:apply-templates mode="root"/>
    </xsl:copy>
    <xsl:if test="not(following-sibling::tei:editionStmt)">
      <xsl:message select="concat('WARN ', /tei:*/@xml:id,
                           ': no root editionStmt, inserting with edition ', $version)"/>
      <editionStmt>
        <edition>
          <xsl:value-of select="$version"/>
        </edition>
      </editionStmt>
      <xsl:if test="not(following-sibling::tei:extent)">
        <xsl:message select="concat('WARN ', /tei:teiCorpus/@xml:id, 
                             ': no root extent, adding extent measures in English only!')"/>
        <extent>
  	  <xsl:call-template name="add-measure">
	    <xsl:with-param name="unit">texts</xsl:with-param>
	  </xsl:call-template>
	  <xsl:call-template name="add-measure">
	    <xsl:with-param name="unit">paragraphs</xsl:with-param>
	  </xsl:call-template>
	  <xsl:call-template name="add-measure">
	    <xsl:with-param name="unit">words</xsl:with-param>
	  </xsl:call-template>
        </extent>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <!-- Check main title if it has the correct stamp, and replace if not -->
  <xsl:template mode="root" match="tei:titleStmt/tei:title">
    <xsl:variable name="okStamp">
      <xsl:text>[PressMint</xsl:text>
      <xsl:if test="normalize-space($mt)">
	<xsl:value-of select="concat('-', $mt)"/>
      </xsl:if>
      <xsl:if test="$type = 'ana'">.ana</xsl:if>
      <xsl:text>]</xsl:text>
    </xsl:variable>
    <xsl:variable name="oldStamp" select="replace(substring-after(., '['), '\]$', '')"/>
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:choose>
	<xsl:when test="$oldStamp = $okStamp">
	  <xsl:value-of select="normalize-space(.)"/>
	</xsl:when>
	<xsl:when test="not($oldStamp)">
          <xsl:message select="concat('INFO ', /tei:TEI/@xml:id, 
                               ': adding title stamp ', $okStamp)"/>
	  <xsl:value-of select="concat(normalize-space(.), ' ', $okStamp)"/>
	</xsl:when>
	<xsl:otherwise>
          <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                               ': replacing title stamp ', $oldStamp, ' with ', $okStamp)"/>
	  <xsl:value-of select="replace(., '(.+?)\s*\[.+\]$', concat('$1', ' ', $okStamp))"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="root" match="tei:extent">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:if test="not(tei:measure[@unit='text'])">
	<xsl:message select="concat('WARN ', /tei:teiCorpus/@xml:id, 
                             ': no root measure for texts, adding it in English only!')"/>
	<xsl:call-template name="add-measure">
	  <xsl:with-param name="unit">texts</xsl:with-param>
	</xsl:call-template>
      </xsl:if>
      <xsl:if test="not(tei:measure[@unit='paragraphs'])">
	<xsl:message select="concat('WARN ', /tei:teiCorpus/@xml:id, 
                             ': no root measure for paragraphs, adding it in English only!')"/>
	<xsl:call-template name="add-measure">
	  <xsl:with-param name="unit">paragraphs</xsl:with-param>
	</xsl:call-template>
      </xsl:if>
      <xsl:if test="not(tei:measure[@unit='words'])">
	<xsl:message select="concat('WARN ', /tei:teiCorpus/@xml:id, 
                             ': no root measure for words, adding it in English only!')"/>
	<xsl:call-template name="add-measure">
	  <xsl:with-param name="unit">words</xsl:with-param>
	</xsl:call-template>
      </xsl:if>
      <xsl:apply-templates mode="root"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="root" match="tei:measure[@unit='texts' or @unit='paragraphs' or @unit='words']">
    <xsl:call-template name="add-measure">
      <xsl:with-param name="unit" select="@unit"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="root" match="tei:publicationStmt/tei:date">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:attribute name="when" select="$today-iso"/>
      <xsl:value-of select="$today-iso"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="root" match="tei:editionStmt">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:if test="$version != tei:edition">
        <xsl:message select="concat('INFO ', /tei:*/@xml:id,
                             ': replacing version ', tei:edition, ' with ', $version)"/>
      </xsl:if>
      <edition>
        <xsl:value-of select="$version"/>
      </edition>
    </xsl:copy>
    <xsl:if test="not(following-sibling::tei:extent)">
      <xsl:message select="concat('WARN ', /tei:teiCorpus/@xml:id, 
                           ': no root extent, adding extent measures in English only!')"/>
      <extent>
  	<xsl:call-template name="add-measure">
	  <xsl:with-param name="unit">texts</xsl:with-param>
	</xsl:call-template>
	<xsl:call-template name="add-measure">
	  <xsl:with-param name="unit">paragraphs</xsl:with-param>
	</xsl:call-template>
	<xsl:call-template name="add-measure">
	  <xsl:with-param name="unit">words</xsl:with-param>
	</xsl:call-template>
      </extent>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="root" match="tei:projectDesc">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:choose>
	<xsl:when test="tei:p[@xml:lang = 'en']">
          <xsl:message select="concat('INFO ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id,
                               ': replacing English project description')"/>
	</xsl:when>
	<xsl:otherwise>
          <xsl:message select="concat('INFO ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id,
                               ': inserting English project description')"/>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:copy-of select="$projectDesc-en"/>
      <xsl:apply-templates mode="root" select="tei:*[not(self::tei:p[@xml:lang = 'en'])]"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="root" match="tei:revisionDesc">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:apply-templates mode="root" select="*"/>
      <change when="{$today-iso}">parlamint-add-common-content script: Adding common content.</change>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="root" match="tei:idno">
    <xsl:copy>
      <xsl:choose>
	<xsl:when test="ancestor::tei:publicationStmt and contains(., 'hdl.handle.net')">
	  <xsl:attribute name="type">URI</xsl:attribute>
	  <xsl:attribute name="subtype">handle</xsl:attribute>
	  <xsl:choose>
            <xsl:when test="$type = 'txt'">
              <xsl:value-of select="$handle-txt"/>
            </xsl:when>
            <xsl:when test="$type = 'ana'">
              <xsl:value-of select="$handle-ana"/>
            </xsl:when>
	  </xsl:choose>
	</xsl:when>
	<xsl:when test="@type and @subtype">
	  <xsl:attribute name="type" select="@type"/>
	  <xsl:attribute name="subtype" select="@subtype"/>
          <xsl:value-of select="normalize-space(.)"/>
	</xsl:when>
	<xsl:when test="@type">
	  <xsl:message select="concat('WARN ', /tei:*/@xml:id, 
                               ': idno without subtype, content is ', .)"/>
	  <xsl:attribute name="type" select="@type"/>
          <xsl:value-of select="normalize-space(.)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:message select="concat('ERROR ', /tei:*/@xml:id, 
                               ': idno without type, content is ', .)"/>
          <xsl:value-of select="normalize-space(.)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="root" match="tei:encodingDesc">
    <xsl:variable name="tagUsagesSum">
    </xsl:variable>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:apply-templates mode="root" select="./tei:projectDesc"/>
      <xsl:apply-templates mode="root" select="./tei:editorialDecl"/>
      <xsl:call-template name="add-tagsDecl">
        <xsl:with-param name="tagUsages">
          <xsl:for-each select="distinct-values($tagUsages//@gi)">
            <xsl:sort select="."/>
            <xsl:variable name="elem-name" select="."/>
            <xsl:element name="tagUsage">
              <xsl:attribute name="gi" select="$elem-name"/>
              <xsl:attribute name="occurs" select="sum($tagUsages//*[@gi=$elem-name]/@occurs)"/>
            </xsl:element>
          </xsl:for-each>
         </xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates mode="root" select="./tei:classDecl"/>
      <xsl:apply-templates mode="root" select="./tei:listPrefixDef"/>
      <xsl:apply-templates mode="root" select="./tei:appInfo"/>
    </xsl:copy>
  </xsl:template>

  <!-- Remove leading, trailing and multiple spaces -->
  <xsl:template mode="root" match="text()[normalize-space(.)]">
    <xsl:variable name="str">
      <xsl:variable name="s" select="replace(., '\s+', ' ')"/>
      <xsl:choose>
	<xsl:when test="(not(preceding-sibling::tei:*) and starts-with($s, ' ')) and 
			(not(following-sibling::tei:*) and matches($s, ' $'))">
          <xsl:value-of select="replace($s, '^ (.+?) $', '$1')"/>
	</xsl:when>
	<xsl:when test="not(preceding-sibling::tei:*) and ends-with($s, ' ')">
          <xsl:value-of select="replace($s, '^ ', '')"/>
	</xsl:when>
	<xsl:when test="not(following-sibling::tei:*) and ends-with($s, ' ')">
          <xsl:value-of select="replace($s, ' $', '')"/>
	</xsl:when>
	<xsl:otherwise>
          <xsl:value-of select="$s"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test=". != $str ">
      <xsl:message select="concat('WARN ', /tei:*/@xml:id, 
                           ': removing spurious space from &quot;', replace(., '\s', '_'), '&quot;')"/>
    </xsl:if>
    <xsl:value-of select="$str"/>
  </xsl:template>
  
    <!-- Output root <measure> for a given $unit. 
	 If $lang is set, it is assumed that the unit measure is not present in input, so it has to be constructed from scratch 
    -->
    <xsl:template name="add-measure">
      <xsl:param name="unit"/>
      <xsl:param name="lang">en</xsl:param>
      <xsl:variable name="quant">
	<xsl:choose>
          <xsl:when test="$unit='texts'">
            <xsl:value-of select="count($docs/tei:item[@type = 'component'])"/>
          </xsl:when>
          <xsl:when test="$unit='paragraphs'">
            <xsl:value-of select="sum($paragraphs/tei:item)"/>
          </xsl:when>
          <xsl:when test="$unit='words'">
            <xsl:value-of select="sum($words/tei:item)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes" select="concat('FATAL: Bad unit ', $unit, ' for add-measure')"/>
            <xsl:value-of select="number('0')"/>
          </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:variable name="quant-formatted" select="et:format-number($lang, $quant)"/>
      <xsl:choose>
	<xsl:when test="$quant != 0">
	  <measure unit="{$unit}" quantity="{format-number($quant, '#')}">
	    <xsl:attribute name="xml:lang">
	      <xsl:choose>
		<xsl:when test="normalize-space($lang)">
		  <xsl:value-of select="$lang"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:attribute>
	    <xsl:choose>
	      <xsl:when test="normalize-space($lang)">
		<xsl:value-of select="concat($quant-formatted, ' ', $unit)"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="replace(., '.+ ', concat($quant-formatted, ' '))"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </measure>
	</xsl:when>
	<xsl:otherwise>
          <xsl:message select="concat('ERROR ', /tei:*/@xml:id, 
                               ': no count for measure ', $unit)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:template>
    
    <xsl:template name="add-tagsDecl">
      <xsl:param name="tagUsages"/>
      <xsl:variable name="context" select="./tei:tagsDecl/tei:namespace[@name='http://www.tei-c.org/ns/1.0']"/>
      <xsl:element name="tagsDecl">
	<xsl:element name="namespace">
          <xsl:attribute name="name">http://www.tei-c.org/ns/1.0</xsl:attribute>
          <xsl:for-each select="distinct-values(($tagUsages//@gi,$context//@gi))">
            <xsl:sort select="."/>
            <xsl:variable name="elem-name" select="."/>
            <xsl:variable name="new" select="$tagUsages//*:tagUsage[@gi=$elem-name]"/>
            <xsl:variable name="old" select="$context//*:tagUsage[@gi=$elem-name]"/>
            <xsl:choose>
              <xsl:when test="$new and not($old)">
		<xsl:message select="$context/concat('INFO ', /tei:*/@xml:id,
				     ': adding ',$elem-name,' tagUsage ', $new/@occurs)"/>
              </xsl:when>
              <xsl:when test="not($new) and $old">
		<xsl:message select="$context/concat('INFO ', /tei:*/@xml:id,
				     ': removing ',$elem-name,' tagUsage ', $old/@occurs)"/>
              </xsl:when>
              <xsl:when test="not($new/@occurs = $old/@occurs)">
		<xsl:message select="$context/concat('INFO ', /tei:*/@xml:id,
				     ': replacing ',$elem-name,' tagUsage ', $old/@occurs, ' with ', $new/@occurs)"/>
              </xsl:when>
              <xsl:when test="$new/@occurs = $old/@occurs">
		<!--xsl:message select="$context/concat('INFO ', /tei:*/@xml:id,
                    ': preserving ',$elem-name,' tagUsage ', $new/@occurs)"/-->
              </xsl:when>
            </xsl:choose>
	    <!-- Need to format the number again, otherwise output in scientific notation -->
	    <xsl:if test="$new">
	      <tagUsage gi="{$new/@gi}">
		<xsl:attribute name="occurs" select="format-number($new/@occurs, '#')"/>
	      </tagUsage>
	    </xsl:if>
          </xsl:for-each>
	</xsl:element>
      </xsl:element>
    </xsl:template>
    
  </xsl:stylesheet>
