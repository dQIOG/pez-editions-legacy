<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    version="2.0">
    <xsl:output indent="yes"/>
    <xsl:template match="/">
        <xsl:variable name="pass1" as="item()">
            <TEI xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of select="TEI/teiHeader"/>
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
        </xsl:variable>
        <xsl:apply-templates select="$pass1" mode="pass2"/>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="pass2">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="msDesc" mode="pass2">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="xml:id" select="concat('ms',count(preceding-sibling::msDesc) + 1)"/>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="p">
        <xsl:param name="place" as="xs:string"/>
        <xsl:variable name="idno">
            <xsl:analyze-string select="." regex="^—\s*(.+?)    (\d+\.\s?)+$">
                <xsl:matching-substring><xsl:value-of select="normalize-space(regex-group(1))"/></xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <msDesc xml:id="m{count(preceding-sibling::p)-6143}">
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