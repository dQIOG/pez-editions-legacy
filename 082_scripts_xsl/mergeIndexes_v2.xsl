<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:_="urn:pez"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs _"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
<!--    <xsl:preserve-space elements="*"/>-->
    <xsl:param name="path-to-vol1">file:/C:/Users/Daniel/data/pez-edition/102_derived_tei/102_02_extracted_index_entries/Pez_Register_Bd1.xml</xsl:param>
    <xsl:param name="path-to-vol2">file:/C:/Users/Daniel/data/pez-edition/102_derived_tei/102_02_extracted_index_entries/Pez_Register_Bd2.xml</xsl:param>
    <xsl:variable name="vol1" select="doc($path-to-vol1)"/>
    <xsl:variable name="vol2" select="doc($path-to-vol2)"/>
    <xsl:function name="_:filename">
        <xsl:param name="string"/>
        <xsl:value-of select="normalize-space(replace(replace($string,'[&#160;\s]','_'),'[\[\]\?\*]',''))"/>
    </xsl:function>
    
    <xsl:template match="/">
        <xsl:for-each-group select="($vol1//list[@n = 1], $vol2//list[@n = 1])" group-by="normalize-space(head)">
            <xsl:variable name="index-head" select="current-grouping-key()"/>
            <xsl:variable name="dirname" select="_:filename(current-grouping-key())"/>
            <xsl:for-each-group select="current-group()/item" group-by="term">
                <xsl:sort select="current-grouping-key()"/>
                <xsl:variable name="filename" select="concat(substring(normalize-space(_:filename(current-grouping-key())),1,40),'_',current-group()[1]/@xml:id)"/>
                <xsl:result-document href="../102_derived_tei/102_02_extracted_index_entries/{$dirname}/{$filename}.xml">
                    <item xml:id="{replace($filename,'^-','')}">
                        <xsl:copy-of select="current-group()/*"/>
                    </item>
                </xsl:result-document>
            </xsl:for-each-group>
        </xsl:for-each-group>
    </xsl:template>
</xsl:stylesheet>