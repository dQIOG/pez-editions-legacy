<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    
    
    <xsl:preserve-space elements="tei:p tei:seg p"/>
    <xsl:output indent="yes"/>
    <xsl:param name="splitLetters">yes</xsl:param>
    <xsl:param name="path-to-sigla">file:/C:/Users/Daniel/data/pez-edition/102_derived_tei/102_04_auxiliary_files/sigla.xml</xsl:param>
    <xsl:variable name="sigla" select="doc($path-to-sigla)" as="document-node()"/>
    
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:TEI" mode="groupSections splitParts cleanup parseRegest collapseAdjacentRends parseCommentary addIDs tagLemmas createLinks tagPersAbbrs parseEditorialNotes xenoData2correspDesc correspDesc2profileDesc correctDates addNotesStmt">
        <xsl:document>
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:apply-templates mode="#current"/>
            </xsl:copy>
        </xsl:document>
    </xsl:template>
    
    
    
    <xsl:template match="/">
        <xsl:variable name="lettersExtracted" as="document-node()+">
            <xsl:apply-templates select="tei:TEI/tei:text/tei:body" mode="extractLetters"/>
        </xsl:variable>
        <xsl:variable name="sectionsGrouped" as="document-node()+">
            <xsl:apply-templates select="$lettersExtracted" mode="groupSections"/>
        </xsl:variable>
        <xsl:variable name="cleanedup" as="document-node()+">
            <xsl:apply-templates select="$sectionsGrouped" mode="cleanup"/>
        </xsl:variable>
        <xsl:variable name="regestParsed" as="document-node()+">
            <xsl:apply-templates select="$cleanedup" mode="parseRegest"/>
        </xsl:variable>
        <xsl:variable name="adjacentRendsCollapsed" as="document-node()+">
            <xsl:apply-templates select="$regestParsed" mode="collapseAdjacentRends"/>
        </xsl:variable>
        <xsl:variable name="commentaryParsed" as="document-node()+">
            <xsl:apply-templates select="$adjacentRendsCollapsed" mode="parseCommentary"/>
        </xsl:variable>
        <xsl:variable name="IDsAdded" as="document-node()+">
            <xsl:apply-templates select="$commentaryParsed" mode="addIDs"/>
        </xsl:variable>
        <xsl:variable name="lemmasTagged" as="document-node()+">
            <xsl:apply-templates select="$IDsAdded" mode="tagLemmas"/>
        </xsl:variable>
        <xsl:variable name="linksCreated" as="document-node()+">
            <xsl:apply-templates select="$lemmasTagged" mode="createLinks"/>
        </xsl:variable>
        <xsl:variable name="partsSplit" as="document-node()+">
            <xsl:apply-templates select="$linksCreated" mode="splitParts"/>
        </xsl:variable>
        <xsl:variable name="persAbbrsTagged" as="document-node()+">
            <xsl:apply-templates select="$partsSplit" mode="tagPersAbbrs"/>
        </xsl:variable>
        <xsl:variable name="xenoData2correspDesc" as="document-node()+">
            <xsl:apply-templates select="$persAbbrsTagged" mode="xenoData2correspDesc"/>
        </xsl:variable>
        <xsl:variable name="editorialNoteParsed" as="document-node()+">
            <xsl:apply-templates select="$xenoData2correspDesc" mode="parseEditorialNotes"/>
        </xsl:variable>
        <xsl:variable name="correspDesc2profileDesc" as="document-node()+">
            <xsl:apply-templates select="$editorialNoteParsed" mode="correspDesc2profileDesc"/>
        </xsl:variable>
        <xsl:variable name="datesCorrected" as="document-node()+">
            <xsl:apply-templates select="$correspDesc2profileDesc" mode="correctDates"/>
        </xsl:variable>
        <xsl:variable name="notesStmtAdded" as="document-node()+">
            <xsl:apply-templates select="$datesCorrected" mode="addNotesStmt"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$splitLetters = 'no'">
                <teiCorpus created="{current-dateTime()}"><xsl:sequence select="$notesStmtAdded"/></teiCorpus>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$notesStmtAdded">
                    <xsl:result-document href="../102_03_extracted_letters/pez_{format-number(.//tei:publicationStmt/tei:idno,'000')}.xml">
                        <xsl:sequence select="."/>
                    </xsl:result-document>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="parse-heading">
        <xsl:param name="heading" as="element(tei:p)"/>
        <xsl:analyze-string select="normalize-space($heading)" regex="\[?(\d+)\]?\s+(.+)\san\s(.+)(\((.+)\))?\." flags="s">
            <xsl:matching-substring>
                <id xmlns=""><xsl:value-of select="normalize-space(regex-group(1))"/></id>
                <deduced xmlns=""><xsl:value-of select="matches(normalize-space($heading),'^\[\d+\]')"/></deduced>
                <sender xmlns=""><xsl:value-of select="normalize-space(regex-group(2))"/></sender>
                <recipient xmlns=""><xsl:value-of select="normalize-space(replace(regex-group(3),'\.$',''))"/></recipient>
                <destination xmlns=""><xsl:value-of select="regex-group(5)"/></destination>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <unparsable xmlns="" element="heading"><xsl:value-of select="."/></unparsable>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    
    
    <xsl:template name="parse-dateline">
        <xsl:param name="dateline" as="element(tei:p)"/>
        <xsl:analyze-string select="normalize-space($dateline)" regex="^((\d{{4,4}}\-\d{{1,2}}\-\d{{1,2}})?(\s?&lt;\s|\s?&gt;\s)?(\d{{4,4}}\-\d{{1,2}}\-\d{{1,2}}))(\s\(\?\))?\.((.+)\.)?$">
            <xsl:matching-substring>
                <date xmlns="">
                    <xsl:if test="normalize-space(regex-group(5)) = '(?)'">
                        <xsl:attribute name="cert">low</xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="normalize-space(regex-group(1))"/></date>
                <place-of-posting xmlns=""><xsl:value-of select="replace(normalize-space(regex-group(6)),'\.$','')"/></place-of-posting>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <unparsable element="dateline" xmlns=""><xsl:value-of select="."/></unparsable>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template match="tei:body" mode="extractLetters">
        <xsl:for-each-group select="*[not(@rend = 'Edition Überschrift Ebene 1')]" group-starting-with="tei:p[@rend = 'Edition Briefüberschrift 1']">
            <xsl:variable name="heading-parsed">
                <xsl:call-template name="parse-heading">
                    <xsl:with-param name="heading" select="current-group()[1]"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="dateline-parsed">
                <xsl:call-template name="parse-dateline">
                    <xsl:with-param name="dateline" select="current-group()/self::tei:p[@rend = 'Edition Briefüberschrift 2'][1]"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:document>
                <TEI xmlns="http://www.tei-c.org/ns/1.0">
                    <teiHeader>
                        <fileDesc>
                            <titleStmt>
                                <title type="main">
                                    <xsl:value-of select="normalize-space(current-group()[1][@rend = 'Edition Briefüberschrift 1'])"/>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="normalize-space(current-group()[2][@rend = 'Edition Briefüberschrift 2'])"/>
                                </title>
                                <title type="sub">Digital Edition</title>
                                <principal>Thomas Wallnig</principal>
                                <respStmt>
                                    <resp>Conversion to TEI</resp>
                                    <persName>Daniel Schopper</persName>
                                </respStmt>
                            </titleStmt>
                            <publicationStmt>
                                <publisher>Austrian Centre for Digital Humanities</publisher>
                            </publicationStmt>
                            <notesStmt>
                                <relatedItem type="publishedIn">
                                    <bibl>Die gelehrte Korrespondenz der Brüder Pez, Text, Regesten, Kommentare; Band 1: 1709–1715.</bibl>
                                </relatedItem>
                            </notesStmt>
                            <sourceDesc>
                            </sourceDesc>
                        </fileDesc>
                        <profileDesc>
                            <textClass>
                                <classCode scheme="pez">letter</classCode>
                            </textClass>
                        </profileDesc>
                        <xenoData>
                            <xsl:sequence select="$heading-parsed"/>
                            <xsl:sequence select="$dateline-parsed"/>
                        </xenoData>
                    </teiHeader>
                    <text>
                        <xsl:apply-templates select="current-group()" mode="#current"/>
                    </text>
                </TEI>
            </xsl:document>
            
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template match="tei:p[@rend = 'Edition Regest']" mode="extractLetters">
        <xsl:variable name="ms" as="document-node()">
            <xsl:document>
                <xsl:analyze-string select="." regex="&lt;(\d+)&gt;">
                    <xsl:matching-substring><milestone n="{regex-group(1)}" xmlns="http://www.tei-c.org/ns/1.0"/></xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:document>
        </xsl:variable>
        <div type="regest">
            <p xml:space="preserve"><xsl:for-each-group select="$ms/node()" group-starting-with="tei:milestone"><seg type="context" n="{current-group()[1]/@n}"><xsl:value-of select="current-group()[position() gt 1]/normalize-space(.)"/></seg></xsl:for-each-group></p>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:p[@rend ='Edition Editorische Notiz']" mode="extractLetters">
        <div type="editorialNote">
            <p xml:space="preserve"><xsl:apply-templates mode="#current"/></p>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:p[@rend ='Edition Editionstext']" mode="extractLetters">
        <!-- context markers look like <1> typeset in italics. However, for manual formatting 
            the angle brackets sometimes are straight and only digits are italicised - thus we 
            have to normalize this here -->
        <xsl:variable name="contextMarkerNormalized">
            <xsl:document>
                <xsl:apply-templates mode="normalizeContextMarker"/>
            </xsl:document>
        </xsl:variable>
        <xsl:variable name="editionTextPrep" as="document-node()">
            <xsl:document>
                <xsl:apply-templates select="$contextMarkerNormalized" mode="prepEdText"/>
            </xsl:document>
        </xsl:variable>
        <div type="edition">
            <p>
                <xsl:attribute name="xml:space">preserve</xsl:attribute>
                <xsl:for-each-group select="$editionTextPrep/node()" group-starting-with="tei:milestone">
                    <xsl:choose>
                        <xsl:when test="current-group()[1]/self::tei:milestone">
                            <seg type="context" n="{current-group()[1]/@n}" xml:space="preserve"><xsl:apply-templates select="current-group()[not(self::tei:milestone)]" mode="#current"/></seg>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="current-group()[not(self::tei:milestone)]" mode="#current"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each-group></p></div>
    </xsl:template>
    
    <xsl:template match="text()[ancestor::tei:div/@type = 'edition'][ends-with(.,'&lt;')][following-sibling::node()[1]/self::tei:hi[@rend = 'italic'][matches(.,'^\d+$')]]" mode="normalizeContextMarker">
        <xsl:value-of select="substring-before(.,'&lt;')"/>
    </xsl:template>
    
    <xsl:template match="text()[ancestor::tei:div/@type = 'edition'][starts-with(.,'&gt;')][preceding-sibling::node()[1]/self::tei:hi[@rend = 'italic'][matches(.,'^\d+$')]]" mode="normalizeContextMarker">
        <xsl:value-of select="substring-after(.,'&gt;')"/>
    </xsl:template>
    
    <xsl:template match="tei:hi[@rend = 'italic'][matches(.,'^\d+$')][preceding-sibling::node()[1]/self::text()[ends-with(.,'&lt;')]][following-sibling::node()[1]/self::text()[starts-with(.,'&gt;')]]" mode="normalizeContextMarker">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:text>&lt;</xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>&gt;</xsl:text>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:hi[@rend = 'italic'][matches(.,'^\d+[rv)]')][preceding-sibling::node()[1]/ends-with(.,'[')][following-sibling::node()[1]/starts-with(.,']')]" mode="prepEdText">
        <pb n="{.}"/>
    </xsl:template>
    
    <xsl:template match="text()[ends-with(.,'[')][following-sibling::node()[1]/self::tei:hi[@rend = 'italic'][matches(.,'^\d+[rv)]')]]" mode="prepEdText">
        <xsl:value-of select="replace(.,'\[$','')"/>
    </xsl:template>
    
    <xsl:template match="text()[starts-with(.,']')][preceding-sibling::node()[1]/self::tei:hi[@rend = 'italic'][matches(.,'^\d+[rv)]')]]" mode="prepEdText" priority="1">
        <xsl:choose>
            <xsl:when test="ends-with(.,'[') and following-sibling::node()[1]/self::tei:hi[@rend = 'italic'][matches(.,'^\d+[rv)]')]">
                <xsl:value-of select="replace(replace(.,'^\]',''),'\[$','')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="replace(.,'^\]','')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:hi[@rend = 'italic'][matches(.,'^&lt;\d+&gt;\s*$')]" mode="prepEdText">
        <xsl:analyze-string select="." regex="^&lt;(\d+)&gt;\s*$">
            <xsl:matching-substring>
                <milestone n="{regex-group(1)}"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
        
    </xsl:template>
    
    <xsl:template match="tei:note[@place = 'foot']" mode="prepEdText">
        <note place="foot"><xsl:apply-templates select="tei:p/node()" mode="prepEdText"/></note>
    </xsl:template>
    
    <xsl:template match="tei:note[@place = 'foot']/tei:p/tei:hi[@rend = 'footnote_reference']" mode="prepEdText"/>
    
    
    <xsl:template match="tei:p[@rend = 'Edition Kommentar']" mode="extractLetters">
        <div type="commentary">
            <p xml:space="preserve"><xsl:apply-templates mode="#current"/></p>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:text" mode="groupSections">
        <xsl:copy>
            <xsl:for-each-group select="*" group-adjacent="if (@rend) then @rend else if (@type) then @type else false()">
                <xsl:choose>
                    <xsl:when test="count(current-group()) gt 1">
                        <div type="{current-group()[1]/(@rend,@type)[1]}">
                            <xsl:apply-templates select="current-group()" mode="#current"/>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()" mode="#current"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:div[@type = 'edition'][tei:p][parent::tei:div[@type = 'edition']]" mode="cleanup">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:div[@type = 'editorialNote'][tei:p][parent::tei:div[@type = 'editorialNote']]" mode="cleanup">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="tei:hi[starts-with(@rend, 'KommentarGesperrt')]" mode="cleanup">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="tei:seg[@rend][parent::tei:hi[starts-with(@rend, 'KommentarGesperrt')] or parent::tei:p[parent::tei:div/@type = 'commentary']]" mode="cleanup">
        <hi>
            <xsl:copy-of select="@rend"/>
            <xsl:copy-of select="node()"/>
        </hi>
    </xsl:template>
    
    <xsl:template match="text()[ancestor::tei:div[@type = 'regest']]" mode="parseRegest">
        <xsl:analyze-string select="." regex="\((\d{{1,3}})\)">
            <xsl:matching-substring>
                <ref type="letter"><xsl:value-of select="regex-group(1)"/></ref>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>    
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    
    <xsl:template match="*[count(tei:hi) gt 1]" mode="collapseAdjacentRends">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:for-each-group select="node()" group-adjacent="if (exists(@rend)) then @rend else true()">
                <xsl:choose>
                    <xsl:when test="every $c in current-group() satisfies $c/@rend and count(current-group()) gt 1 and count(distinct-values(current-group()/local-name())) eq 1">
                        <xsl:element name="{current-group()[1]/local-name(.)}" namespace="{namespace-uri()}">
                            <xsl:copy-of select="current-group()[1]/@rend"/>
                            <xsl:for-each select="distinct-values(current-group()/@*/local-name())">
                                <xsl:attribute name="{.}">
                                    <xsl:value-of select="current-group()//attribute::*[local-name() = .][1]"/>
                                </xsl:attribute>
                            </xsl:for-each>
                            <xsl:apply-templates select="current-group()/node()" mode="#current"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
    
        
    
    <!-- 
        <div type="commentary">
            <p>
                <hi rend="italic" xml:space="preserve">&lt;2&gt; Vitum Spaney: </hi>Die genannten Codices sind in der BStB München nicht erhalten, jedoch in clm 21108 Spanneys Schulschrift „Oratio de laudibus litterarum“ von 1590 (vgl. Halm et al., Catalogus 2/3 297).<hi rend="italic" xml:space="preserve"> &lt;4&gt; insigniis ... abbatis mei: </hi>Das Wappen von Abt Joseph Frantz zeigt einen Strauß: Zimmermann, Kloster-Heraldik 159.<hi rend="italic" xml:space="preserve"> Problemata descripsi: </hi>Die Beilage ist erhalten: I, 556r–v. Das Thesenwerk „Struthio problematicus“ scheint sonst verloren zu sein. Zu seiner Aufnahme durch BP vgl. 381 &lt;1&gt;.<hi rend="italic" xml:space="preserve"> theses theologicas:</hi> Wahrscheinlich das „Exercitium theologicum de incarnatione Verbi divini“ von 1704, dem ein Supplement zur 1702 veröffentlichten „Chronologia monastico-philosophica“ beigegeben war, die BCh schon mit 52 an BP übermittelt hatte.<hi rend="italic" xml:space="preserve"> calamo ... nimis Bavarico: </hi>Gemeint sind vermutlich antiösterreichische Spitzen; zur Plünderung Thierhauptens durch kaiserliche Truppen im Spätsommer 1704 vgl. 52 &lt;1&gt;. <hi rend="italic">&lt;5&gt; qui modo cathedras ... illustrant:</hi> Vgl. Reichhold, 300 Jahre 672. Zum Kommunstudium der Bayerischen Kongregation vgl. allgemein 36 &lt;7&gt;, 255 &lt;3&gt;. <hi rend="italic" xml:space="preserve">Petrus Guettrather: </hi>Vgl. 255 &lt;3&gt;, 293. <hi rend="italic">&lt;6&gt; Alphonsus Wenzel:</hi> Zu ihm: Hubensteiner, Geistliche Stadt 166f.; Lindner, Schriftsteller Bayern 1 33; Muschard, Kirchenrecht 483 (der freilich irrig behauptet, Wenzl sei auch Professor in Salzburg gewesen).<hi rend="italic" xml:space="preserve"> &lt;7&gt; Henricus Hardter:</hi> Baader, Das gelehrte Baiern col. 442f.; Hubensteiner, Geistliche Stadt 163, 166f.<hi rend="italic" xml:space="preserve"> &lt;8&gt; Quartum adiungo: </hi>Meichelbeck war bereits seit 1708 nicht mehr am Kommunstudium tätig; vgl. Mindera, Jugend 101. Zu seinen Thesen vgl. 464 &lt;1&gt;. <hi rend="italic" xml:space="preserve">&lt;9&gt; Aegidium Kibler: </hi>Vgl. 36 &lt;7&gt;. <hi rend="italic" xml:space="preserve">&lt;10&gt; collegii ... Frisingani: </hi>Vgl. 255 &lt;3&gt;.<hi rend="italic" xml:space="preserve"> inventionis sancti Nonnosi: </hi>Die Gebeine des Hl. Nonnosus waren 1708 im Zuge der Bauarbeiten am Freisinger Dom aufgefunden worden. Die Translation in die neugestaltete Krypta am 2. September 1709 wurde mit achttägigen Feiern begangen: Götz, Kunst in Freising 48, 94, 101f.; Hubensteiner, Geistliche Stadt 156, 199; Meichelbeck, Historia Frisingensis 2/1 441–448; vgl. auch 464 &lt;11&gt;. Die Festschrift zu dieser Gelegenheit einschließlich Wiedergabe der gehaltenen Predigten brachte der „Hofpater“ des Freisinger Fürstbischofs Johann Franz Eckher von Kapfing, der Frauenzeller Benediktiner und spätere Abt Benedikt Eberschwang, heraus; von dieser Schrift scheint BCh zu sprechen. Zu Eberschwang: Götz, Kunst in Freising 47f.; Sächerl, Chronik Frauenzell 344–353.<hi rend="italic" xml:space="preserve"> &lt;11&gt; Martinum Rabstein: </hi>Zu dieser Person konnte nichts ermittelt werden.<hi rend="italic" xml:space="preserve"> Joannem Rieger: </hi>Vgl. Lieb, Rieger.
            </p>
        </div>
        
        zu 
        
        <div type="commentary">
            <note>
                <ref>2</ref>
                <label>Vitium Spaney</label>
                <p>Die genannten Codices ...</p>
            </note>
        </div>
    -->
    
    
    <xsl:template match="tei:div[@type = 'commentary']/tei:p" mode="parseCommentary">
        <xsl:if test="not(node()[1]/self::tei:hi/@rend = 'italic' and node()[2] instance of text())">
            <xsl:message terminate="no" select="."/>
            <xsl:message terminate="yes">Unexpected Structure of commentary</xsl:message>
        </xsl:if>
        <xsl:for-each-group select="node()" group-starting-with="tei:hi[@rend = 'italic']">
            <note>
                <xsl:apply-templates select="current-group()" mode="#current"/>
            </note>
        </xsl:for-each-group> 
    </xsl:template>
    
    <xsl:template match="tei:hi[@rend = 'italic'][ancestor::tei:div[@type = 'commentary']]" mode="parseCommentary">
        <xsl:variable name="note" select="parent::tei:p"/>
        <xsl:analyze-string select="." regex="^\s*(&lt;(\d+)&gt;\s)?(.+):\s*$">
            <xsl:matching-substring>
                <xsl:if test="regex-group(1) != ''">
                    <ref><xsl:value-of select="regex-group(2)"/></ref>
                </xsl:if>
                <label><xsl:value-of select="regex-group(3)"/></label>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <unparsable xmlns="" element="commentary/hi"><xsl:value-of select="."/></unparsable>
                <xsl:message>Note contains unparsable content</xsl:message>
                <xsl:message select="."/>
                <xsl:message terminate="yes" select="$note"/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template match="tei:div[@type = 'commentary']/tei:p/text()" mode="parseCommentary">
        <p><xsl:value-of select="normalize-space(.)"/></p>
    </xsl:template>
    
    <xsl:template match="tei:seg | tei:note" mode="addIDs">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:seg[ancestor::tei:div[@type = 'edition']]" mode="tagLemmas">
        <xsl:variable name="n" select="@n"/>
        <xsl:variable name="notes" select="root()//tei:note[(tei:ref,preceding-sibling::tei:note[tei:ref][1]/tei:ref)[1] = $n]" as="element(tei:note)*"/>
        <xsl:choose>
            <xsl:when test="exists($notes)">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:call-template name="tag-lemma">
                        <xsl:with-param name="notes" select="$notes" as="element(tei:note)+"/>
                        <xsl:with-param name="text-tagged" select="node()"/>
                    </xsl:call-template>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:note[ancestor::tei:div[@type = 'commentary']]" mode="createLinks">
        <xsl:variable name="id" select="@xml:id"/>
        <xsl:variable name="ref" select="(tei:ref,preceding-sibling::tei:note[tei:ref][1]/tei:ref)[1]" as="element(tei:ref)?"/>
        <xsl:if test="not($ref)">
            <xsl:message select="concat('letter ',root()//id)"/>
            <xsl:message terminate="yes">Missing $ref in note <xsl:sequence select="."/></xsl:message>
        </xsl:if>
        <xsl:variable name="context" select="root()//tei:seg[@n = $ref]" as="element(tei:seg)*"/>
        <!--<xsl:variable name="target" select="$context//tei:seg[@corresp = concat('#',$id)]" as="element(tei:seg)?"/>-->
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <!--<xsl:choose>
                <!-\-<xsl:when test="exists($context)">
                    <xsl:attribute name="target" select="$context/concat('#',@xml:id)"/>
                </xsl:when>-\->
                <xsl:otherwise>
                    <xsl:attribute name="lemma-not-found"/>
                </xsl:otherwise>
            </xsl:choose>-->
            <xsl:if test="not(exists(tei:ref))">
                <ref type="context"><xsl:value-of select="$ref"/></ref>
            </xsl:if>
            <xsl:apply-templates mode="#current">
                <xsl:with-param name="context-ids" as="xs:string*" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:note[ancestor::tei:div[@type = 'commentary']]/tei:ref" mode="createLinks">
        <xsl:param name="context-ids" as="xs:string*"/>
        <xsl:copy>
            <!--<xsl:attribute name="target" select="string-join(for $c in $context-ids return concat('#',$c),' ')"/>-->
            <xsl:attribute name="type">context</xsl:attribute>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:div[@type = 'editorialNote']/tei:p" mode="parseEditorialNotes">
        <xsl:variable name="letter-no" select="xs:integer(root()//tei:publicationStmt/tei:idno)"/>
            <xsl:choose>
                <xsl:when test="starts-with(., 'Bezüge')">
                    <correspContext>
                        <xsl:for-each select="tokenize(normalize-space(substring-after(., 'Bezüge:')),'\.')[. != '']">
                            <xsl:variable name="this" select="normalize-space(.)"/>
                            <xsl:variable name="type">
                                <xsl:choose>
                                    <xsl:when test="starts-with(normalize-space(.), 'Erwähnt in ')">
                                        <xsl:text>mentionedIn</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="starts-with($this, 'Erwähnt ')">
                                        <xsl:text>mentions</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="starts-with($this, 'Steht in einem Überlieferungszusammenhang mit ')">
                                        <xsl:text>relatedToTraditionOf</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="matches(.,'(Wohl |Möglicherweise )?[vV]ersendet bis .+ mit\s|(Wohl |Möglicherweise )?[vV]ersendet von .+ (bis|nach) .+ mit\s')">
                                        <xsl:text>sentWith</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="position() le 2 and xs:integer($this) lt $letter-no">
                                        <xsl:text>prev</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="position() le 2 and xs:integer($this) gt $letter-no">
                                        <xsl:text>next</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>UNKNOWN</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="this-label-removed" select="replace(.,'[^\d+,]','')"/>
                            <xsl:choose>
                                <xsl:when test="contains($this-label-removed,',')">
                                    <xsl:for-each select="tokenize($this-label-removed, '\s*,\s*')">
                                        <ref type="{$type}">
                                            <idno type="pezEd"><xsl:value-of select="normalize-space(.)"/></idno>
                                        </ref>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <ref type="{$type}"><idno type="pezEd"><xsl:value-of select="$this-label-removed"/></idno></ref>
                                </xsl:otherwise>
                            </xsl:choose>
                            <!--<xsl:analyze-string select="." regex="(Erwähnt in\s|Erwähnt\s|Steht in einem Überlieferungszusammenhang mit\s|(Wohl |Möglicherweise )?[vV]ersendet bis .+ mit\s|(Wohl |Möglicherweise )?[vV]ersendet von .+ (bis|nach) .+ mit\s)?(\d+)( oder (\d+))?(\s\(\?\))?[\.,]">
                                <xsl:matching-substring>
                                    <ref>
                                        <xsl:if test="regex-group(9) = ' (?)'">
                                            <xsl:attribute name="cert">low</xsl:attribute>
                                        </xsl:if>
                                        <xsl:choose>
                                            <xsl:when test="regex-group(1) != ''">
                                                <xsl:attribute name="type">
                                                    <xsl:choose>
                                                        <xsl:when test="regex-group(1) = 'Erwähnt in '">
                                                            <xsl:text>mentionedIn</xsl:text>
                                                        </xsl:when>
                                                        <xsl:when test="regex-group(1) = 'Erwähnt '">
                                                            <xsl:text>mentions</xsl:text>
                                                        </xsl:when>
                                                        <xsl:when test="regex-group(1) = 'Steht in einem Überlieferungszusammenhang mit '">
                                                            <xsl:text>relatedToTraditionOf</xsl:text>
                                                        </xsl:when>
                                                        <xsl:when test="contains(lower-case(regex-group(1)), 'versendet')">
                                                            <xsl:text>sentWith</xsl:text>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:text>UNKNOWN</xsl:text>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:attribute>
                                                <!-\-<label><xsl:value-of select="regex-group(1)"/></label>-\->
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:attribute name="type">relatedTo</xsl:attribute>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <idno><xsl:value-of select="regex-group(5)"/></idno>
                                        <xsl:if test="regex-group(6) != ''">
                                            <xsl:text> oder </xsl:text> 
                                            <idno><xsl:value-of select="regex-group(7)"/></idno>
                                        </xsl:if>
                                    </ref>
                                </xsl:matching-substring>
                                <xsl:non-matching-substring>
                                    <xsl:if test="normalize-space(.) != ''">
                                        <xsl:message select="." terminate="yes"></xsl:message>
                                    </xsl:if>
                                </xsl:non-matching-substring>
                            </xsl:analyze-string>-->
                        </xsl:for-each>
                    </correspContext>
                </xsl:when>
                <xsl:when test="starts-with(., 'Überlieferung')">
                    <xsl:choose>
                        <xsl:when test="matches(., '^Überlieferung: (I+), (\d+[rv]?([–-]\d*[rv])?)\.$')">
                            <div type="msDesc">
                                <xsl:analyze-string select="." regex="^Überlieferung: (I+), (\d+[rv]?([–-]\d*[rv])?)\.$">
                                    <xsl:matching-substring>
                                        <msDesc>
                                            <msIdentifier>
                                                <institution>Stift Melk</institution>
                                                <repository>Stiftsbibliothek</repository>
                                                <idno type="signatory">???</idno>
                                            </msIdentifier>
                                        </msDesc>
                                        <bibl>
                                            <biblScope unit="volume"><xsl:value-of select="regex-group(1)"/></biblScope>
                                            <biblScope unit="page"><xsl:value-of select="regex-group(2)"/></biblScope>
                                        </bibl>
                                    </xsl:matching-substring>
                                    <xsl:non-matching-substring>
                                        <ab><xsl:value-of select="."/></ab>
                                    </xsl:non-matching-substring>
                                </xsl:analyze-string>
                            </div>
                        </xsl:when>
                        <!-- other formats of "Überlieferung" to be added here. -->
                        <xsl:otherwise>
                            <div type="msDesc">
                                <p><xsl:value-of select="normalize-space(substring-after(., 'Überlieferung:'))"/></p>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="matches(.,'^Literatur:')">
                    <relatedItem type="secondaryLiterature">
                        <listBibl>
                            <head>Literatur</head>
                            <xsl:for-each select="tokenize(substring-after(.,'Literatur:'), ';')">
                                <bibl><xsl:value-of select="normalize-space(replace(.,'\.$',''))"/></bibl>
                            </xsl:for-each>
                        </listBibl>
                    </relatedItem>
                </xsl:when>
                <xsl:when test="starts-with(., 'Edition:')">
                    <relatedItem type="otherEdition">
                        <bibl><xsl:value-of select="substring-after(., 'Edition:')"/></bibl>
                    </relatedItem>
                </xsl:when>
                <xsl:when test="starts-with(., 'Adresse:')">
                    <div type="address">
                        <cit><q><xsl:value-of select="substring-after(., 'Adresse: ')"/></q></cit>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>
    
    <xsl:template name="tag-lemma">
        <xsl:param name="notes" as="element(tei:note)+"/>
        <xsl:param name="text-tagged" as="item()*"/>
        <xsl:variable name="note" select="$notes[1]"/>
        <xsl:if test="not(exists($note/tei:label))">
            <xsl:message terminate="no" select="$note"></xsl:message>
            <xsl:message>No lemma found in note</xsl:message>
        </xsl:if>
        <xsl:variable name="lemmaRegex" select="if (contains($note/tei:label, '...')) then replace($note/tei:label, ' ... ','.+') else $note/tei:label"/>
        <xsl:variable name="lemma-applied" as="item()*">
            <xsl:for-each select="$text-tagged">
                <xsl:choose>
                    <xsl:when test=". instance of text()">
                        <xsl:analyze-string select="." regex="{$lemmaRegex}">
                            <xsl:matching-substring>
                                <seg type="lemma" corresp="{$note/concat('#',@xml:id)}"><xsl:value-of select="."/></seg>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="not($lemma-applied/self::tei:seg)">
            <xsl:message>lemma regex <xsl:value-of select="$lemmaRegex"/> not found in "<xsl:value-of select="string-join($text-tagged,'')"/>"</xsl:message>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="count($notes) gt 1">
                <xsl:call-template name="tag-lemma">
                    <xsl:with-param name="notes" select="subsequence($notes, 2)"/>
                    <xsl:with-param name="text-tagged" select="$lemma-applied"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$lemma-applied"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="text()[ancestor::tei:div[@type = 'regest']]" mode="tagPersAbbrs">
        <xsl:variable name="this" select="."/>
        <xsl:variable name="regex">
            <xsl:text>(^|\s)(</xsl:text>
            <xsl:value-of select="string-join(for $s in $sigla//tei:*[@full='abb'] return concat($s, 's?'),'|')"/>
            <xsl:text>)(\s|$)</xsl:text>
        </xsl:variable>        
        <xsl:analyze-string select="." regex="{$regex}">
            <xsl:matching-substring>
                <xsl:variable name="this" select="."/>
                <xsl:variable name="person" select="$sigla//tei:*[@full='abb'][matches(., concat($this,'s?'))]"/>
                <xsl:value-of select="regex-group(1)"/><rs type="person" key=""><xsl:value-of select="regex-group(2)"/></rs><xsl:value-of select="regex-group(3)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:variable name="sender" select="$this/ancestor::tei:TEI[1]//sender"/>
                <xsl:variable name="recipient" select="$this/ancestor::tei:TEI[1]//recipient"/>
                <xsl:variable name="senderAbbr">
                    <xsl:if test="not(starts-with($sender, 'NN'))">
                        <xsl:value-of select="string-join(for $t in tokenize($sender,'\s') return substring($t,1,1), '')"/>
                        <xsl:text>s?</xsl:text>
                    </xsl:if>
                </xsl:variable>
                <xsl:variable name="recipientAbbr">
                    <xsl:if test="not(starts-with($recipient, 'NN'))">
                        <xsl:value-of select="string-join(for $t in tokenize($recipient,'\s') return substring($t,1,1), '')"/>
                        <xsl:text>s?</xsl:text>
                    </xsl:if>
                </xsl:variable>
                <xsl:variable name="regex">
                    <xsl:text>(^|\s)</xsl:text>
                    <xsl:choose>
                        <xsl:when test="count(($senderAbbr, $recipientAbbr)[. != '']) gt 1">
                            <xsl:text>(</xsl:text>
                            <xsl:value-of select="string-join(($senderAbbr, $recipientAbbr), '|')"/>
                            <xsl:text>)</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>(</xsl:text>
                            <xsl:value-of select="($senderAbbr, $recipientAbbr)[.!=''][1]"/>
                            <xsl:text>)</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>(\s|$)</xsl:text>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="count(($senderAbbr, $recipientAbbr)[. != '']) ge 1">
                        <xsl:variable name="role">
                            <xsl:choose>
                                <xsl:when test="$senderAbbr != ''">sender</xsl:when>
                                <xsl:when test="$recipientAbbr != ''">recipient</xsl:when>
                                <xsl:otherwise>mentioned</xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:analyze-string select="." regex="{$regex}">
                            <xsl:matching-substring>
                                <xsl:value-of select="regex-group(1)"/><rs type="person" role="{$role}"><xsl:value-of select="regex-group(2)"/></rs><xsl:value-of select="regex-group(3)"/>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template match="tei:text" mode="splitParts">
        <xsl:copy>
            <front>
                <xsl:sequence select="tei:div[@type = ('regest', 'editorialNote')]"/>
            </front>
            <body>
                <xsl:choose>
                    <xsl:when test="exists(tei:div[@type = 'edition'])">
                        <xsl:sequence select="tei:div[@type = 'edition']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <ab><gap reason="inferred letter"></gap></ab>
                    </xsl:otherwise>
                </xsl:choose>
            </body>
            <back>
                <xsl:sequence select="tei:div[@type = 'commentary']"/>
            </back>
        </xsl:copy>    
    </xsl:template>
    
    <xsl:template match="tei:xenoData" mode="xenoData2correspDesc">
        <correspDesc>
            <correspAction type="sent">
                <xsl:apply-templates select="sender|place-of-posting|date" mode="#current"/>
            </correspAction>
            <correspAction type="received">
                <xsl:apply-templates select="recipient|destination" mode="#current"/>
            </correspAction>
        </correspDesc>
    </xsl:template>
    
    <xsl:template match="tei:publicationStmt" mode="xenoData2correspDesc">
        <xsl:copy>
            <xsl:copy-of select="@*|node()"/>
            <idno type="pezEd"><xsl:value-of select="root()//tei:xenoData/id"/></idno>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="date" mode="xenoData2correspDesc">
        <date when="{.}"><xsl:value-of select="."/></date>
    </xsl:template>
    
    <xsl:template match="sender|recipient" mode="xenoData2correspDesc">
        <xsl:choose>
            <xsl:when test="matches(., '^NN\s\(')">
                <xsl:analyze-string select="." regex="^NN\s\((.+)\)">
                    <xsl:matching-substring>
                        <orgName type="monastery"><xsl:value-of select="regex-group(1)"/></orgName>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test=". != ''">
                <persName><xsl:value-of select="."/></persName>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="destination|place-of-posting" mode="xenoData2correspDesc">
        <xsl:if test=". != ''">
            <placeName><xsl:value-of select="."/></placeName>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:correspDesc" mode="correspDesc2profileDesc"/>
    <xsl:template match="tei:correspContext" mode="correspDesc2profileDesc"/>
        
    
    <xsl:template match="tei:profileDesc" mode="correspDesc2profileDesc">
        <xsl:copy>
            <xsl:copy-of select="@*|node()"/>
            <correspDesc>
                <xsl:copy-of select="root()//tei:correspDesc/*"/>
                <xsl:copy-of select="root()//tei:correspContext"/>
            </correspDesc>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@when[matches(., '&lt;\s\d{4,4}-\d{2,2}-\d{2,2}')]" mode="correctDates">
        <xsl:attribute name="notBefore"><xsl:value-of select="substring-after(., '&lt; ')"/></xsl:attribute>
    </xsl:template>
    
    
    <xsl:template match="tei:notesStmt" mode="addNotesStmt">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
            <xsl:copy-of select="root()//tei:text//tei:relatedItem"/>
            <xsl:if test="matches(root()/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'main'],'LE\s\d+')">
                <xsl:analyze-string select="root()/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'main']" regex="LE\s+(\d+)">
                    <xsl:matching-substring>
                        <relatedItem type="inferedFrom">
                            <bibl>
                                <author>Bernhard Pez</author>
                                <title>Littera encyclica <xsl:value-of select="regex-group(1)"/></title>
                            </bibl>
                        </relatedItem>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring/>
                </xsl:analyze-string>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:sourceDesc" mode="addNotesStmt">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="//tei:div[@type = 'msDesc']/*">
                    <xsl:sequence select="//tei:div[@type = 'msDesc']/*"/>
                </xsl:when>
                <xsl:otherwise>
                    <p>No direct source, inferred letter.</p>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:relatedItem[ancestor::tei:text]" mode="addNotesStmt"/>
    <xsl:template match="tei:div[@type = 'msDesc']" mode="addNotesStmt"/>
        
    
    
    
    
    
</xsl:stylesheet>