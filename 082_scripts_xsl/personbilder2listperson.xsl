<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">
    <xsl:output indent="yes"/>
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
                        <xsl:for-each select="//Person">
                            <person>
                                <xsl:attribute name="xml:id">
                                    <xsl:value-of select="concat('person__', data(@id))"/>
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
                            </person>
                        </xsl:for-each>
                    </listPerson>
                </body>
            </text>
        </TEI>
    </xsl:template>

</xsl:stylesheet>
