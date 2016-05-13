<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:e13="http://www.edirom.de/ns/1.3"
    exclude-result-prefixes="xs math xd mei e13"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> May 10, 2016</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p><xd:b>License:</xd:b> AGPL3.0</xd:p>
            <xd:p>This stylesheet is used to extract a concordance of measures for Edirom Online.
                It generates a temporary file. The content of that file needs to be copied into the
                appropriate place inside freidi-edition.xml. It is operated on freidi-work.xml</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:variable name="doc.uri" select="substring-before(document-uri(/),'freidi-work.xml')" as="xs:string"/>
    <xsl:variable name="sources" select="collection($doc.uri || 'musicSources/?select=*.xml')//mei:mei" as="node()+"/>
    
    <xsl:template match="/">
        
        <xsl:if test="not(/mei:mei[@xml:id = 'freidi-work'])">
            <xsl:message terminate="yes" select="'ERROR: This xslt must be run on freidi-work.xml.'"/>
        </xsl:if>
        
        <xsl:message select="'INFO: Processing the following sources: ' || string-join($sources/@xml:id,', ')"/>
        
        <xsl:result-document href="{concat($doc.uri,'ready-for-use/ediromOnline_measureConcordance.xml')}">
            <concordance name="Taktkonkordanz nach neuer Struktur" xmlns="http://www.edirom.de/ns/1.3">
                <xsl:comment>Concordance automatically generated on <xsl:value-of select="string(current-dateTime())"/>.
                Sources considered:
                <xsl:for-each select="$sources">
                    <xsl:value-of select="@xml:id"/>: version <xsl:value-of select=".//mei:identifier[@type = 'FreiDi.internal.version']/@n"/> (<xsl:value-of select=".//mei:identifier[@type = 'FreiDi.internal.version']/parent::mei:edition/mei:date/@isodate"/>)<xsl:if test="position() lt count($sources)">,
                    </xsl:if>
                    
                </xsl:for-each>
                </xsl:comment>
                <groups label="Satz">
                    <xsl:apply-templates select=".//mei:mdiv"/>
                </groups>
            </concordance>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template match="mei:mdiv">
        <group name="{@label}" xmlns="http://www.edirom.de/ns/1.3">
            <connections label="Takt">
                <xsl:apply-templates select=".//mei:measure"/>
            </connections>
        </group>    
    </xsl:template>
    
    <xsl:template match="mei:measure">
        <xsl:variable name="coreID" select="@xml:id" as="xs:string"/>
        <xsl:variable name="prefix" select="'xmldb:exist:///db/apps/contents/musicSources/'" as="xs:string"/>
        <xsl:variable name="measures" select="$sources//mei:measure[@sameas = concat('../freidi-work.xml#',$coreID)]" as="node()*"/>
        
        <xsl:if test="count($measures) lt count($sources)">
            <xsl:variable name="unfilled.sources" select="$sources[not(.//mei:measure[@sameas = concat('../freidi-work.xml#',$coreID)])]" as="node()+"/>            
            <xsl:message select="concat('measure ', $coreID,' not referenced in source(s) ',string-join($unfilled.sources/@xml:id,', '))"/>
        </xsl:if>
        
        <xsl:variable name="references" as="xs:string*">
            <xsl:for-each select="$measures">
                <xsl:variable name="id" select="@xml:id" as="xs:string"/>
                <xsl:variable name="file" select="tokenize(document-uri(./root()),'/')[last()]" as="xs:string"/>
                <xsl:value-of select="concat($prefix,$file,'#',$id)"/>
            </xsl:for-each>
        </xsl:variable>
        
        <connection name="{string(@n)}" plist="{string-join($references,' ')}" xmlns="http://www.edirom.de/ns/1.3"/>
        
    </xsl:template>
    
</xsl:stylesheet>