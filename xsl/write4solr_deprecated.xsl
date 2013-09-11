<?xml version="1.0" encoding="UTF-8"?>
<!--
	eadSolr
	Created by Brian Hoffman on 2007-05-08.
	Copyright (c) 2007 __MyCompanyName__. All rights reserved.
	DEPRECATED 2012: This stylesheet has no namespace - will not work with AT-exported content

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output encoding="UTF-8" indent="yes" method="xml" name="xml"/>
	<xsl:param name="sourceFilename"/>
	<xsl:param name="collectionName"/>
	<xsl:param name="uri"/>
	<xsl:param name="eadMode" select="inter"/>
	<xsl:include href="generateXML.xsl"/>
	<xsl:include href="globalVars.xsl"/>
	<xsl:template match="/">
		<xsl:apply-templates select="ead"/>
	</xsl:template>
	<xsl:template match="ead">
<!--Document to represent the EAD Document (The entire collection)-->
		<add>
			<xsl:choose>
				<xsl:when test="$eadMode = 'inter'">
					<doc>
<!--special collection if it can be parsed from the source file's directory-->
						<field name="collectionId">
							<xsl:choose>
								<xsl:when test="contains($collectionName, 'fales')">fales</xsl:when>
								<xsl:when test="contains($collectionName, 'archives')">archives</xsl:when>
								<xsl:when test="contains($collectionName, 'tamwag')">tamwag</xsl:when>
								<xsl:when test="contains($collectionName, 'nyhs')">nyhs</xsl:when>
								<xsl:when test="contains($collectionName, 'rism')">rism</xsl:when>
								<xsl:when test="contains($collectionName, 'bhs')">bhs</xsl:when>
								<xsl:otherwise>undefined</xsl:otherwise>
							</xsl:choose>
						</field>
						<field name="uri">
							<xsl:choose>
								<xsl:when test="$uri">
									<xsl:value-of select="$uri"/>
								</xsl:when>
								<xsl:otherwise>
				</xsl:otherwise>
							</xsl:choose>
						</field>
						<xsl:apply-templates select="eadheader"/>
						<xsl:apply-templates select="archdesc" mode="doc4ead"/>
					</doc>
				</xsl:when>
				<xsl:when test="$eadMode = 'intra'">
					<xsl:apply-templates select="archdesc" mode="doc4did"/>
				</xsl:when>
			</xsl:choose>
		</add>
	</xsl:template>
	<xsl:template match="eadheader">
		<xsl:apply-templates select="eadid"/>
		<xsl:apply-templates select="//titleproper" mode="title"/>
	</xsl:template>
	<xsl:template match="archdesc" mode="doc4ead">
<!--children: 
			did - collection level DMD
			custodhist
			accessrestrict
			userestrict
			prefercite
			bioghist
			scopecontent
			arrangement
			controlaccess
			dsc - Detailed description of collection contents
			relatedmaterial
			separatedmaterial
						-->
		<xsl:apply-templates select="did"/>
		<xsl:apply-templates select="scopecontent"/>
		<xsl:apply-templates select="bioghist"/>
		<xsl:apply-templates select="controlaccess"/>
		<xsl:apply-templates select="dsc" mode="doc4ead"/>
	</xsl:template>
<!--End archdesc for ead level-->
<!--archdesc for did level-->
	<xsl:template match="archdesc" mode="doc4did">
		<xsl:apply-templates select="dsc" mode="doc4did"/>
<!--Use modes 'ead' or 'did' to fork for stuff that goes in the ead <doc> as well as the did <doc> in the solr index files-->
	</xsl:template>
<!--End archdesc-->
<!--Children of archdesc -->
	<xsl:template match="did">
		<xsl:apply-templates select="physdesc[@label = 'Quantity']" mode="format.extent"/>
		<xsl:apply-templates select="origination[@label = 'Creator']" mode="creator"/>
		<xsl:apply-templates select="abstract" mode="description.abstract"/>
		<xsl:apply-templates select="langmaterial[@label = 'Language']" mode="language"/>
	</xsl:template>
	<xsl:template match="bioghist">
		<xsl:if test="position() = 1">
			<field name="{name()}URI">
				<xsl:value-of select="$bioghistLink"/>
			</field>
		</xsl:if>
		<xsl:for-each select="p">
			<field name="bioghist">
				<xsl:value-of select="text()"/>
				<xsl:if test="list/item">
					<xsl:for-each select="list/item">
						<xsl:value-of select="text()"/>
					</xsl:for-each>
				</xsl:if>
			</field>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="scopecontent">
		<field name="{name()}URI">
			<xsl:value-of select="$scopeLink"/>
		</field>
		<xsl:for-each select="p">
			<field name="description.scopecontent">
				<xsl:value-of select="text()"/>
			</field>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="controlaccess">
		<xsl:apply-templates select="controlaccess"/>
		<xsl:choose>
			<xsl:when test="head = 'Subject Names:'">
				<xsl:apply-templates select="persname" mode="subject.person.lcsh"/>
			</xsl:when>
			<xsl:when test="head = 'Subject Organizations:'">
				<xsl:apply-templates select="corpname[@source = 'lcnaf']" mode="subject.organization.lcnaf"/>
			</xsl:when>
			<xsl:when test="head = 'Subject Topics:'">
				<xsl:apply-templates select="subject" mode="subject.lcsh"/>
			</xsl:when>
			<xsl:when test="head = 'Subject Places:'">
				<xsl:apply-templates select="geogname" mode="coverage.geographical.lcsh"/>
			</xsl:when>
			<xsl:when test="head = 'Document Types:'">
				<xsl:apply-templates select="genreform" mode="type.aat"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="dsc" mode="doc4ead">
		<field name="containerURI">
			<xsl:value-of select="$containerLink"/>
		</field>
		<field name="description.dsc.glob">
			<xsl:for-each select="descendant::unittitle">
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:for-each>
		</field>
	</xsl:template>
	<xsl:template match="dsc" mode="doc4did">
<!--For starters, just piece together dynamic field names for each box and folder-->
		<xsl:apply-templates select="descendant::did" mode="doc4did"/>
	</xsl:template>
<!--End Children of archdesc-->
<!--Grand children of archdesc-->
	<xsl:template match="langmaterial" mode="language">
		<field name="language">
			<xsl:value-of select="."/>
		</field>
	</xsl:template>
	<xsl:template match="physdesc" mode="format.extent">
		<field name="format.extent">
			<xsl:value-of select="."/>
		</field>
	</xsl:template>
	<xsl:template match="origination" mode="creator">
		<xsl:apply-templates select="persname" mode="creator"/>
		<xsl:apply-templates select="corpname" mode="creator"/>
	</xsl:template>
	<xsl:template match="eadid">
		<field name="id">
			<xsl:value-of select="concat($collectionName, '_', text())"/>
		</field>
	</xsl:template>
	<xsl:template match="titleproper" mode="title">
		<field name="title">
			<xsl:value-of select="normalize-space(.)" />
		</field>
	</xsl:template>
	<xsl:template match="persname | corpname" mode="creator">
		<field name="creator">
<xsl:value-of select="normalize-space(text())" />
		</field>
	</xsl:template>
	<xsl:template match="abstract" mode="description.abstract">
		<field name="description.abstract">
			<xsl:value-of select="."/>
		</field>
	</xsl:template>
<!--Access Points-->
	<xsl:template match="persname" mode="subject.person.lcsh">
		<field name="subject.person.lcsh">
			<xsl:value-of select="normalize-space(text())" />
		</field>
	</xsl:template>
	<xsl:template match="corpname" mode="subject.organization.lcnaf">
		<field name="subject.organization.lcnaf">
			<xsl:value-of select="normalize-space(text())" />
		</field>
	</xsl:template>
	<xsl:template match="subject" mode="subject.lcsh">
		<field name="subject.lcsh">
			<xsl:value-of select="normalize-space(text())" />
		</field>
	</xsl:template>
	<xsl:template match="geogname" mode="coverage.geographical.lcsh">
		<field name="coverage.geographical.lcsh">
			<xsl:value-of select="normalize-space(text())" />
		</field>
	</xsl:template>
	<xsl:template match="genreform" mode="type.aat">
		<field name="type.att">
			<xsl:value-of select="normalize-space(text())" />
		</field>
	</xsl:template>
<!--Templates for 'did' docs in solr-->
	<xsl:template match="did" mode="doc4did">
		<xsl:choose>
			<xsl:when test="not(container) and not (unittitle)">
<!--do nothing-->
			</xsl:when>
			<xsl:otherwise>
<!--Build a separate doc for each low-level did-->
				<doc>
					<field name="id">
						<xsl:value-of select="concat($collectionName, '_', /ead/eadheader/eadid, '_', position())"/>
					</field>
					<field name="collectionId">
						<xsl:value-of select="concat($collectionName, '_', /ead/eadheader/eadid)"/>
					</field>
					<xsl:variable name="nodeID" select="substring(generate-id(),3)"/>
					<field name="uri">
						<xsl:choose>
							<xsl:when test="container and unittitle">
								<xsl:value-of select="concat($uri, '#', name(parent::node()), '-', $nodeID)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="contains(unittitle,'Series') and (parent::c01)">
										<xsl:variable name="seriesNum">
											<xsl:number format="1" value="1 + count(parent::c01/preceding-sibling::c01)"/>
										</xsl:variable>
										<xsl:value-of select="concat($uri, '#series',$seriesNum)"/>
									</xsl:when>
									<xsl:when test="parent::c">
										<xsl:variable name="num">
											<xsl:number value="1 + count(parent::c/preceding-sibling::c)"/>
										</xsl:variable>
										<xsl:variable name="seriesType">
											<xsl:if test="../@level='series'">
												<xsl:value-of select="'#series'"/>
											</xsl:if>
											<xsl:if test="../@level='subseries'">
												<xsl:value-of select="'#subseries'"/>
											</xsl:if>
										</xsl:variable>
										<xsl:value-of select="concat($uri, $seriesType,$num)"/>
									</xsl:when>
									<xsl:when test="parent::c02">
										<xsl:variable name="num">
											<xsl:number value="1 + count(parent::c02/preceding-sibling::c02)"/>
										</xsl:variable>
										<xsl:value-of select="concat($uri, '#subseries',$num)"/>
									</xsl:when>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</field>
					<xsl:apply-templates select="container"/>
					<xsl:apply-templates select="unittitle"/>
					<xsl:apply-templates select="unitdate"/>
				</doc>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="container">
		<xsl:variable name="type" select="@type"/>
		<field name="container">
			<xsl:value-of select="@type"/>
			<xsl:text>: </xsl:text>
			<xsl:value-of select="."/>
		</field>
	</xsl:template>
	<xsl:template match="unittitle">
		<field name="title">
			<xsl:apply-templates/>
		</field>
	</xsl:template>
	<xsl:template match="unitdate">
		<field name="date">
			<xsl:choose>
				<xsl:when test="text() = 'undated'">
					Undated 
					<xsl:choose><xsl:when test="string-length(@normal)">
							(<xsl:value-of select="@normal"/>)
						</xsl:when><xsl:otherwise>
							</xsl:otherwise></xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</field>
	</xsl:template>


</xsl:stylesheet>
