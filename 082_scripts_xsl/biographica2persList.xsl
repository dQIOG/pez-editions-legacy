<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:saxon="http://saxon.sf.net/"
    exclude-result-prefixes="#all" 
    version="2.0" 
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    saxon:suppress-indentation="bibl">
    <xsl:output method="xml" indent="yes"/>
    
    
    <xsl:param name="path-to-biographica-vol1">file:/C:/Users/Daniel/data/pez-edition/001_src/Biographica_formatiert_20090717-TEI-P5.xml</xsl:param>
    <xsl:param name="path-to-biographica-vol2">file:/C:/Users/Daniel/data/pez-edition/001_src/03_Biographica_Endphase-TEI-P5.xml</xsl:param>
    <xsl:variable name="vol1" select="doc($path-to-biographica-vol1)"/>
    <xsl:variable name="vol2" select="doc($path-to-biographica-vol2)"/>
    <xsl:variable name="vol1-grouped">
        <xsl:apply-templates select="$vol1" mode="group"/>
    </xsl:variable>
    <xsl:variable name="vol2-grouped">
        <xsl:apply-templates select="$vol2" mode="group"/>
    </xsl:variable>
    
    <xsl:template match="node() | @*" mode="group inBio inLit">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="body" mode="group">
        <xsl:copy>
            <xsl:for-each-group select="p[starts-with(@rend, 'Biographica')]" group-starting-with="*[@rend = 'Biographica Fließtext']">
                <xsl:if test="current-group()[1]/@rend = 'Biographica Fließtext'">
                    <div type="bio" about="{normalize-space(current-group()[1]/substring-before(.,'('))}">
                        <xsl:apply-templates select="current-group()" mode="inBio"/>
                    </div>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="p[@rend = 'Biographica Fließtext']" mode="inBio">
        <p><xsl:apply-templates mode="#current"/></p>
    </xsl:template>
    
    <xsl:template match="p[@rend = 'Biographica Literatur']" mode="inBio">
        <listBibl><xsl:for-each-group select="node()" group-starting-with="hi[@rend = 'smallcaps']"><bibl><xsl:apply-templates select="current-group()" mode="inLit"/></bibl></xsl:for-each-group></listBibl>
    </xsl:template>
    
    <xsl:template match="hi[@rend = 'smallcaps']" mode="inLit">
        <author><xsl:apply-templates/></author>
    </xsl:template>
    
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="bibl">
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:space"/>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/">
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>Biographica zu den Pez-Korrespondenten</title>
                        <author><persName><forename>Thomas</forename><surname>Stockinger</surname></persName></author>
                        <author><persName><forename>Thomas</forename><surname>Wallnig</surname></persName></author>
                    </titleStmt>
                    <publicationStmt>
                        <p>unknown</p>
                    </publicationStmt>
                    <sourceDesc>
                        <p>Converted from two Word documents</p>
                    </sourceDesc>
                </fileDesc>
            </teiHeader>
            <text>
                <body>
                    <listPerson>
                        <head>Korrespondenten von Bernhard und Hieronymus Pez 1709-1718</head>
                        <xsl:for-each-group select="($vol1-grouped, $vol2-grouped)//div[@type = 'bio']" group-by="@about">
                            <person>
                                <persName><xsl:value-of select="current-grouping-key()"/></persName>
                                <xsl:choose>
                                    <xsl:when test="(current-group()/p)[1] eq (current-group()/p)[2]">
                                        <xsl:apply-templates select="(current-group()/p)[1]"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="current-group()/p"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="not(current-group()/listBibl)"/>
                                    <xsl:when test="count(current-group()/listBibl) eq 2">
                                        <listBibl>
                                            <xsl:variable name="bibls" select="current-group()/listBibl/bibl" as="element(bibl)*"/>
                                            <xsl:for-each select="distinct-values(current-group()/listBibl/bibl)">
                                                <xsl:variable name="thisBibl" select="."/>
                                                <xsl:copy-of select="subsequence($bibls[. eq $thisBibl],1)"/>
                                            </xsl:for-each>
                                        </listBibl>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="current-group()/listBibl"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </person>
                        </xsl:for-each-group>
                    </listPerson>
                </body>
            </text>
        </TEI>
    </xsl:template>
    
    <xsl:template match="p">
        <note><xsl:apply-templates/></note>
    </xsl:template>
    
    
</xsl:stylesheet>
