<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    
    
    <xsl:template match="TEI">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="front/*|body/*|back/*">
        <div class="{@type}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="p">
        <p><xsl:apply-templates/></p>
    </xsl:template>
    
    <xsl:template match="pb">
        <span class="{local-name()}">[<xsl:value-of select="."/>]</span>
    </xsl:template>
    
    <xsl:template match="seg">
        <span class="{local-name()}" id="{generate-id()}">
            <xsl:value-of select="concat('&lt;',@n,'>')"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
</xsl:stylesheet>