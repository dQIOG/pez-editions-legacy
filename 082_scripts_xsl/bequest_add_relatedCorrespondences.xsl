<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="#all"
    
    version="2.0">
    <!--<xsl:strip-space elements="*"/>
    <xsl:output method="xml" indent="yes"/>-->
    <xsl:output omit-xml-declaration="yes"/>
    <xsl:param name="path-to-unidam-md"/>
    <xsl:variable name="verz_einh" select="//tei:idno[@type = 'unidam-verz_einh']"/>
    <xsl:variable name="unidam-md" as="element(bild)" select="fn:doc($path-to-unidam-md)//bild[verz_einh/@id = $verz_einh]"/>
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$unidam-md/pez_br_z != ''">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:fileDesc/tei:publicationStmt[not(tei:notesStmt)]">
        <xsl:sequence select="."/>
        <xsl:if test="$unidam-md/pez_br_z != ''">
            <notesStmt xmlns="http://www.tei-c.org/ns/1.0">
                <note type="relatedCorrespondences"><xsl:value-of select="$unidam-md/pez_br_z"/></note>
            </notesStmt>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>