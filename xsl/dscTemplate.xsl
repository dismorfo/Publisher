<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ns2="http://www.w3.org/1999/xlink" version="2.0" xpath-default-namespace="urn:isbn:1-931666-22-9">
<!--<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ns2="http://www.w3.org/1999/xlink" version="2.0">-->
<!--CONTENTS-->
<!--TEMPLATE DSC 
		PROCESSES HEADER DSC DATA
		
		2008-07-17
		DELETED MANY DEPRECATED TEMPLATES - 
		THESE CAN BE FOUND IN SUBVERSION REVISIONS EARLIER THAN 5453
		
		
		-->
	<xsl:template name="dsc">
		<xsl:message select="'here'"/>
		<xsl:for-each select="archdesc/dsc[1]">
			<xsl:comment>Begin iteration: archdesc/dsc</xsl:comment>
			<h3>
				<a name="{$containerLink}"/>
				<xsl:choose>
					<xsl:when test="string-length(head)">
						<xsl:message select="'head'"/>
						<xsl:apply-templates select="head"/>
					</xsl:when>
					<xsl:otherwise><xsl:message select="'list'"/>
						Container List
					</xsl:otherwise>
				</xsl:choose>
			</h3>
			<xsl:if test="p">
				<p style="margin-left: 25 pt">
					<i>
						<xsl:apply-templates select="p"/>
					</i>
				</p>
			</xsl:if>
		</xsl:for-each>
		<xsl:comment>End iteration</xsl:comment>
		<table class="c_table" cellpadding="0" cellspacing="0" width="100%">
			<xsl:for-each select="archdesc/dsc/*[name(..)='dsc']">
				<xsl:variable name="seriesNum">
					<xsl:number/>
				</xsl:variable>
				<tr>
					<td>
						<a name="{concat('series',$seriesNum)}"/>
					</td>
				</tr>
				<xsl:call-template name="process_c"/>
			</xsl:for-each>
		</table>
	</xsl:template>
<!--New universal 'note' template added by Brian Hoffman 1-14-2008 
		to replace various inline note treatments in the templates above-->
	<xsl:template name="noteRow">
		<xsl:param name="cols" select="4"/>
		<xsl:param name="noteCol" select="2"/>
		<xsl:param name="row-color" select="'#FFFFFF'"/>
		<tr style="background-color: {$row-color}; border: none; padding: none;">
			<xsl:call-template name="noteCells">
				<xsl:with-param name="cols" select="$cols"/>
				<xsl:with-param name="noteCol" select="$noteCol"/>
			</xsl:call-template>
		</tr>
	</xsl:template>
	<xsl:template name="noteCells">
		<xsl:param name="cols"/>
		<xsl:param name="noteCol"/>
		<xsl:param name="currentCol" select="1"/>
		<xsl:choose>
			<xsl:when test="$currentCol = $noteCol">
				<td class="noteCell" colspan="{1 + $cols - $currentCol}">
					<xsl:copy-of select="."/>
				</td>
			</xsl:when>
			<xsl:otherwise>
				<td/>
				<xsl:call-template name="noteCells">
					<xsl:with-param name="cols" select="$cols"/>
					<xsl:with-param name="noteCol" select="$noteCol"/>
					<xsl:with-param name="currentCol" select="$currentCol + 1"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
<!--NEW TEMPLATES DLTS 2008 -->
	<xsl:template name="process_c">
		<xsl:param name="nestingLevel" select="0"/>
		<xsl:variable name="row-color">
			<xsl:choose>
				<xsl:when test="position() mod 2 = 1 and not(child::c) and not(child::c02) and not(child::c03) and not(child::c04) and not(child::c05)">
					<xsl:value-of select="'#EEEEEE'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'#FFFFFF'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="@level = 'series' or @level = 'subseries' or(@level='otherlevel' and *[@level])">
				<tr>
					<td colspan="5">
						<a name="{generate-id()}"/>
						<xsl:choose>
							<xsl:when test="@level = 'series'">
								<h3>
									<xsl:apply-templates select="did/unittitle/text() | did/unittitle/node()"/>
								</h3>
							</xsl:when>
							<xsl:otherwise>
								<h4>
									<xsl:apply-templates select="did/unittitle/text() | did/unittitle/node()"/>
								</h4>
							</xsl:otherwise>
						</xsl:choose>
					</td>
				</tr>
				<xsl:for-each select="scopecontent">
					<tr>
						<td colspan="5" style="padding-right:20px;">
							<xsl:call-template name="process_scopecontent">
								<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
							</xsl:call-template>
						</td>
					</tr>
				</xsl:for-each>
				<xsl:for-each select="separatedmaterial/p">
					<xsl:call-template name="separatedmaterial"/>
				</xsl:for-each>
				
				
				<!--DAOs in SSeries-->
				<xsl:if test="child::dao">
					<tr class="item_description_row" style="background-color: {$row-color}">
						<td colspan="5" style="padding-right:20px; font-size: 0.8em; vertical-align:top;">
							<div style="margin-left: 10px; vertical-align:top;">
								<table>
									<tr>

										<xsl:if test="child::dao">

											<td>
												<xsl:call-template name="process_daos">
	<!--												<xsl:with-param name="daos" select="child::dao[not(contains(@ns2:href, 'dao_files'))]"/>-->
	<xsl:with-param name="daos" select="child::dao"/>
													<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
												</xsl:call-template>
											</td>
										</xsl:if>
										<td>
											<xsl:for-each select="child::accessrestrict | child::userestrict">
												<xsl:call-template name="process_any_restrict">
													<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
												</xsl:call-template>
											</xsl:for-each>
											<xsl:for-each select="descendant::phystech">
												<xsl:call-template name="process_phystech">
													<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
												</xsl:call-template>
											</xsl:for-each>
											<xsl:for-each select="descendant::note">
												<xsl:call-template name="process_note">
												</xsl:call-template>
											</xsl:for-each>
											<xsl:for-each select="descendant::odd[not(@audience = 'internal')]">
												<xsl:call-template name="process_note">
												</xsl:call-template>
											</xsl:for-each>
										</td>
									</tr>
								</table>
							</div>
						</td>
					</tr>
				</xsl:if>
				<!--END DAOS IN SERIES-->
				
				
				
				
				
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="position() = 1 and (count(c) != 0 or count(c02) != 0 or count(c03) !=0 or count(c04) != 0 or count(c05) != 0 or parent::*[(@level='series') or (@level='subseries')] or (@level='otherlevel' and not(*[@level])) or @level='item' or @level='file')">
					<tr>
						<xsl:call-template name="dsc_table_headers"/>
					</tr>
				</xsl:if>
				<tr class="did_row" style="background-color: {$row-color}">
					<xsl:for-each select="child::did">
						<xsl:call-template name="process_did">
							<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
						</xsl:call-template>
					</xsl:for-each>
				</tr>
				<tr class="did_row" style="background-color: {$row-color}">
					<xsl:for-each select="separatedmaterial/p">
						<xsl:call-template name="separatedmaterial"/>
					</xsl:for-each>
				</tr>
<!--A ROW TO HOLD THE ESSENCE AND THE MINOR METADATA-->
				<tr class="item_description_row" style="background-color: {$row-color}">
					<td colspan="5" style="padding-right:20px; font-size: 0.8em; vertical-align:top;">
						<div style="margin-left: 10px; vertical-align:top;">
							<table>
								<tr>

									<xsl:if test="child::dao">

										<td>
											<xsl:call-template name="process_daos">
<!--												<xsl:with-param name="daos" select="child::dao[not(contains(@ns2:href, 'dao_files'))]"/>-->
<xsl:with-param name="daos" select="child::dao"/>
												<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
											</xsl:call-template>
										</td>
									</xsl:if>
									<td>
										<xsl:for-each select="child::accessrestrict | child::userestrict">
											<xsl:call-template name="process_any_restrict">
												<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
											</xsl:call-template>
										</xsl:for-each>
										<xsl:for-each select="descendant::phystech">
											<xsl:call-template name="process_phystech">
												<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
											</xsl:call-template>
										</xsl:for-each>
										<xsl:for-each select="descendant::note">
											<xsl:call-template name="process_note">
											</xsl:call-template>
										</xsl:for-each>
										<xsl:for-each select="descendant::odd[not(@audience = 'internal')]">
											<xsl:call-template name="process_note">
											</xsl:call-template>
										</xsl:for-each>
									</td>
								</tr>
							</table>
						</div>
					</td>
				</tr>
<!--END THE SECOND ROW-->
<!--SEPERATOR ROW IF NEEDED-->
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="position() = last() and not(child::c) and not(child::c02) and not(child::c03) and not(child::c04) and not(child::c05)">
			<tr>
				<td colspan="5">
					<p>
						<a href="#top">Return to top</a>
					</p>
					<hr/>
				</td>
			</tr>
<!--
					<xsl:choose>
						<xsl:when test="not(parent::*[contains(@level,'series')])">
							<tr>
								<xsl:call-template name="dsc_table_headers"/>
							</tr>
						</xsl:when>
					</xsl:choose>
					-->
		</xsl:if>
<!--RECURSIVELY DESCEND THROUGH THE HEIRARCHY-->
		<xsl:for-each select="child::c | child::c02 | child::c03 | child::c04 | child::c05">
			<xsl:call-template name="process_c">
				<xsl:with-param name="nestingLevel" select="$nestingLevel + 1"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="process_daos">
		<xsl:param name="nestingLevel" select="0"/>
		<xsl:param name="daos"/>


		<xsl:choose>
			<xsl:when test="$daos[@ns2:role = 'Image-Thumbnail'] and $daos[@ns2:role = 'Image-Service']">
				<xsl:variable name="service-uri" select="$daos[@ns2:role = 'Image-Service'][1]/@ns2:href"/>
				<xsl:variable name="thumbnail-uri" select="$daos[@ns2:role = 'Image-Thumbnail'][1]/@ns2:href"/>
				<a id="daoLink" href="{$service-uri}" target="new">
					<img src="{$thumbnail-uri}" title="click to enlarge" style="float:left; margin-right: 10px"/>
				</a>
			</xsl:when>
			<!--duplicating for Tamiment's nomenclature-->
			<xsl:when test="$daos[@ns2:role = 'thumb'] and $daos[@ns2:role = 'service']">
				<xsl:variable name="service-uri" select="$daos[@ns2:role = 'service'][1]/@ns2:href"/>
				<xsl:variable name="thumbnail-uri" select="$daos[@ns2:role = 'thumb'][1]/@ns2:href"/>
				<a id="daoLink" href="{$service-uri}" target="new">
					<img src="{$thumbnail-uri}" title="click to enlarge" style="float:left; margin-right: 10px"/>
				</a>
			</xsl:when>
			<xsl:when test="$daos[@ns2:role = 'Image-Thumbnail']">
				<xsl:variable name="thumbnail-uri" select="$daos[@ns2:role = 'Image-Thumbnail'][1]/@ns2:href"/>
				<img src="{$thumbnail-uri}" title="click to enlarge" style="float:left; margin-right: 10px"/>
			</xsl:when>
			<xsl:when test="$daos[@ns2:role = 'thumb']">
				<xsl:variable name="thumbnail-uri" select="$daos[@ns2:role = 'thumb'][1]/@ns2:href"/>
				<img src="{$thumbnail-uri}" title="click to enlarge" style="float:left; margin-right: 10px"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="$daos">

					<xsl:variable name="uri" select="@ns2:href" />


				<a id="daoLink" href="{$uri}" target="new">
					<xsl:choose>
						<xsl:when test="descendant::daodesc">
							<xsl:copy-of select="descendant::daodesc" />
						</xsl:when>						
						<xsl:when test="@ns2:title">
							<xsl:value-of select="@ns2:title" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>Digital Object</xsl:text>
					</xsl:otherwise>
					</xsl:choose>

				</a>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="process_phystech">
		<xsl:param name="nestingLevel" select="0"/>
		<xsl:for-each select="p">
			<xsl:copy>
				<xsl:apply-templates/>
			</xsl:copy>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="process_any_restrict">
		<xsl:param name="nestingLevel" select="0"/>
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template name="process_scopecontent">
		<xsl:param name="nestingLevel" select="0"/>
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template name="process_note">
		<xsl:for-each select="p">
			<xsl:copy>
				<xsl:apply-templates/>
			</xsl:copy>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="process_did">
		<xsl:param name="nestingLevel" select="0"/>
		<td label="box" class="c_box">
			<a name="{generate-id(parent::*)}"/>
<!--			<xsl:if test="container[@type = 'Box'] or container[@type = 'box'] or container[position() = 1]">-->
			<xsl:if test="container[position() = 1] and not(container[position() = 1]/@type = 'item')">
<!--the negative condition is for RISM-->
				<b>
<!--					<xsl:value-of select="normalize-space(container[contains(@type, 'ox')])"/>-->
					<xsl:value-of select="normalize-space(container[position() = 1])"/>
				</b>
			</xsl:if>
		</td>
		<td label="Folder" class="c_folder">
<!--			<xsl:if test="container[contains(@type, 'older')]">-->
<!--				<xsl:for-each select="container[contains(@type, 'older')]">-->
			<xsl:if test="container[position() = 2]">
				<xsl:for-each select="container[position() = 2]">
					<xsl:value-of select="normalize-space(.)"/>
				</xsl:for-each>
			</xsl:if>
		</td>
		<xsl:if test="container[@type = 'volume']">
			<td label="Item" class="c_item">
				<xsl:for-each select="container[@type = 'volume']">
					<xsl:value-of select="normalize-space(text())"/>
				</xsl:for-each>
			</td>
		</xsl:if>
		<xsl:if test="not(container[@type = 'volume'][string-length() &gt; 1]) and not(container[@type = 'item'][string-length() &gt; 1])">
			<td style="padding-right:25pt"/>
		</xsl:if>
		<xsl:if test="container[@type = 'item']">
			<td label="Item" class="c_item">
				<xsl:for-each select="container[@type = 'item']">
					<xsl:value-of select="normalize-space(text())"/>
				</xsl:for-each>
			</td>
		</xsl:if>
		<td label="title" class="title">
<!--<xsl:if test="container">-->
			<xsl:variable name="folderTitle">
				<xsl:choose>
					<xsl:when test="following-sibling::c and container[contains(@type, 'older')]">
						<xsl:value-of select="concat('Folder: ',unittitle)"/>
					</xsl:when>
					<xsl:otherwise>
<!--
							<xsl:value-of select="unittitle"/>
							<xsl:for-each select="unittitle/node()">
							-->
						<xsl:apply-templates select="unittitle/node() | unittitle/text()"/>
<!--
							</xsl:for-each>		
							-->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<span class="unittitle_{../@level}">
				<xsl:copy-of select="$folderTitle"/>
			</span>
<!--</xsl:if>-->
		</td>
		<td label="date" class="c_date">
			<xsl:if test="unitdate">
				<xsl:for-each select="unitdate">
					<xsl:value-of select="text()"/>
				</xsl:for-each>
			</xsl:if>
		</td>
	</xsl:template>
	<xsl:template name="dsc_table_headers">
		<th>
			<xsl:choose>
<!--The 'not' below is to keep some RISM item numbers from showing up in the Box column-->
				<xsl:when test="did/container[position() = 1][@type] and not(did/container[position() = 1]/@type = 'item')">
					<xsl:value-of select="did/container[position() = 1]/@type"/>
				</xsl:when>
				<xsl:otherwise>Box</xsl:otherwise>
			</xsl:choose>
		</th>
		<th>
			<xsl:choose>
				<xsl:when test="did/container[position() = 2][@type]">
					<xsl:value-of select="did/container[position() = 2]/@type"/>
				</xsl:when>
				<xsl:when test="descendant::container[@type = 'Folder' or @type = 'folder']">Folder</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
		</th>
		<th>
			<xsl:choose>
				<xsl:when test="did/container[position() = 3][@type]">
					<xsl:value-of select="did/container[position() = 3]/@type"/>
				</xsl:when>
				<xsl:when test="following-sibling::*/did/container[@type='item'] or did/container[@type='item']">Item
		</xsl:when>
				<xsl:when test="following-sibling::*/did/container[@type='volume'] or did/container[@type='volume']">
			Vol.
		</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="style">padding-right:25 pt</xsl:attribute>
					<xsl:text> </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</th>
		<th>Title</th>
		<th>Date</th>
	</xsl:template>
	<xsl:template name="processSerials">
		<xsl:param name="processSeriesNode"/>
		<xsl:param name="contentFrameFilename"/>
<!-- Displays the title and date of each series and numbers
            them to form a hyperlink to the base document. -->
		<xsl:for-each select="$processSeriesNode">
			<xsl:comment>Begin iteration: processSeriesNode</xsl:comment>
			<a class="processSeriesTitles" href="{$contentFrameFilename}#{generate-id()}" target="content">
<!--series titles-->
				<xsl:choose>
					<xsl:when test="did/unittitle/unitdate">
						<xsl:for-each select="did/unittitle">
							<xsl:comment>Begin iteration: did/unittitle</xsl:comment>
							<xsl:apply-templates select="text()|*[not(self::unitdate)]"/>
							<xsl:text> </xsl:text>
							<xsl:apply-templates select="./unitdate"/>
							<xsl:comment>End iteration: did/unittitle</xsl:comment>
						</xsl:for-each>
						<xsl:comment>End iteration</xsl:comment>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="did/unittitle/text() | did/unittitle/node()"/>
						<xsl:text> </xsl:text>
						<xsl:apply-templates select="did/unitdate"/>
					</xsl:otherwise>
				</xsl:choose>
			</a>
			<xsl:if test="*[@level='subseries']">
				<xsl:call-template name="processSeriesSubTitles">
					<xsl:with-param name="subSeriesNode" select="*[@level='subseries']"/>
					<xsl:with-param name="contentFrameFilename" select="$contentFrameFilename"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:comment>End iteration: processSeriesNode</xsl:comment>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="processSeriesSubTitles">
		<xsl:param name="subSeriesNode"/>
		<xsl:param name="contentFrameFilename"/>
<!--sub titles of series-->
		<xsl:for-each select="$subSeriesNode">
			<xsl:comment>Begin iteration: $subSeriesNode</xsl:comment>
			<xsl:variable name="subseriesLink">
				<xsl:number level="any" format="1"/>
			</xsl:variable>
			<a class="processSeriesSubTitles" href="{$contentFrameFilename}#{generate-id()}" target="content">
				<xsl:choose>
					<xsl:when test="did/unittitle/unitdate">
						<xsl:for-each select="did/unittitle">
							<xsl:comment>Begin iteration: did/unittitle</xsl:comment>
							<xsl:apply-templates select="text()|*[not(self::unitdate)]"/>
							<xsl:text> </xsl:text>
							<xsl:apply-templates select="./unitdate"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="did/unittitle/text() | did/unittitle/node()"/>
						<xsl:text> </xsl:text>
						<xsl:apply-templates select="did/unitdate"/>
					</xsl:otherwise>
				</xsl:choose>
			</a>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="separatedmaterial">
		<tr>
			<td width="10%"> </td>
			<td width="10%"> </td>
			<td width="80%" colspan="2">
				<div>
					<i>
						<xsl:apply-templates select="."/>
					</i>
				</div>
			</td>
<!--<td width="40%">&#x00A0;</td>-->
		</tr>
	</xsl:template>
</xsl:stylesheet>
