<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/">
        <xsl:variable name="prepared" as="item()*">
            <xsl:apply-templates mode="prepare"/>
        </xsl:variable>
        <xsl:variable name="indexes" as="item()*">
            <xsl:apply-templates select="$prepared" mode="indexes"/>
        </xsl:variable>
        <xsl:variable name="textTagged" as="item()*">
            <xsl:apply-templates select="$indexes" mode="tagText"/>
        </xsl:variable>
        <xsl:variable name="descUnnested" as="item()*">
            <xsl:apply-templates select="$textTagged" mode="unnestDesc"/>
        </xsl:variable>
        <xsl:variable name="IDsAdded" as="item()*">
            <xsl:apply-templates select="$descUnnested" mode="addIDs"/>
        </xsl:variable>
        <xsl:sequence select="$IDsAdded"/>
    </xsl:template>
    
    <xsl:template match="anchor" mode="prepare"/>
    
    <xsl:template match="hi[@rend = 'Kommentar_Zchn']|hi[@rend = 'Kommentar_Zchn']/seg[@rend='italic']" mode="prepare">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="p[@rend = ('Edition Überschrift Ebene 1', 'Überschrift Ebene 2')]" mode="prepare">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="p[matches(., '^\p{L}')]/@rend" mode="prepare">
        <xsl:attribute name="rend">Register 1</xsl:attribute>
    </xsl:template>
    
    <xsl:template match="p[matches(., '^—[\t\s]\p{L}')]/@rend" mode="prepare" priority="1"/>
    <xsl:template match="p[matches(., '^—[\t\s]\p{L}')]" mode="prepare" priority="1">
        <xsl:copy>
            <xsl:copy-of select="@* except @rend"/>
            <xsl:attribute name="rend">Register 2</xsl:attribute>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
        
    <xsl:template match="p[matches(., '^—[\t\s]—\s\p{L}')]/@rend" mode="prepare" priority="2"/>
    <xsl:template match="p[matches(., '^—[\t\s]—\s\p{L}')]" mode="prepare" priority="2">
        <xsl:copy>
            <xsl:copy-of select="@* except @rend"/>
            <xsl:attribute name="rend">Register 3</xsl:attribute>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="p[matches(., '^—[\t\s]—[\t\s]—\s\p{L}')]/@rend" mode="prepare" priority="3"/>
    <xsl:template match="p[matches(., '^—[\t\s]—[\t\s]—\s\p{L}')]" mode="prepare" priority="3">
        <xsl:copy>
            <xsl:copy-of select="@* except @rend"/>
            <xsl:attribute name="rend">Register 4</xsl:attribute>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="p[matches(., '^—[\t\s]—[\t\s]—[\t\s]—\s\p{L}')]/@rend" mode="prepare" priority="4"/>
    <xsl:template match="p[matches(., '^—[\t\s]—[\t\s]—[\t\s]—\s\p{L}')]" mode="prepare" priority="4">
        <xsl:copy>
            <xsl:copy-of select="@* except @rend"/>
            <xsl:attribute name="rend">Register 5</xsl:attribute>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="p[starts-with(., 'Personen oder Werke, die mit einem Asterisk (*) gekennzeichnet')]" mode="prepare">
        <note><xsl:value-of select="."/></note>
    </xsl:template>
    
    <xsl:template match="body" mode="indexes">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:for-each-group select="*" group-starting-with="p[@rend = 'Überschrift Ebene 2']">
                <xsl:choose>
                    <xsl:when test="current-group()[1]/self::p[@rend  = 'Überschrift Ebene 2']">
                        <list type="index" n="1">
                            <xsl:apply-templates select="current-group()[1][@rend = 'Überschrift Ebene 2']" mode="#current"/>
                            <xsl:apply-templates select="current-group()/self::note"/>
                            <xsl:call-template name="group">
                                <xsl:with-param name="elts" select="current-group()[self::p][position() gt 1]"/>
                                <xsl:with-param name="level" select="1" as="xs:integer"/>
                            </xsl:call-template>
                        </list>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()" mode="#current"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="p[@rend = ('Edition Überschrift Ebene 1', 'Überschrift Ebene 2')]" mode="indexes">
        <head><xsl:apply-templates mode="#current"/></head>
    </xsl:template>
    
    <xsl:template match="p[matches(@rend, 'Register \d')]" mode="indexes">
        <desc>
            <xsl:apply-templates mode="#current"/>
        </desc>
    </xsl:template>
    
    <!--<xsl:function name="str2ref" as="item()+">
        <xsl:param name="string" as="xs:string"/>
        <xsl:analyze-string select="." regex="\s+"></xsl:analyze-string>
    </xsl:function>-->
    <!--
    <xsl:template match="p[matches(@rend, 'Register \d')]/text()[contains(.,'&#160;&#160;&#160;&#160;')]" mode="indexes">
        <xsl:value-of select="substring-before(.,'&#160;&#160;&#160;&#160;')"/>
        <xsl:for-each select="tokenize(substring-after(.,'&#160;&#160;&#160;&#160;'),'\.\s*')">
            <ref><xsl:value-of select="."/></ref>
        </xsl:for-each>
    </xsl:template>
    -->
    <xsl:template match="p[matches(@rend, 'Register \d')]/text()[matches(., '^(—\t)+')]" mode="indexes">
        <xsl:value-of select="replace(., '^(—\t)+', '')"/>
    </xsl:template>
    
    
    <!--<xsl:template match="p[@rend = 'Register 2']" mode="indexes">
        <xsl:call-template name="mkIndexEntry">
            <xsl:with-param name="elts" select="."/>
            <xsl:with-param name="level" select="2" as="xs:integer"/>
        </xsl:call-template>
    </xsl:template>
-->    
    <xsl:template name="mkIndexEntry">
        <xsl:param name="elts" as="element()+"/>
        <xsl:param name="level" as="xs:integer"/>
        <xsl:variable name="sub-entries" as="item()*">
            <xsl:call-template name="group">
                <xsl:with-param name="level" select="$level+1" as="xs:integer"/>
                <xsl:with-param name="elts" select="$elts[not(@rend = concat('Register ', $level))]"/>
            </xsl:call-template>
        </xsl:variable>
        <item>
            <xsl:apply-templates select="$elts/self::p[@rend = concat('Register ', $level)]" mode="indexes"/>    
            <xsl:if test="$sub-entries">
                <list type="indexEntry" n="{$level+1}">
                    <xsl:sequence select="$sub-entries"/>
                </list>
            </xsl:if>
        </item>
    </xsl:template>
    
    
    <xsl:template name="group">
        <xsl:param name="elts" as="element()*"/>
        <xsl:param name="level" as="xs:integer"/>
        <xsl:for-each-group select="$elts" group-starting-with="p[@rend = concat('Register ', $level)]">
            <xsl:call-template name="mkIndexEntry">
                <xsl:with-param name="elts" select="current-group()"/>
                <xsl:with-param name="level" select="$level" as="xs:integer"/>
            </xsl:call-template>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template match="desc/text()" mode="tagText">
        <xsl:analyze-string select="." regex="^(—[\t\s])+">
            <xsl:matching-substring/>
            <xsl:non-matching-substring>
                <xsl:analyze-string select="." regex="&#160;{{4,}}((\d+(-\d+)?\.\s*)+)">
                    <xsl:matching-substring>
                        <xsl:choose>
                            <xsl:when test="matches(regex-group(1),'^ \d+\.$')">
                                <ref type="letter"><xsl:value-of select="substring-before(regex-group(1), '.')"/></ref>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="tokenize(regex-group(1), '\s+')">
                                    <ref type="letter"><xsl:value-of select="substring-before(., '.')"/></ref>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:analyze-string select="." regex="\((.+)\)" flags="s">
                            <xsl:matching-substring>
                                <note><xsl:value-of select="regex-group(1)"/></note>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
        
    
    
    <xsl:template match="desc/note | desc/ref" mode="unnestDesc"/>
    
    <xsl:template match="desc" mode="unnestDesc">
        <term>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </term>
        <xsl:apply-templates select="note | ref" mode="copyEltsInDesc"/>
    </xsl:template>
    
    <xsl:template match="desc/text()[1]" mode="unnestDesc" priority="1"> 
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    
    <xsl:template match="desc/text()[last()][matches(.,'^\s*\.\s*$')]" mode="unnestDesc"/>
    
    
    <xsl:template match="*" mode="copyEltsInDesc" priority="1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="unnestDesc"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="item" mode="addIDs">
        <xsl:copy>
            <xsl:attribute name="xml:id" select="generate-id()"/>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>