<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="2.0">
    <xsl:param name="path-to-tmp-bibl">file:/home/dschopper/data/pez-edition/102_derived_tei/102_04_auxiliary_files/bibliography.xml</xsl:param>
    <xsl:variable name="tmp-bibl" select="doc($path-to-tmp-bibl)"/>
    <xsl:key name="tmp-bibl-enty-by-shortTitlte" match="bibl" use="title"/>
    <xsl:output method="xml" indent="yes"/>
    
    <!-- 1) Export TEI-XML (including XML:ids and Tags) from Zotero
         2) Run through this XSLT – the xml:ids on tei:biblStruct will be replaced by the temporary IDs from ${pdu}/102_derived_tei/102_04_auxiliary_files/bibliography.xml 
    -->
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:biblStruct">
        <xsl:variable name="shortTitle" select="descendant::tei:title[@type='short']"/>
        <xsl:variable name="tmp-bibl-entry" select="key('tmp-bibl-enty-by-shortTitlte', $shortTitle, $tmp-bibl)"/>
        <xsl:copy>
            <xsl:copy-of select="@* except @xml:id"/>
            <xsl:choose>
                <xsl:when test="count($tmp-bibl-entry) gt 1">
                    <xsl:attribute name="xml:id" select="concat('b',$tmp-bibl-entry[1]/idno)"/>
                    <xsl:comment>CHECKME: More than one entries found for this short title, taking I of first one</xsl:comment>
                </xsl:when>
                <xsl:when test="count($tmp-bibl-entry) eq 1">
                    <xsl:attribute name="xml:id" select="concat('b',$tmp-bibl-entry/idno)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>NO ENTRY FOUND by short title "<xsl:value-of select="$shortTitle"/>"</xsl:message>
                    <xsl:copy-of select="@xml:id"/>
                    <xsl:comment>This entry was not found in the temp bibliography!</xsl:comment>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>