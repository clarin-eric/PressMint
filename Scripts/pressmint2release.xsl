<?xml version="1.0"?>
<!-- Prepare a PressMint corpus for a release, i.e. fix known and automatically fixable errors in the source corpus -->
<!-- The script can be used for both corpora in original langauge(s) or for their MTed variant -->
<!-- Input is either lingustically analysed (.TEI.ana) or "plain text" (.TEI) corpus root file XIncluding the corpus components
     Note that .TEI needs access to .TEI.ana as that is where it takes its word extents
     Output is the corresponding .TEI / TEI.ana corpus root and corpus components, in the dicrectory given in the outDir parameter
     If .TEI is being processed, the corresponding TEI.ana directory should be given in the anaDir parameter
     STDERR gives a detailed log of changes.

     Changes to root file:
     - delete non-standard extent/measures
     - fix bad URL idno @type and @subtype
     - fix sprurious spaces in text content (multiple, leading and trailing spaces)

     Changes to component files:
     - delete non-standard extent/measures
     - remove empty paragraphs
     - assign IDs to paragraphs without them
     - in .ana remove body name tag if name contains no words
     - in .ana remove sentences without tokens
     - in .ana change tag from <w> to <pc> for punctuation
     - in .ana change UPoS tag from - to X
     - in .ana change lemma tag from empty or _ to normalised form or wordform, lower-cased if not PROPN
     - fix spurious spaces in text content (multiple, leading and trailing spaces)
-->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:mk="http://ufal.mff.cuni.cz/matyas-kopp"
  xmlns:et="http://nl.ijs.si/et" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xsl tei et mk xs xi"
  version="2.0">

  <xsl:import href="pressmint-lib.xsl"/>
  
  <!-- Directories must have absolute paths or relative to the location of this script -->
  <xsl:param name="outDir">.</xsl:param>
  <xsl:param name="anaDir">.</xsl:param>
  
  <!-- Type of corpus is 'txt' or 'ana' -->
  <xsl:param name="type">
    <xsl:choose>
      <xsl:when test="contains(/tei:teiCorpus/@xml:id, '.ana')">ana</xsl:when>
      <xsl:otherwise>txt</xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  
  <!-- County code take from the teiCorpus ID, country name from main English title -->
  <xsl:param name="country-code" select="replace(/tei:teiCorpus/@xml:id, 
                                         '.*?-([^._]+).*', '$1')"/>
  <xsl:param name="country-name" select="replace(/tei:teiCorpus/tei:teiHeader/
                                         tei:fileDesc/tei:titleStmt/
                                         tei:title[@type='main' and @xml:lang='en'],
                                         '([^ ]+) .*', '$1')"/>
  
  <!-- Is this an MTed corpus? Set $mt to name of MTed language (or to empty, if not MTed) -->
  <xsl:param name="mt">
    <xsl:if test="matches($country-code, '-[a-z]{2,3}$')">
      <xsl:value-of select="replace($country-code, '.+-([a-z]{2,3})$', '$1')"/>
    </xsl:if>
  </xsl:param>
  
  <!-- parameters for partial processing, root file is processed after processing the last component file -->
  <xsl:param name="chunkStart">0</xsl:param>
  <xsl:param name="chunkSize">0</xsl:param> <!-- 0 means process all -->
  
  <xsl:output method="xml" indent="yes" omit-xml-declaration="no"/>
  <xsl:preserve-space elements="catDesc p"/>

  <!-- Input directory -->
  <xsl:variable name="inDir" select="replace(base-uri(), '(.*)/.*', '$1')"/>
  <!-- The name of the corpus directory to output to, i.e. "PressMint-XX" -->
  <xsl:variable name="corpusDir" select="replace(base-uri(), 
                                         '.*?([^/]+)/[^/]+\.[^/]+$', '$1')"/>

  <!-- Output root file -->
  <xsl:variable name="outRoot">
    <xsl:value-of select="$outDir"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="$corpusDir"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="replace(base-uri(), '.*/(.+)$', '$1')"/>
  </xsl:variable>

  <!-- Gather URIs of component xi + files and map to new files, incl. .ana files -->
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
      </item>
      </xsl:for-each>
  </xsl:variable>

  <!-- docs to process in chunk -->
  <xsl:variable name="docsChunk">
    <xsl:copy-of select="$docs//tei:item[xs:integer(@position) gt xs:integer($chunkStart) and (xs:integer(@position) le $chunkStart + $chunkSize or $chunkSize = 0)]"/>  
  </xsl:variable> 

  <xsl:template match="/">
    <xsl:message select="concat('INFO Starting to process ', tei:teiCorpus/@xml:id)"/>
    <xsl:message>
      <xsl:text>INFO Starting to process component files</xsl:text>
      <xsl:if test="xs:integer($chunkSize) = 0 or xs:integer($chunkStart) gt 0">
        <xsl:text> from </xsl:text>
        <xsl:value-of select="$docsChunk//tei:item[1]/@position"/>
        <xsl:text> to </xsl:text>
        <xsl:value-of select="$docsChunk//tei:item[last()]/@position"/> 
      </xsl:if>
    </xsl:message>
    <!-- Process component files -->
    <xsl:for-each select="$docsChunk//tei:item">
      <xsl:variable name="this" select="tei:xi-orig"/>
      <xsl:message select="concat('INFO Processing [',@position,'] ', $this)"/>
      <xsl:result-document href="{tei:url-new}">
	<xsl:choose>
	  <!-- Process factorised parts of corpus root teiHeader as if they were root -->
	  <xsl:when test="@type = 'factorised'">
            <xsl:apply-templates mode="root" select="document(tei:url-orig)"/>
	  </xsl:when>
	  <!-- Process component -->
	  <xsl:when test="@type = 'component'">
            <xsl:apply-templates mode="comp" select="document(tei:url-orig)/tei:TEI"/>
	  </xsl:when>
	</xsl:choose>
      </xsl:result-document>
    </xsl:for-each>
    <xsl:if test="$docsChunk//tei:item[last()]/@position = count($docs//tei:item)">
      <xsl:text>STATUS: Processed last chunk</xsl:text> <!-- Do not change this message !!! -->
      <!-- Output Root file -->
      <xsl:message select="concat('INFO processing root ', tei:teiCorpus/@xml:id)"/>
      <xsl:result-document href="{$outRoot}">
        <xsl:apply-templates mode="root"/>
      </xsl:result-document>
    </xsl:if>
  </xsl:template>

  <xsl:template match="* | @*">
    <xsl:message terminate="yes">All templates must have mode comp or root!</xsl:message>
  </xsl:template>
  
  <!-- Finalizing root file -->
  
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
        <xsl:copy-of select="."/>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="root" match="tei:revisionDesc">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <change when="{$today-iso}">parlamint2release script: Fix some identifiable erros for the release.</change>
      <xsl:apply-templates mode="root" select="*"/>
    </xsl:copy>
  </xsl:template>

  <!-- We remove individually inserted non-speech and non-word measures as we don't trust them -->
  <xsl:template mode="root" match="tei:extent/tei:measure[@unit != 'speeches' and @unit != 'words']"/>
    
  <xsl:template mode="root" match="tei:langUsage/tei:language">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:variable name="okName" select="concat(upper-case(substring(., 1, 1)), lower-case(substring(., 2)))"/>
      <xsl:choose>
	<!-- English names of languages should be in title case -->
	<xsl:when test="ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = 'en' and . != $okName">
	  <xsl:value-of select="$okName"/>
	  <xsl:message select="concat('WARN ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id, 
                               ': changing language name from ', ., ' to ', $okName)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="normalize-space(.)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="root" match="tei:idno">
    <xsl:copy>
      <xsl:apply-templates mode="root" select="@*"/>
      <xsl:choose>
	<xsl:when test="@type = 'url' or @type = 'URL'">
	  <xsl:attribute name="type">URI</xsl:attribute>
	  <xsl:message select="concat('WARN ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id, 
                               ': fixing idno type from url to URI for ', .)"/>
        </xsl:when>
      </xsl:choose>
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="root" match="text()">
    <xsl:choose>
      <xsl:when test="not(../tei:*)">
	<xsl:if test="starts-with(., '\s') or ends-with(., '\s')">
	  <xsl:message select="concat('WARN ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id, 
                               ': removing spurious space from ', .)"/>
	</xsl:if>
	<xsl:value-of select="normalize-space(.)"/>
      </xsl:when>
      <xsl:when test="preceding-sibling::tei:* and following-sibling::tei:*">
	<xsl:value-of select="."/>
      </xsl:when>
      <xsl:when test="preceding-sibling::tei:*">
	<xsl:if test="ends-with(., '\s')">
	  <xsl:message select="concat('WARN ', /tei:*/@xml:id, 
                               ': removing trailing space from ', .)"/>
	</xsl:if>
	<xsl:value-of select="replace(., '\s+$', '')"/>
      </xsl:when>
      <xsl:when test="following-sibling::tei:*">
	<xsl:if test="starts-with(., '\s')">
	  <xsl:message select="concat('WARN ', /tei:*/@xml:id, 
                               ': removing starting space from ', .)"/>
	</xsl:if>
	<xsl:value-of select="replace(., '^\s+', '')"/>
      </xsl:when>
      <xsl:otherwise>
	  <xsl:message terminate="yes" select="concat('FATAL ERROR ', /tei:*/@xml:id, 
                               ': strange situation with ', .)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Finalizing component files -->
  <xsl:template mode="comp" match="*">
    <xsl:copy>
      <xsl:apply-templates mode="comp" select="@*"/>
      <xsl:apply-templates mode="comp"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template mode="comp" match="@*">
    <xsl:copy/>
  </xsl:template>

  <!-- Set correct ID of component -->
  <xsl:template mode="comp" match="tei:TEI/@xml:id">
    <xsl:variable name="id" select="replace(base-uri(), '^.*?([^/]+)\.xml$', '$1')"/>
    <xsl:attribute name="xml:id" select="$id"/>
    <xsl:if test=". != $id">
      <xsl:message select="concat('WARN ', @xml:id, ': fixing TEI/@xml:id to ', $id)"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="comp" match="text()">
    <xsl:apply-templates mode="root" select="."/>
  </xsl:template>

  <!-- We remove individually inserted non-speech and non-word measures as we don't trust them -->
  <xsl:template mode="comp" match="tei:extent/tei:measure[@unit != 'pages' and @unit != 'words']"/>

  <!-- Bug where a paragraph contains nothing, remove it -->
  <xsl:template mode="comp" match="tei:p[not(normalize-space(.) or .//tei:*)]">
    <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                         ': removing paragraph without content for ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
  </xsl:template>
  
  <!-- Bug where a sentence contains no tokens, remove sentence -->
  <xsl:template mode="comp" match="tei:s[not(.//tei:w or .//tei:pc)]">
    <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                         ': removing sentence without tokens for ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
    <!-- If sentence contains notes or similar, keep these but not link group -->
    <xsl:if test="tei:*">
      <xsl:apply-templates mode="comp" select="tei:*[not(self::tei:linkGrp)]"/>
    </xsl:if>
  </xsl:template>
  
  <!-- Bug where a name contains no words, but only punctuation or a transcriber comment: remove <name> tag -->
  <xsl:template mode="comp" match="tei:body//tei:name[not(.//tei:w or .//tei:pc[not(matches(., '^\p{P}+$'))])]">
    <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                         ': removing name tag as ', normalize-space(.), 
			 ' contains no w elements for ', ancestor-or-self::tei:*[@xml:id][1]/@xml:id)"/>
    <xsl:apply-templates mode="comp"/>
  </xsl:template>
  
  <!-- Processing tools also make various formal mistakes on words, here we try to fix them -->
  <xsl:template mode="comp" match="tei:w">
    <xsl:choose>
      <!-- Bug where punctuation is encoded as a word: change <w> to <pc> -->
      <xsl:when test="contains(@msd, 'UPosTag=PUNCT') and matches(., '^\p{P}+$')">
	<!-- Do not output warning, as there are typically too many of them -->
	<!--xsl:message select="concat('WARN: changing word ', ., ' to punctuation for ', @xml:id)"/-->
	<pc>
	  <xsl:apply-templates mode="comp" select="@*[name() != 'lemma']"/>
	  <xsl:apply-templates mode="comp"/>
	</pc>
      </xsl:when>
      <!-- Wrongly annotated punctations as a symbol-->
      <xsl:when test="@lemma='' and @msd = 'UPosTag=SYM' ">
        <xsl:message select="concat('WARN: changing symbol(UPosTag=SYM) ', ., ' to punctuation for ', @xml:id)"/>
	<pc>
          <xsl:attribute name="msd">UPosTag=PUNCT</xsl:attribute>
	        <xsl:apply-templates mode="comp" select="@*[name() != 'lemma' and name() != 'pos' and name() != 'msd']"/>
	        <xsl:apply-templates mode="comp"/>
	      </pc>
      </xsl:when>
      <!-- Bug where syntactic word contains just one word: remove outer word and preserve annotations -->
      <xsl:when test="tei:w[tei:w] and not(tei:w[tei:*[2]])">
        <xsl:message select="concat('WARN ', /tei:TEI/@xml:id,
                             ': removing useless syntactic word ', @xml:id)"/>
        <xsl:copy>
          <xsl:apply-templates mode="comp" select="tei:w/@*[name() != 'norm']"/>
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates mode="comp" select="@*"/>
          <xsl:apply-templates mode="comp"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Bug where UPosTag is set to "-": change to "X" -->
  <xsl:template mode="comp" match="tei:w/@msd[contains(., 'UPosTag=-')]">
    <xsl:attribute name="msd">
      <xsl:message select="concat('WARN ', /tei:TEI/@xml:id, 
                           ': changing UPosTag=- to UPosTag=X for ', ../@xml:id)"/>
      <xsl:value-of select="replace(., 'UPosTag=-', 'UPosTag=X')"/>
    </xsl:attribute>
  </xsl:template>
  
  <!-- Bug where lemma is empty or "_": change to @norm, if it exists, else to text() of the word -->
  <xsl:template mode="comp" match="tei:w/@lemma[not(normalize-space(.)) or . = '_']">
    <xsl:variable name="message" select="concat('WARN ', /tei:TEI/@xml:id,  ': changing bad lemma ', ., ' to ')"/>
    <xsl:variable name="location" select="concat(' in ', ../@xml:id)"/>
    <xsl:attribute name="lemma">
      <xsl:choose>
        <xsl:when test="../@norm">
          <xsl:message select="concat($message, '@norm ', ../@norm, $location)"/>
          <xsl:value-of select="../@norm"/>
        </xsl:when>
        <xsl:when test="../contains(@msd, 'UPosTag=PROPN')">
          <xsl:message select="concat($message, 'PROPN token ', ../text(), $location)"/>
          <xsl:value-of select="../text()"/>
	</xsl:when>
        <xsl:otherwise>
          <xsl:message select="concat($message, 'lower-cased token ', lower-case(../text()), $location)"/>
          <xsl:value-of select="lower-case(../text())"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  
  <!-- Bug in STANZA, sometimes several tokens have root dependency -->
  <!-- We set those that have root but do not point to sentence ID to "dep" -->
  <xsl:template mode="comp" match="tei:linkGrp[@type = 'UD-SYN']/tei:link[@ana='ud-syn:root']">
    <xsl:copy>
      <xsl:variable name="root-ref" select="concat('#', ancestor::tei:s/@xml:id)"/>
      <xsl:attribute name="ana">
	<xsl:choose>
	  <xsl:when test="$root-ref = substring-before(@target, ' ')">ud-syn:root</xsl:when>
	  <xsl:otherwise>
            <xsl:message select="concat('WARN ', ancestor::tei:s/@xml:id, 
                               ': replacing ud-syn:root with ud-syn:dep for non-root dependency')"/>
	    <xsl:text>ud-syn:dep</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates mode="root" select="@target"/>
    </xsl:copy>
  </xsl:template>

  <!-- Bug in STANZA, sometimes synt. relation is "<PAD>" -->
  <!-- We set it to general dependency "dep" -->
  <xsl:template mode="comp" match="tei:linkGrp[@type = 'UD-SYN']/tei:link[@ana='ud-syn:&lt;PAD&gt;']">
    <xsl:copy>
      <xsl:attribute name="ana">
        <xsl:message select="concat('WARN ', ancestor::tei:s/@xml:id, 
                               ': replacing ud-syn:&lt;PAD&gt; with ud-syn:dep')"/>
	<xsl:text>ud-syn:dep</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates mode="comp" select="@target"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
