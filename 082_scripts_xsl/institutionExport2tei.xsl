<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:s="urn:schemas-microsoft-com:office:spreadsheet"
    exclude-result-prefixes="xs s"
    xmlns:_="urn:acdh:pez"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="path-to-normdata-table">file:/C:/Users/Daniel/data/pez-edition/101_derived/Institutionen_IR-bearbeitet.xml</xsl:param>
    <!-- on the server-side we might have some updated data which we want to consider when re-running the transformation -->
    <xsl:param name="path-to-updated-data">oxygen:/eXist%202.2$exist-curation%20minerva%20(XMLRPC)/db/apps/pez/data/102_derived_tei/102_04_auxiliary_files/institutions.xml</xsl:param>
    <xsl:variable name="current-tax" select="if (doc-available($path-to-updated-data)) then doc($path-to-updated-data) else ()"/>
    <xsl:variable name="ids" select="doc($path-to-normdata-table)"/>
    <xsl:key name="institution-by-id" match="Institution" use="@id"/>
    <xsl:key name="institution-by-parent" match="Institution" use="@parent"/>
    <xsl:key name="current-category-by-id" match="tei:category" use="@xml:id"/>
    <xsl:key name="call-by-value" match="s:Cell" use="data(s:Data)"/>
    <xsl:template match="/">
        <xsl:variable name="tree">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:apply-templates select="$tree" mode="addIDs"/>
    </xsl:template>
    <xsl:template match="Institutionen">
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>Pez Digital: Institutionen</title>
                        <author>Thomas Wallnig</author>
                        <xsl:comment>...</xsl:comment>
                        <respStmt>
                            <resp>Converted to TEI</resp>
                            <persName>Daniel Schopper</persName>
                        </respStmt>
                    </titleStmt>
                    <publicationStmt>
                        <p>Under development, currently internal use only.</p>
                    </publicationStmt>
                    <sourceDesc>
                        <p>Born digital.</p>
                    </sourceDesc>
                </fileDesc>
                <encodingDesc>
                    <classDecl>
                        <taxonomy xml:id="institutions">
                            <desc>Pez-Edition: Institutionen</desc>
                            <xsl:apply-templates select="Institution[@parent = '']"/>
                        </taxonomy>
                    </classDecl>
                </encodingDesc>
            </teiHeader>
            <text>
                <body>
                    <p>This document contains a taxonomy in the TEI Header.</p>
                </body>
            </text>
        </TEI>
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="addIDs">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- only leaf nodes should have IDs -->
    <xsl:template match="tei:category[tei:category[not(tei:category)]]" mode="addIDs">
        <xsl:param name="rows-prefiltered" tunnel="yes"/>
        <xsl:variable name="this" select="."/>
        <xsl:variable name="ancestors" select="_:getAncestors(.)"/>
        <xsl:variable name="rows-prefiltered" select="_:filter(if (count($ancestors) eq 1) then $ids//s:Row else $rows-prefiltered, $this, count($ancestors))" as="item()*"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current">
                <xsl:with-param name="rows-prefiltered" select="$rows-prefiltered" tunnel="yes" as="item()*"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:category[not(tei:category)]" mode="addIDs">
        <xsl:param name="rows-prefiltered" as="item()*" tunnel="yes"/>
        <xsl:variable name="anc" select="_:getAncestors(.)"/>
        <!-- this is an institution, so we alsways take row 4 -->
        <xsl:variable name="rows" select="_:filter($rows-prefiltered, $anc[last()], count($anc)+1)"/>
        <xsl:variable name="rows-by-name" select="if (not(exists($rows))) then _:getRowsByName(@n) else ()"/>
        <xsl:copy>
            <xsl:copy-of select="@* except (@n|@status)"/>
            <xsl:attribute name="status" select="if (not($rows) and $rows-by-name) then 'watchstruct' else @status"/>
            <xsl:apply-templates select="node()" mode="#current">
                <xsl:with-param name="rows" select="if (exists($rows)) then $rows else $rows-by-name" as="item()*" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:category[not(tei:category)]/tei:catDesc" mode="addIDs">
        <xsl:param name="rows" as="item()*" tunnel="yes"/>
        <xsl:copy>
            <xsl:apply-templates select="node()" mode="#current"/>
            <xsl:call-template name="getIDs">
                <xsl:with-param name="rows" select="$rows" as="item()*"/>
            </xsl:call-template>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="Institution">
        <xsl:param name="children" as="element(Institution)*" select="key('institution-by-parent', @id)"/>
        <xsl:variable name="id" select="@id"/>
        <category xml:id="org{@id}" n="{name}">
            <xsl:sequence select="key('current-category-by-id', concat('org',@id), $current-tax)/@*[not(. instance of attribute(xml:id))]"/>
            <catDesc>
                <xsl:call-template name="parseInstName"/>
            </catDesc>
            <xsl:apply-templates select="$children"/>    
        </category>
    </xsl:template>
    
    
<xsl:template name="parseInstName">
    <xsl:choose>
        <xsl:when test="matches(name, '\s+-\s+')">
            <xsl:analyze-string select="name" regex="^(.+)\s+-\s+(.+)">
                <xsl:matching-substring>
                    <name><xsl:value-of select="normalize-space(regex-group(2))"/></name>
                    <placeName><xsl:value-of select="normalize-space(regex-group(1))"/></placeName>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:when>
        <xsl:otherwise>
            <name><xsl:value-of select="normalize-space(name)"/></name>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
    
<xsl:template name="getIDs">
    <xsl:param name="rows" as="element(s:Row)*"/>
    
    <xsl:variable name="gs-cell" select="$rows/s:Cell[starts-with(.,'http://klosterdatenbank.germania-sacra.de/')]"/>
    <xsl:variable name="gnd-cell" select="$rows/s:Cell[starts-with(.,'http://d-nb.info')]"/>
    <xsl:variable name="viaf-cell" select="$rows/s:Cell[starts-with(.,'http://viaf.org')]"/>
    <xsl:variable name="geonames-cell" select="$rows/s:Cell[starts-with(.,'http://www.geonames.org/')]"/>
    <xsl:if test="$gs-cell">
        <xsl:call-template name="idno">
            <xsl:with-param name="cell" select="$gs-cell"/>
            <xsl:with-param name="type">gs</xsl:with-param>
        </xsl:call-template>
    </xsl:if>
    <xsl:if test="$gnd-cell">
        <xsl:call-template name="idno">
            <xsl:with-param name="cell" select="$gnd-cell"/>
            <xsl:with-param name="type">GND</xsl:with-param>
        </xsl:call-template>
    </xsl:if>
    <xsl:if test="$viaf-cell">
        <xsl:call-template name="idno">
            <xsl:with-param name="cell" select="$viaf-cell"/>
            <xsl:with-param name="type">VIAF</xsl:with-param>
        </xsl:call-template>
    </xsl:if>
    <xsl:if test="$geonames-cell">
        <xsl:call-template name="idno">
            <xsl:with-param name="cell" select="$geonames-cell"/>
            <xsl:with-param name="type">geonames</xsl:with-param>
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<xsl:template name="idno">
    <xsl:param name="type"/>
    <xsl:param name="cell"/>
    <xsl:for-each select="$cell">
        <xsl:for-each select="tokenize(normalize-space(.),' / ')">
            <idno type="{$type}" corresp="{.}">
                <xsl:analyze-string select="." regex="(gsn/|gnd/|viaf/|names.org/)([\d\-X]+)">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(2)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </idno>
        </xsl:for-each>
    </xsl:for-each>
</xsl:template>
    
    <xsl:function name="_:getAncestors">
        <xsl:param name="elt" as="element()"/>
        <xsl:choose>
            <xsl:when test="$elt instance of element(tei:category)">
                <xsl:sequence select="_:getAncestors-category($elt)"/>
            </xsl:when>
            <xsl:when test="$elt instance of element(Institution)">
                <xsl:sequence select="_:getAncestors-Institution($elt, ())"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">Unexpected element type <xsl:value-of select="local-name($elt)"/></xsl:message>
            </xsl:otherwise>
        </xsl:choose>    
    </xsl:function>
    
    <xsl:function name="_:getAncestors-category">
        <xsl:param name="elt" as="element(tei:category)"/>
        <xsl:sequence select="$elt/ancestor-or-self::tei:category"/>
    </xsl:function>
    
    <xsl:function name="_:getAncestors-Institution">
        <xsl:param name="elt" as="element(Institution)"/>
        <xsl:param name="sub-elts" as="element(Institution)*"/>
        <xsl:variable name="parent-id" select="$elt/@parent"/>
        <xsl:choose>
            <xsl:when test="$parent-id != ''">
                <xsl:sequence select="_:getAncestors-Institution(_:getInstById($parent-id), ($elt, $sub-elts))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="($elt, $sub-elts)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="_:getInstById">
        <xsl:param name="id" as="attribute(parent)"/>
        <xsl:sequence select="key('institution-by-id', $id, root($id))"/> 
    </xsl:function>
    
    <xsl:function name="_:filter">
        <xsl:param name="rows" as="element(s:Row)*"/>
        <xsl:param name="filter-by" as="element()"/>
        <xsl:param name="pos" as="xs:integer"/>
        <xsl:variable name="filter-val" select="_:normalize-string($filter-by/(@n|name))"/>
        <xsl:variable name="cells" select="$rows/s:Cell[if (@s:Index = $pos) then @s:Index = $pos else position() = $pos]"/>
        <xsl:variable name="rows-filtered" select="$cells[_:normalize-string(.) = $filter-val]/.."/>
        <xsl:sequence select="$rows-filtered"/>
    </xsl:function>
    
    <xsl:function name="_:normalize-string">
        <xsl:param name="s" as="xs:string"/>
        <xsl:value-of select="replace(lower-case(normalize-space($s)), '\P{L}', '')"/>
    </xsl:function>
    
    <xsl:function name="_:getRowsByName">
        <xsl:param name="name" as="xs:string"/>
        <xsl:sequence select="key('call-by-value', $name, $ids)/parent::s:Row"/>
    </xsl:function>
</xsl:stylesheet>