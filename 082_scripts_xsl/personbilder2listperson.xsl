<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">
    <xsl:output indent="yes"/>
    <xsl:param name="baseUri" select="'https://id.acdh.oeaw.ac.at/pez/pez-nachlass/'"/>
    <xsl:param name="idnoDoc" select="'../001_src/Personen_IR-bearbeitet_TW20180724.xml'"></xsl:param>
    <xsl:variable name="idnos" select="doc($idnoDoc)"/>
    <xsl:template match="/">
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>Title</title>
                    </titleStmt>
                    <publicationStmt>
                        <p>Publication Information</p>
                    </publicationStmt>
                    <sourceDesc>
                        <p>Information about the source</p>
                    </sourceDesc>
                </fileDesc>
            </teiHeader>
            <text>
                <body>
                    <p>Some text here.</p>
                    <listPerson>
                        <xsl:for-each select="//Person[./@id]">
                            <xsl:variable name="personId">
                                <xsl:value-of select="data(./@id)"/>
                            </xsl:variable>
                            <xsl:variable name="idno">
                                <xsl:value-of select="$idnos//row[
                                    descendant::MatchedPersonID/text() = $personId and descendant::Status/text() = 's' and descendant::ManualGND/text()
                                    ][1]/ManualGND/text()"/>
                            </xsl:variable>
                            <person>
                                <xsl:attribute name="xml:id">
                                    <xsl:value-of select="concat('person__', $personId)"/>
                                </xsl:attribute>
                                <persName>
                                    <persName type="pref">
                                        <xsl:value-of
                                            select="normalize-space(concat(@vorname, ' ', @name))"/>
                                    </persName>
                                    <persName>
                                        <forename>
                                            <xsl:value-of select="data(@vorname)"/>
                                        </forename>
                                        <xsl:if test="data(@name)">
                                            <surname>
                                                <xsl:value-of select="data(@name)"/>
                                            </surname>
                                        </xsl:if>
                                    </persName>
                                </persName>
                                <xsl:if test="starts-with($idno, 'http')">
                                    <idno type="GND">
                                        <xsl:value-of select="tokenize($idno, ' ')[last()]"/>
                                    </idno>
                                </xsl:if>
                                <xsl:for-each select=".//Bild">
                                    <xsl:if test="data(./@relation)">
                                        <ptr>
                                            <xsl:attribute name="target">
                                                <xsl:value-of select="concat($baseUri, 'msDesc_', data(@bildid), '.xml') "/>
                                            </xsl:attribute>
                                            <xsl:attribute name="type">
                                                <xsl:value-of select="lower-case(tokenize(data(@relation), ' ')[1])"/>
                                            </xsl:attribute>
                                        </ptr>
                                    </xsl:if>
                                </xsl:for-each>
                                
                            </person>
                        </xsl:for-each>
                    </listPerson>
                </body>
            </text>
        </TEI>
    </xsl:template>

</xsl:stylesheet>
