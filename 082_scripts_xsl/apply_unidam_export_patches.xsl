<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="path-to-patch-file">file:/home/dschopper/data/pez-edition/102_derived_tei/102_07_bequest/unidam-export-patches.xml</xsl:param>
    
    <xsl:variable name="id" select="root()//tei:idno[@type = 'unidam-verz_einh']/xs:integer(.)"/>
    <xsl:variable name="patch-imgs" select="doc($path-to-patch-file)//verz_einh[xs:integer(@nr) = xs:integer($id)]/img"/>
    <xsl:variable name="patches" as="element()*">
        <xsl:for-each select="$patch-imgs">
            <surface xml:id="s{.}" n="{@n}">
                <graphic url="http://unidam.univie.ac.at/id/{.}"/>
            </surface>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    
    
    <xsl:template match="tei:facsimile">
        <xsl:variable name="surfaces" select="tei:surface"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <!-- just to make sure that we don't duplicate existing surfaces (in case this
                script has already been run), we group both the existing ones and the 
                constructed ones by ID and just take the first element in the group -->
            <xsl:for-each-group select="($patches, $surfaces)" group-by="@xml:id">
                <xsl:sort select="@xml:id"/>
                <xsl:sequence select="current-group()[1]"/>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>