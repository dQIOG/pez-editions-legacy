<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    version="2.0">
    <xsl:output indent="yes"/>
    <xsl:template match="/">
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>REGISTER</title>
                        <author>Wallnig</author>
                    </titleStmt>
                    <editionStmt>
                        <edition><date>2015-12-22</date></edition>
                    </editionStmt>
                    <publicationStmt>
                        <p>unknown</p>
                    </publicationStmt>
                    <sourceDesc>
                        <p>Converted from a Word document</p>
                    </sourceDesc>
                </fileDesc>
                <encodingDesc>
                    <appInfo>
                        <application xml:id="docxtotei" ident="TEI_fromDOCX" version="2.15.0">
                            <label>DOCX to TEI</label>
                        </application>
                    </appInfo>
                </encodingDesc>
                <revisionDesc>
                    <listChange>
                        <change><date>2016-03-22T01:03:57Z</date><name>Wallnig</name></change>
                    </listChange>
                </revisionDesc>
            </teiHeader>
            <text>
                <body>
                    <head>In der Korrespondenz erwähnte Handschriften und Urkunden nach heutigen Aufbewahrungsorten</head>
                    <xsl:for-each-group select="//p[preceding-sibling::p[@rend = 'Überschrift Ebene 2'][1] = 'III  In der Korrespondenz erwähnte Handschriften und Urkunden nach heutigen Aufbewahrungsorten']" group-starting-with="p[not(starts-with(., '—'))]">
                        <xsl:apply-templates select="current-group()[position() gt 1]">
                            <xsl:with-param name="place" select="current-group()[1]/normalize-space(.)" as="xs:string"/>
                        </xsl:apply-templates>
                    </xsl:for-each-group>
                </body>
            </text>
        </TEI>            
    </xsl:template>
    
    <xsl:template match="p">
        <xsl:param name="place" as="xs:string"/>
        <xsl:variable name="idno">
            <xsl:analyze-string select="." regex="^—\s*(.+?)    (\d+\.\s?)+$">
                <xsl:matching-substring><xsl:value-of select="normalize-space(regex-group(1))"/></xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <msDesc>
            <msIdentifier>
                <xsl:analyze-string select="$place" regex="^(.+)\s*\((.+)\)">
                    <xsl:matching-substring>
                        <settlement><xsl:value-of select="normalize-space(regex-group(1))"/></settlement>
                        <institution><xsl:value-of select="normalize-space(regex-group(2))"/></institution>
                    </xsl:matching-substring>
                </xsl:analyze-string>
                <idno><xsl:value-of select="replace($idno, '\.$','')"/></idno>
            </msIdentifier>
            <additional>
                <listBibl>
                    <xsl:for-each select="tokenize(normalize-space(substring-after(.,$idno)),'\s+')">
                        <bibl type="letter"><xsl:value-of select="replace(substring-before(.,'.'),'[&#x00A0;\s\t]+','')"/></bibl>
                    </xsl:for-each>
                </listBibl>
            </additional>            
        </msDesc>
    </xsl:template>
</xsl:stylesheet>