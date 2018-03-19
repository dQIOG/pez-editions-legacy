<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:_="urn:pez"
    xmlns="http://ead3.archivists.org/schema/"
    xmlns:ead="http://ead3.archivists.org/schema/"
    xmlns:saxon="http://saxon.sf.net/"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output method="xml" indent="yes" saxon:suppress-indentation="ead:dao"/>
    <xsl:param name="LOCALTYPE_KARTON">box</xsl:param>
    <xsl:param name="LOCALTYPE_FASZIKEL">file</xsl:param>
    <xsl:param name="img-path-steps" select="tokenize(base-uri(),'/')"/>
    <xsl:param name="img-path" select="string-join(($img-path-steps[position() lt count($img-path-steps)],'_verz_einh'),'/')"/>
    
    <xsl:function name="_:letter-by-date" as="item()*">
        <xsl:param name="date"/>
        <xsl:sequence select="doc(concat('https://exist-curation.minerva.arz.oeaw.ac.at/exist/restxq/pez/letters?view=heading&amp;filter=date=',$date))//item"/>
    </xsl:function>
    <xsl:template match="/bilder">
        <xsl:processing-instruction name="xml-model">href="http://www.loc.gov/ead/ead3.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
        <xsl:processing-instruction name="xml-model">href="http://www.loc.gov/ead/ead3.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
        <ead> 
            <control>
                <recordid>peznachlassead</recordid>
                <filedesc>
                    <titlestmt>
                        <titleproper>Digitales Findbuch zum Nachlass der Brüder Bernhard und Hieronymus Pez OSB</titleproper>
                        <author>Irene Rabl</author>
                        <author>Thomas Wallnig</author>
                        <author>Manuela Mayer</author>
                    </titlestmt>
                    <publicationstmt>
                        <publisher>Verein zur Erforschung monastischer Gelehrsamkeit in der Frühen Neuzeit (VEMG)</publisher>
                        <date>2018</date>
                        <address>
                            <addressline>Institut für Österreichische Geschichtsforschung</addressline>
                            <addressline>Universitätsring 1</addressline>
                            <addressline>1010 Wien</addressline>
                        </address>
                    </publicationstmt>
                </filedesc>
                <maintenancestatus value="derived"/>
                <maintenanceagency>
                    <agencyname>Verein zur Erforschung monastischer Gelehrsamkeit in der Frühen Neuzeit (VEMG)</agencyname>
                </maintenanceagency>
                <maintenancehistory>
                    <maintenanceevent>
                        <eventtype value="derived"/>
                        <eventdatetime>2017-08-30T17:41:52.114+02:00</eventdatetime>
                        <agenttype value="human"/>
                        <agent>daniel.schopper@oeaw.ac.at</agent>
                        <eventdescription>Conversion from easydb XML-dump of https://unidam.univie.ac.at to EAD 3.0.</eventdescription>
                    </maintenanceevent>
                </maintenancehistory>
            </control>
            <archdesc level="collection" localtype="Nachlass">
                <did>
                    <unittitle>NACHLASS BERNHARD UND HIERONYMUS PEZ OSB</unittitle>
                    <repository>
                        <corpname>
                            <part>Melk</part>
                            <part>Benediktinerstift</part>
                        </corpname>
                        <address>
                            <addressline>Abt-Berthold-Dietmayr-Straße 1</addressline>
                            <addressline>A-3390 Melk</addressline>
                            <addressline>+432752 555 0</addressline>
                            <addressline>Fax: +432752 555 52</addressline>
                            <addressline>Email: archiv@stiftmelk.at</addressline>
                            <addressline>URL: <ref>http://www.stiftmelk.at</ref></addressline>
                        </address>
                    </repository>
                </did>
                <dsc>
                    <xsl:apply-templates select="bild"/>
                </dsc>
            </archdesc>
        </ead>
    </xsl:template>
    
    <xsl:template match="bild">
        <xsl:variable name="verz_einh_id" select="verz_einh/@id"/>
        <xsl:variable name="path-to-folgeseiten" select="concat($img-path,'/',$verz_einh_id,'.xml')"/>
        <c level="item" id="i{$verz_einh_id}">
            <did>
                <xsl:apply-templates select="standort" mode="did"/>
                <xsl:apply-templates select="verz_einh"/>
                <xsl:apply-templates select="titel" mode="did"/>
                <xsl:apply-templates select="datierung" mode="did"/>
                <xsl:apply-templates select="datierung_zusatz" mode="did"/>
                <xsl:variable name="folgeseiten" select="if (doc-available($path-to-folgeseiten)) then doc($path-to-folgeseiten)//bild else ()" as="element(bild)*"/>
                <xsl:choose>
                    <xsl:when test="exists($folgeseiten)">
                        <daoset label="Digitalisate" coverage="whole">
                            <dao daotype="derived" coverage="whole" label="{normalize-space(foliierung)}" href="{ $verz_einh_id}/{@id}.tif" />                            
                            <xsl:for-each select="$folgeseiten">
                                <dao daotype="derived" coverage="whole" label="{normalize-space(foliierung_paginierung)}" href="{$verz_einh_id}/{@id}.tif"/>
                            </xsl:for-each>
                        </daoset>
                    </xsl:when>
                    <xsl:otherwise>
                        <dao daotype="derived" coverage="whole" label="{normalize-space(foliierung)}" href="{ $verz_einh_id}/{@id}.tif" />
                    </xsl:otherwise>
                </xsl:choose>
            </did>
            <xsl:apply-templates/>
        </c>
    </xsl:template>
    
    <xsl:template match="standort"/>
    <xsl:template match="standort" mode="did">
        <repository>
            <corpname>
                <part>Benediktinerstift Melk</part>
                <part><xsl:value-of select="normalize-space(reverse(tokenize(.,'&gt;')[normalize-space(.) != ''])[1])"/></part>
            </corpname>
        </repository>
    </xsl:template>
    
    <xsl:template match="verz_einh"/>
    <xsl:template match="verz_einh" mode="did">
        <xsl:choose>
            <xsl:when test="starts-with(.,'Kt.')">
                <xsl:variable name="parts" select="tokenize(.,' &gt; ')[normalize-space(.) != '']" as="xs:string+"/>                                        
                <xsl:call-template name="mkContainers">
                    <xsl:with-param name="parts" select="$parts" as="xs:string*"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="starts-with(., 'Cod.')">
                <unitid><xsl:value-of select="normalize-space(replace(.,'&gt;',''))"/></unitid>
            </xsl:when>
            <xsl:when test="starts-with(., 'Pez. Catalogus')">
                <xsl:for-each select="tokenize(.,'&gt;')">
                    <container localtype="file"><xsl:value-of select="normalize-space(.)"/></container>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="."/>
                <xsl:message terminate="yes">Unexpected value in field 'Verz_einh' (does not start with 'Kt.' or 'Cod.')</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>        
    
    
    <xsl:template match="titel"/>
    <xsl:template match="titel" mode="did">
        <unittitle><xsl:value-of select="normalize-space(.)"/></unittitle>
    </xsl:template>
    
    <xsl:template match="titel_lang"/>
    
    <xsl:template match="foliierung"/>
    <xsl:template match="foliierungsverlauf"/>
    <xsl:template match="sortierfeld"/>
    <xsl:template match="kategorie[normalize-space()!='']">
        <controlaccess>
            <head>Kategorie</head>
            <xsl:for-each select="tokenize(.,'&gt;')[normalize-space(.)!='']">
                <genreform><part><xsl:value-of select="normalize-space(.)"/></part></genreform>
            </xsl:for-each>
        </controlaccess>
    </xsl:template>
    <xsl:template match="datierung"/>
    
    <xsl:template match="datierung" mode="did">
        <unitdate><xsl:value-of select="normalize-space(.)"/></unitdate>
    </xsl:template>
    <xsl:template match="datierung_zusatz"/>
    <xsl:template match="datierung_zusatz" mode="did">
        <didnote localtype="datenote"><xsl:value-of select="normalize-space(.)"/></didnote>
    </xsl:template>
    <xsl:template match="datierung_verbal"/>
    
    <xsl:template match="folgeseiten|file-original|pool|poolpath"/>
        
    
    
    <xsl:template match="personen[*]">
        <controlaccess>
            <head>Personen</head>
            <xsl:apply-templates/>
        </controlaccess>
    </xsl:template>
    
    <xsl:template match="person">
        <persname relator="{funktion}">
            <xsl:apply-templates select="* except funktion"/>
        </persname> 
    </xsl:template>
    
    <xsl:template match="vorname|name">
        <part localtype="{local-name()}"><xsl:value-of select="."/></part>
    </xsl:template>
    
    <xsl:template match="regionen[*]">
        <controlaccess>
            <head>Regionen</head>
            <xsl:apply-templates/>
        </controlaccess>
    </xsl:template>
    
    <xsl:template match="region">
        <geogname>
            <part><xsl:value-of select="normalize-space()"/></part>
        </geogname>
    </xsl:template>
    
    <xsl:template match="institutionen[*]">
        <controlaccess>
            <head>Institutionen</head>
            <xsl:apply-templates/>
        </controlaccess>
    </xsl:template>
    
    <xsl:template match="institution">
        <corpname>
            <xsl:for-each select="tokenize(.,'\s*&gt;\s*')[normalize-space(.) != '']">
                <part><xsl:value-of select="normalize-space(.)"/></part>
            </xsl:for-each>
        </corpname>
    </xsl:template>
    
    <xsl:template name="mkContainers">
        <xsl:param name="parts" as="xs:string*"/>
        <xsl:param name="containers" as="element()*"/>
        <xsl:variable name="type">
           <xsl:choose>
               <xsl:when test="starts-with($parts[1],'Kt')"><xsl:value-of select="$LOCALTYPE_KARTON"/></xsl:when>
               <xsl:when test="starts-with($parts[1],'Faszikel')"><xsl:value-of select="$LOCALTYPE_FASZIKEL"/></xsl:when>
               <xsl:when test="starts-with($parts[1], 'Nr.')">item</xsl:when>
           </xsl:choose>
        </xsl:variable>
        <xsl:variable name="newItem" as="element()">
            <xsl:choose>
                <xsl:when test="$type = $LOCALTYPE_KARTON">
                    <container localtype="{$type}" containerid="melk_{replace($parts[1],'[\p{P}\s]+','')}"><xsl:value-of select="normalize-space($parts[1])"/></container>
                </xsl:when>
                <xsl:when test="$type = $LOCALTYPE_FASZIKEL">
                    <xsl:variable name="parentid" select="$containers[@localtype = $LOCALTYPE_KARTON]/@containerid"/>
                    <xsl:variable name="containerid" select="lower-case(replace(replace($parts[1],'[\p{P}\s]',''),'Faszikel','fz'))"/>
                    <container localtype="{$type}" containerid="{$parentid}_{$containerid}"><xsl:value-of select="normalize-space($parts[1])"/></container>
                </xsl:when>
                <xsl:when test="$type = 'item'">
                    <xsl:variable name="parentid" select="$containers[@localtype = $LOCALTYPE_FASZIKEL]/@containerid"/>
                    <unitid><xsl:value-of select="normalize-space($parts[1])"/></unitid>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes">Unexpected structure in "verz_einh": "<xsl:value-of select="verz_einh"/>"</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="exists($parts[2])">
                <xsl:call-template name="mkContainers">
                    <xsl:with-param name="parts" select="subsequence($parts,2)"/>
                    <xsl:with-param name="containers" as="element()+">
                        <xsl:sequence select="($containers, $newItem)"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="($containers, $newItem)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="beschr">
        <scopecontent>
            <head>Beschreibung</head>
            <xsl:choose>
                <xsl:when test="matches(.,'\n1\)')">
                    <xsl:for-each-group select="tokenize(.,'\n')[normalize-space(.) != '']" group-by="matches(.,'^\d+\)')">
                        <xsl:choose>
                            <xsl:when test="current-grouping-key() eq true()">
                                <list listtype="ordered">
                                    <xsl:for-each select="current-group()">
                                        <item><xsl:value-of select="replace(.,'^\d+\)\s*','')"/></item>
                                    </xsl:for-each>
                                </list>
                            </xsl:when>
                            <xsl:otherwise>
                                <p><xsl:value-of select="current-group()"/></p>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                </xsl:when>
                <xsl:otherwise>
                    <p><xsl:value-of select="."/></p>
                </xsl:otherwise>
            </xsl:choose>
        </scopecontent>
    </xsl:template>
    
    <xsl:template match="literatur">
        <bibliography>
            <head>Literatur</head>
            <xsl:choose>
                <xsl:when test="matches(.,'\nZu 1\)')">
                    <xsl:for-each-group select="tokenize(.,'\n')[normalize-space(.) != '']" group-by="matches(.,'^Zu \d+\)')">
                        <xsl:choose>
                            <xsl:when test="current-grouping-key() eq true()">
                                <list listtype="ordered">
                                    <xsl:for-each select="current-group()">
                                        <item><xsl:value-of select="replace(.,'^\d+\)\s*','')"/></item>
                                    </xsl:for-each>
                                </list>
                            </xsl:when>
                            <xsl:otherwise>
                                <p><xsl:value-of select="current-group()"/></p>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each-group>
                </xsl:when>
                <xsl:otherwise>
                    <p><xsl:value-of select="."/></p>
                </xsl:otherwise>
            </xsl:choose>
        </bibliography>
    </xsl:template>
    
    <xsl:template match="pez_br_z[normalize-space()!='']">
        <relatedmaterial>
            <head>Pez-Briefe im direkten Zusammenhang mit dem Stück</head>
            <xsl:choose>
                <xsl:when test="matches(., '^\w+\san\s\w+:')">
                    <xsl:analyze-string select="." regex="(\w+\san\s\w+:)(.+)[\.?]">
                        <xsl:matching-substring>
                            <list>
                                <head><xsl:value-of select="regex-group(1)"/></head>
                                <xsl:for-each select="tokenize(regex-group(2), ',\s+')">
                                    <item>
                                        <xsl:analyze-string select="normalize-space()" regex="\d{{4,4}}-\d{{2,2}}-\d{{2,2}}">
                                            <xsl:matching-substring>
                                                <ref>
                                                    <xsl:variable name="identifiers" select="_:letter-by-date(.)/@id/concat('pezEd:',.)"/>
                                                    <xsl:attribute name="href" select="string-join($identifiers,' ')"/>
                                                    <xsl:value-of select="."/>
                                                </ref>
                                            </xsl:matching-substring>
                                            <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
                                        </xsl:analyze-string>
                                    </item>
                                </xsl:for-each>
                            </list>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:value-of select="."/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:when>
                <xsl:otherwise>
                    <p><xsl:value-of select="."/></p>
                </xsl:otherwise>
            </xsl:choose>
        </relatedmaterial>
    </xsl:template>
</xsl:stylesheet>