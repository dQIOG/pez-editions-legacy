<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:template match="item">
        <div class="{local-name()}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="hi">
        <xsl:variable name="style">
            <xsl:choose>
                <xsl:when test="@rend = 'italic'">
                    <xsl:text>font-style:italic;</xsl:text>
                </xsl:when>
                <xsl:when test="@rend = 'superscript'">
                    <xsl:text>vertical-align:super; font-size:smaller;</xsl:text>
                </xsl:when>
                <xsl:when test="@rend = 'subcript'">
                    <xsl:text>vertical-align:sub; font-size:smaller;</xsl:text>
                </xsl:when>
                <xsl:when test="@rend = 'smallcaps'">
                    <xsl:text>font-variant:small-caps;</xsl:text>
                </xsl:when>
                <xsl:when test="@rend = 'Strong'">
                    <xsl:text>font-weight:bold;</xsl:text>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <span>
            <xsl:if test="$style != ''">
                <xsl:attribute name="style" select="$style"/>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <xsl:template match="term|note">
        <span class="{local-name()}"><xsl:apply-templates select="node()"/></span>
    </xsl:template>
    
    <xsl:template match="bibl">
        <span class="bibl"><xsl:value-of select="string-join(biblScope/concat('S. ',.),', ')"/></span>
    </xsl:template>
</xsl:stylesheet>