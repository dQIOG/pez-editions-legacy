<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    <xsl:output method="xml" indent="yes"></xsl:output>
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="list[@n = '1'][not(contains(head,'Personen'))]">
        <xsl:sequence select="."/>
    </xsl:template>
    <xsl:template match="list[@n = '1'][contains(head,'Personen')]">
        <xsl:for-each-group select="item" group-by="substring(replace(term,'(\[.+\]|\P{L}|\s+)',''),1,1)" collation="http://saxon.sf.net/collation?lang=de;ignore-case=yes;ignore-modifiers=yes;ignore-symbols=yes">
            <xsl:sort select="current-grouping-key()"/>
            <xsl:if test="current-grouping-key() != ''">
                <xsl:result-document href="{replace(tokenize(base-uri(),'/')[last()],'\.xml$','')}\{current-grouping-key()}.xml" method="xml" indent="no">
                    <xsl:processing-instruction name="xml-stylesheet">type="text/css" href="../index.css"</xsl:processing-instruction>
                    <TEI>
                        <teiHeader>
                            <fileDesc>
                                <titleStmt>
                                    <title type="main">Die gelehrte Korrespondenz der Brüder Pez, Text, Regesten, Kommentare; Band 1: 1709–1715 - Register</title>
                                    <title type="sub"><xsl:value-of select="upper-case(current-grouping-key())"/></title>
                                    <xsl:copy-of select="root()//titleStmt/*[not(self::title)]"/>
                                </titleStmt>
                                <xsl:copy-of select="root()//teiHeader/fileDesc/*[not(self::titleStmt)]"/>
                            </fileDesc>
                            <xsl:copy-of select="root()//teiHeader/*[not(self::fileDesc)]"/>
                        </teiHeader>
                        <text>
                            <body>
                                <list n="1">
                                    <head><xsl:value-of select="upper-case(current-grouping-key())"/></head>
                                    <xsl:sequence select="current-group()"/>
                                </list>
                            </body>
                        </text>
                    </TEI>
                </xsl:result-document>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>
    
    
</xsl:stylesheet>