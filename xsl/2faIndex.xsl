<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output method="html" indent="yes" name="html"/>
	<xsl:param name="CONTENT_URI"/>
	<xsl:param name="CONTENT_PATH"/>
	<xsl:param name="SOLR1_URI"/>
	<xsl:template match="/">
		<xsl:apply-templates select="findingaids"/>
	</xsl:template>
	<xsl:template match="findingaids">
		<xsl:call-template name="faIndex"/>
	</xsl:template>
	<xsl:template name="faIndex">
		<xsl:result-document href="{$CONTENT_PATH}/index.html" format="html">
			<html>
				<head>
					<style type="text/css">		
								@import "<xsl:value-of select="$CONTENT_URI"/>/css/results.css";
				    </style>
					<script type="text/javascript" src="{$CONTENT_URI}/js/queryTools.js"/>
				</head>
				<body onload="checkSelects('simpleSearchForm');" bgcolor="#eff0e8">
					<div id="maincontainer">
						<div id="topsection">
							<table cellpadding="0" cellspacing="0" width="100%">
								<tr>
									<td style="background: #A4121F;" width="270px;"> </td>
									<td>
										<a href="http://library.nyu.edu">
											<img src="{$CONTENT_URI}/images/banner2.gif" border="0px"/>
										</a>
									</td>
								</tr>
							</table>
						</div>
						<div id="contentwrapper">
							<div id="contentcolumn">
								<div class="innertube" style="width: 720px;">
									<h2>Search Finding Aids</h2>
									<p>Use the search box to search finding aids for any or all of these collections:</p>
									<ul>
										<xsl:for-each select="//list[@name='collections']/item">
											<li>
												<a href="{uri}" style="text-decoration: none;">
													<xsl:value-of select="longname"/>
												</a>
											</li>
										</xsl:for-each>
									</ul>
									
									<div class="doc">
										<div style="background-color:#EEE8CD; padding: 10px 10px 10px 20px; ">
										<h3>Search for</h3><form id="simpleSearchForm" method="get" action="search/" style="padding:0px; margin:0px; margin-right:20px;"><input class="inputBorder" type="text" name="q" size="20"/> in <select name="collectionId" id="collectionSelect"><option value="">All Collections</option><xsl:for-each select="//list[@name='collections']/item"><option value="{@id}"><xsl:value-of select="longname"/></option></xsl:for-each></select></form><br/><a class="button" href="#" onclick="document.getElementById('simpleSearchForm').submit()" id="submitBtn"><u>Submit Search Query</u></a>
									
									</div>

									<h3>Tips for Searching</h3><p>By default, the search engine will return items with ALL of your search terms. If you would like to see finding aids with <i>either</i> of two or more search terms, use the OR operator.</p>
			<div style="padding: 10px; ">Example: <span style="background-color:white; padding: 2px">&#160;Spanish OR Portugese&#160;</span></div><p>If you would like to search for an exact phrase, place the phrase in quotes.</p>
			<div style="padding: 10px; padding-bottom: 10px;">Example: <span style="background-color:white; padding: 2px">&quot;Give me Liberty&quot;</span></div>

		</div>
								</div>
							</div>
						</div>
					</div>
				</body>
			</html>
		</xsl:result-document>
	</xsl:template>
</xsl:stylesheet>
