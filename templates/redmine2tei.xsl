<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:j="http://www.w3.org/2013/XSL/json"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:_="urn:acdh"
    exclude-result-prefixes="#all" 
    version="3.0">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:param name="base-url" select="concat('https://',$user,':',$password,'@redmine.acdh.oeaw.ac.at/issues/')"/>
    
    
    <xsl:function name="_:get-md" as="item()?" xpath-default-namespace="">
        <xsl:param name="md" as="document-node()+"/>
        <xsl:param name="aspect" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="exists($md//*[local-name() = $aspect])">
                <xsl:value-of select="$md//*[local-name() = $aspect]"/>
            </xsl:when>
            <xsl:when test="exists($md//custom_field[@name = $aspect])">
                <xsl:variable name="field" select="$md//custom_field[@name = $aspect]"/>
                <xsl:sequence select="if ($field/@multiple = 'true') then $field/value/value else $field/value"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>Unknown field "<xsl:value-of select="$aspect"/>"</xsl:comment>
            </xsl:otherwise>
        </xsl:choose> 
    </xsl:function>
    
    <xsl:template match="/t:TEI">
        <xsl:variable name="id" select="//t:publicationStmt/t:idno[@type = 'pezEd']"/>
        <xsl:variable name="xml" select="doc(concat($base-url, $id, '.xml'))"/>
        <xsl:variable name="relations" select="doc(concat($base-url,$id,'/relations.xml'))"/>
        <xsl:variable name="md" select="($xml,$relations)"/>
        <xsl:choose>
            <xsl:when test="@keep">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates>
                        <xsl:with-param name="md" select="$md" tunnel="yes" as="item()+"/>
                    </xsl:apply-templates>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="t:titleStmt/t:title[@level = 'a'][@type = 'main']">
        <xsl:param name="md" tunnel="yes"/>
        <xsl:variable name="subject" select="_:get-md($md,'subject')"/>
        <xsl:message select="exists($subject)"></xsl:message>
        <xsl:message select="$subject"/>
        <xsl:message>here</xsl:message>
        <xsl:choose>
            <xsl:when test="@keep">
                <xsl:sequence select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:value-of select="$subject"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template match="t:physDesc">
        <xsl:param name="md" tunnel="yes"/>
        <xsl:variable name="attachments" select="_:get-md($md, 'Attachments')"/>
        <xsl:variable name="extent" select="_:get-md($md, 'size')"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
            <!-- possibly we now have attachments in the redmine ticket, 
                so we have to add it here, when needed -->
            <xsl:if test="not(exists(t:accMat)) and exists($attachments)">
                <accMat type="attachments">
                    <p><xsl:value-of select="$attachments"/></p>
                </accMat>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="t:accMat[@type = 'attachments']">
        <xsl:param name="md" tunnel="yes"/>
        <xsl:variable name="attachments" select="_:get-md($md, 'Attachments')"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <p><xsl:value-of select="$attachments"/></p>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="t:msIdentifier/t:idno[@type = 'signature']">
        <xsl:param name="md" tunnel="yes"/>
        <xsl:variable name="signatur" select="_:get-md($md, 'Signatur')"/>
        <xsl:choose>
            <xsl:when test="@keyp">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:value-of select="$signatur"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="t:supportDesc/t:extent">
        <xsl:param name="md" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="@keep">
                <xsl:sequence select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:value-of select="_:get-md($md,'size')"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="t:correspAction[@type = ('sent', 'received')]/t:placeName">
        <xsl:param name="md" tunnel="yes"/>
        <xsl:variable name="fieldName" select="if (../@type = 'sent') then 'Absendsort' else 'Empfangsort'"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="_:get-md($md, $fieldName)/normalize-space(.)"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="t:correspAction[@type = ('sent', 'received')]/t:persName">
        <xsl:param name="md" tunnel="yes"/>
        <xsl:variable name="fieldName" select="if (../@type = 'sent') then 'Absender' else 'Empfänger'"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="_:get-md($md, $fieldName)/normalize-space(.)"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="t:correspAction[@type = 'sent']/t:date">
        <xsl:param name="md" tunnel="yes"/>
        <xsl:variable name="fieldName">Datum</xsl:variable>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="_:get-md($md, $fieldName)/normalize-space(.)"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="t:correspContext">
        <xsl:param name="md" tunnel="yes"/>
        <xsl:variable name="nextLetter" select="_:get-md($md,'precedes')"/>
        <xsl:variable name="prevLetter" select="_:get-md($md,'follows')"/>
        <xsl:if test="$nextLetter">
            <ref type="next">
                <idno type="pezEd"><xsl:value-of select="$nextLetter"/></idno>
            </ref>
        </xsl:if>
        <xsl:if test="$prevLetter">
            <ref type="prev">
                <idno type="pezEd"><xsl:value-of select="$prevLetter"/></idno>
            </ref>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="t:creation/t:origDate">
        <xsl:param name="md" tunnel="yes"/>
        <xsl:variable name="fieldName">Datum</xsl:variable>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="_:get-md($md, $fieldName)/normalize-space(.)"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="t:creation/t:origPlace">
        <xsl:param name="md" tunnel="yes"/>
        <xsl:variable name="fieldName">Absendsort</xsl:variable>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="_:get-md($md, $fieldName)/normalize-space(.)"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
