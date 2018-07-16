<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:_="urn:acdh"
    exclude-result-prefixes="#all"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="output-format">single</xsl:param>
    <xsl:param name="img-path-steps" select="tokenize(base-uri(),'/')"/>
    <xsl:param name="img-path" select="string-join(($img-path-steps[position() lt count($img-path-steps)],'_verz_einh'),'/')"/>
    <xsl:function name="_:category" as="item()*">
        <xsl:param name="bild" as="element(bild)"/>
        <xsl:variable name="id" select="$bild/@id"/>
        <xsl:sequence select="$entries[@id = $id]/cat"/>
    </xsl:function>
    <xsl:function name="_:title" as="item()*">
        <xsl:param name="bild" as="element(bild)"/>
        <xsl:variable name="id" select="$bild/@id"/>
        <xsl:sequence select="$entries[@id = $id]/title"/>
    </xsl:function>
    <xsl:param name="path-to-tsv">../001_src/Nachlass/PEZ_Nachlass_Kategorisierung_nach_RNA.tsv</xsl:param>
    <xsl:variable name="tsv" select="unparsed-text($path-to-tsv,'UTF-8')"/>
    <xsl:variable name="lines" select="tokenize($tsv,'\n')"/>
    <xsl:variable name="entries" as="item()+">
        <xsl:for-each select="$lines[position() gt 1]">
            <xsl:variable name="t" select="tokenize(.,'\t')" as="xs:string*"/>
            <entry xmlns="" id="{tokenize($t[2],'/')[last()]}">
                <title><xsl:value-of select="normalize-space($t[1])"/></title>
                <link><xsl:value-of select="normalize-space($t[2])"/></link>
                <cat><xsl:value-of select="normalize-space($t[3])"/></cat>
            </entry>
        </xsl:for-each>
    </xsl:variable>
    <xsl:template match="/bilder">
        <xsl:choose>
            <xsl:when test="$output-format = 'corpus'">
                <xsl:processing-instruction name="xml-model">href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_ms.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction> 
                <xsl:processing-instruction name="xml-model">href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_ms.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
                <teiCorpus xmlns="http://www.tei-c.org/ns/1.0">
                    <teiHeader>
                        <fileDesc>
                            <titleStmt>
                                <title>Pez Nachlass Handschriftenbeschreibungen</title>
                                <!-- TODO andere Verantwortliche ergänzen -->
                                <respStmt>
                                    <resp>Automatische Konvertierung nach TEI</resp>
                                    <persName xml:id="ds">Daniel Schopper</persName>
                                </respStmt>
                            </titleStmt>
                            <publicationStmt>
                                <p>unpublished, intermediate version</p>
                            </publicationStmt>
                            <sourceDesc>
                                <p>Automatisch konveritert aus UNIDAM-Export</p>
                            </sourceDesc>
                        </fileDesc>
                    </teiHeader>
                    <xsl:for-each-group select="bild" group-by="_:category(.)">
                        <group>
                            <head><xsl:value-of select="current-grouping-key()"/></head>
                            <xsl:variable name="category" select="_:category(.)"/>
                            <xi:include href="msDesc/{replace($category,'\s+','_')}/{@id}.xml" xmlns:xi="http://www.w3.org/2003/XInclude"/>
                            <xsl:result-document href="msDesc/{replace($category,'\s+','_')}/msDesc_{@id}.xml">
                                <xsl:apply-templates select=".">
                                    <xsl:with-param name="category" select="$category" tunnel="yes"/>
                                </xsl:apply-templates>
                            </xsl:result-document>
                        </group>
                    </xsl:for-each-group>                    
                </teiCorpus>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="bild">
                    <xsl:variable name="category" select="_:category(.)"/>
                    <xsl:result-document href="msDesc/{replace($category,'\s+','_')}/msDesc_{@id}.xml">
                        <xsl:processing-instruction name="xml-model">href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_ms.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction> 
                        <xsl:processing-instruction name="xml-model">href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_ms.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
                        <xsl:apply-templates select=".">
                            <xsl:with-param name="category" select="$category" tunnel="yes"/>
                        </xsl:apply-templates>
                    </xsl:result-document>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="bild">
        <xsl:param name="category" tunnel="yes"/>
        <xsl:variable name="verz_einh_id" select="verz_einh/@id"/>
        <xsl:variable name="path-to-folgeseiten" select="concat($img-path,'/',$verz_einh_id,'.xml')"/>        
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title type="main"><xsl:value-of select="titel"/></title>
                        <title type="sub">Digital Manuscript description</title>
                    </titleStmt>
                    <publicationStmt>
                        <publisher>Austrian Center for Digital Humanities</publisher>
                        <idno type="unidam-verz_einh"><xsl:value-of select="$verz_einh_id"/></idno>
                    </publicationStmt>
                    <sourceDesc>
                        <msDesc xml:lang="de">
                            <msIdentifier>
                                <xsl:for-each select="tokenize(standort,'\s*&gt;\s*')">
                                    <xsl:choose>
                                        <xsl:when test="position() eq 1">
                                            <country><xsl:value-of select="."/></country>
                                        </xsl:when>
                                        <xsl:when test="position() eq 2">
                                            <settlement><xsl:value-of select="."/></settlement>
                                        </xsl:when>
                                        <xsl:when test="position() eq 3">
                                            <institution><xsl:value-of select="."/></institution>
                                        </xsl:when>
                                        <xsl:when test="position() eq 4">
                                            <repository><xsl:value-of select="."/></repository>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:for-each>
                                <idno><xsl:value-of select="replace(verz_einh,'\s*&gt;\s*',' ')"/></idno>
                            </msIdentifier>
                            <msContents>
                                <xsl:variable name="parts" select="tokenize(beschr,'\n')[.!='']"/>
                                <summary><xsl:value-of select="$parts[1]"/></summary>
                                <xsl:for-each select="$parts[matches(.,'^\s*\d+\)')]">
                                    <msItem>
                                        <xsl:attribute name="n">
                                            <xsl:analyze-string select="." regex="^\s*(\d+)">
                                                <xsl:matching-substring>
                                                    <xsl:value-of select="regex-group(1)"/>
                                                </xsl:matching-substring>
                                            </xsl:analyze-string>
                                        </xsl:attribute>
                                        <locus><xsl:value-of select="replace(substring-before(.,':'),'\s*\d+\)\s*','')"/></locus>
                                        <bibl>
                                            <xsl:analyze-string select="normalize-space(substring-after(.,':'))" regex="^(.+?),">
                                                <xsl:matching-substring>
                                                    <author><xsl:value-of select="normalize-space(regex-group(1))"/></author>
                                                </xsl:matching-substring>
                                                <xsl:non-matching-substring>
                                                    <xsl:analyze-string select="." regex='"(.+?)"'>
                                                        <xsl:matching-substring>
                                                            <title><xsl:value-of select="regex-group(1)"/></title>
                                                        </xsl:matching-substring>
                                                        <xsl:non-matching-substring>
                                                            <xsl:value-of select="."/>
                                                        </xsl:non-matching-substring>
                                                    </xsl:analyze-string>
                                                </xsl:non-matching-substring>
                                            </xsl:analyze-string>
                                        </bibl>
                                    </msItem>
                                </xsl:for-each>
                            </msContents>
                            <physDesc>
                                <objectDesc>
                                    <supportDesc>
                                        <foliation><xsl:value-of select="foliierungsverlauf"/></foliation>
                                    </supportDesc>
                                </objectDesc>
                            </physDesc>
                            <history>
                                <origin>
                                    <date>
                                        <xsl:value-of select="datierung"/>
                                    </date>
                                    <note>
                                        <xsl:value-of select="datierung_zusatz"/>
                                    </note>
                                </origin>
                            </history>
                            <xsl:if test="literatur != ''">
                                <additional>
                                    <xsl:apply-templates select="literatur"/>
                                </additional>
                            </xsl:if>
                        </msDesc>
                    </sourceDesc>
                </fileDesc>
                <profileDesc>
                    <textClass>
                        <classCode scheme="RNA"><xsl:value-of select="$category"/></classCode>
                    </textClass>
                </profileDesc>
            </teiHeader>
            <facsimile>
                <surface xml:id="s{@id}" n="{normalize-space(foliierung)}">
                    <graphic url="http://unidam.univie.ac.at/id/{@id}"/>
                </surface>               
                <xsl:variable name="folgeseiten" select="if (doc-available($path-to-folgeseiten)) then doc($path-to-folgeseiten)//bild else ()" as="element(bild)*"/>
                <xsl:for-each select="$folgeseiten">
                    <xsl:sort select="@id" order="ascending"/>
                    <surface xml:id="s{@id}" n="{normalize-space(foliierung_paginierung)}">
                        <graphic url="http://unidam.univie.ac.at/id/{@id}"/>
                    </surface>          
                </xsl:for-each>
            </facsimile>
        </TEI>
    </xsl:template>
    <xsl:template match="literatur">
        <listBibl xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="tokenize(., ';')">
                <bibl><xsl:value-of select="normalize-space(.)"/></bibl>
            </xsl:for-each>
        </listBibl>
    </xsl:template>
</xsl:stylesheet>