<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="body">
        <body>
            <list>
            <xsl:for-each-group select="*" group-starting-with="p[starts-with(@rend, 'Bibliographie Standort')]">
                <xsl:choose>
                    <xsl:when test="current-group()[1]/@rend = 'Bibliographie Standort'">
                        <item>
                            <placeName><xsl:value-of select="current-group()/self::p[@rend = 'Bibliographie Standort']"/></placeName>
                            <list type="archives">
                                <xsl:for-each-group select="current-group() except self::p[@rend = 'Bibliographie Standort']" group-starting-with="p[@rend = 'Bibliographie Archivname']">
                                    <item>
                                        <orgName><xsl:value-of select="current-group()/self::p[@rend = 'Bibliographie Archivname']"/></orgName>
                                        <list type="items">
                                            <xsl:for-each select="current-group() except self::p[@rend = 'Bibliographie Archivname']">
                                                <item>
                                                    <xsl:value-of select="."/>
                                                </item>
                                            </xsl:for-each>
                                        </list>
                                    </item>
                                </xsl:for-each-group>
                            </list>
                        </item>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="current-group()">
                            <head><xsl:value-of select="."/></head>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
            </list>
        </body>
    </xsl:template>
    
</xsl:stylesheet>