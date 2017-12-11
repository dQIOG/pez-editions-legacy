<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
    <xsl:template match="@xml:id" priority="100">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="element()">
        <xsl:element name="{local-name()}" namespace="">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="comment() | processing-instruction() | document-node() | @*">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:item[not(tei:term)]">
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*" copy-namespaces="no"/>
            <term>
                <xsl:if test="xs:integer(../@n) gt 1">
                    <xsl:for-each select="1 to xs:integer(../@n) - 1">
                        <xsl:text>> </xsl:text>
                    </xsl:for-each>
                </xsl:if>
                <xsl:value-of select="tei:ref[not(@type = 'letter')]"/>
            </term>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>