<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:local="http://dlib.nyu.edu/findingaids/ns" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ns2="http://www.w3.org/1999/xlink" version="2.0" xpath-default-namespace="urn:isbn:1-931666-22-9">
    <!--
        *******************************************************************
        *                                                                 *
        * AUTHOR:           Winona Salesky                                *
        *                   wsalesky@gmail.com                            *
        *                                                                 *
        * UPDATED:          August 16, 2010                                 *
        *                                                                 *
        * DESCRIPTION:      Based on the Archivists' ToolKit stylesheets  *
        *                   addapted for NYU.                             *
        *******************************************************************
    --> 
    <!--
        *******************************************************************
        *                                                                 *
        * UPDATER / OWNER:  Brian Hoffman			                      *
        *                   bh@nyu.edu			                          *
        *                                                                 *
        *******************************************************************
    -->
        
    <!--Basic Parameters-->
	<xsl:param name="targetDir" />
    <!--short name for the archive to which the EAD belongs-->
    <xsl:param name="collectionName"/>
    <!--search URI from conf file-->
    <xsl:param name="searchURI"/>
    <!--root of the content on the file system-->
    <xsl:param name="contentURI"/>
    <xsl:param name="collPage"/>
    <xsl:param name="contentType"/>
  
    <!-- Finding aid id, should be established in AT export, but if not it will be pulled form the filename -->
    <xsl:variable name="id">
        <xsl:choose>
            <xsl:when test="/ead/eadheader/eadid"><xsl:value-of select="/ead/eadheader/eadid"/></xsl:when>
            <xsl:otherwise>
                <xsl:variable name="filename" select="tokenize(base-uri(.), '/')[last()]"/>
                <xsl:value-of select="substring-before($filename,'.')"></xsl:value-of>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:variable>

    <!-- Local function to make more friendly dates -->
    <xsl:function name="local:stringDate">
        <xsl:param name="date"/>
        <xsl:variable name="shortDate">
            <xsl:choose>
                <xsl:when test="contains($date, 'T')">
                    <xsl:value-of select="substring-before($date,'T')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$date"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-length($shortDate) = 4">
                <xsl:value-of select="$shortDate"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="tokenize($shortDate, '-')[2] = '01'">January</xsl:when>
                    <xsl:when test="tokenize($shortDate, '-')[2] = '02'">February</xsl:when>
                    <xsl:when test="tokenize($shortDate, '-')[2] = '03'">March</xsl:when>
                    <xsl:when test="tokenize($shortDate, '-')[2] = '04'">April</xsl:when>
                    <xsl:when test="tokenize($shortDate, '-')[2] = '05'">May</xsl:when>
                    <xsl:when test="tokenize($shortDate, '-')[2] = '06'">June</xsl:when>
                    <xsl:when test="tokenize($shortDate, '-')[2] = '07'">July</xsl:when>
                    <xsl:when test="tokenize($shortDate, '-')[2] = '08'">August</xsl:when>
                    <xsl:when test="tokenize($shortDate, '-')[2] = '09'">September</xsl:when>
                    <xsl:when test="tokenize($shortDate, '-')[2] = '10'">October</xsl:when>
                    <xsl:when test="tokenize($shortDate, '-')[2] = '11'">November</xsl:when>
                    <xsl:when test="tokenize($shortDate, '-')[2] = '12'">December</xsl:when>
                </xsl:choose>
                <xsl:text>&#160;</xsl:text>
                <xsl:value-of select="concat(tokenize($shortDate, '-')[3],', ')"/>
                <xsl:value-of select="tokenize($shortDate, '-')[1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:strip-space elements="*"/>
    <!-- Transitional  xhtml1-transitional.dtd -->
    <xsl:output indent="yes" method="xhtml" omit-xml-declaration="yes" exclude-result-prefixes="#all" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" encoding="utf-8"/>
    <!-- Main template calls ead root element -->
    <xsl:template match="/">
        <!-- Generates Ajax driven version -->
        <xsl:apply-templates select="ead"/>
        <!-- Print version, one long HTML page -->
        <xsl:apply-templates select="ead" mode="print"/>
    </xsl:template>
   
   <!-- Pre-defined sections/pages generated for Ajax view -->
    <xsl:template match="ead">
        <xsl:call-template name="html">
            <xsl:with-param name="templateName">summary</xsl:with-param>
        </xsl:call-template>    
        <xsl:if test="archdesc/bioghist">
            <xsl:call-template name="html">
                <xsl:with-param name="templateName">bioghist</xsl:with-param>
            </xsl:call-template>        
        </xsl:if>
        <xsl:if test="archdesc/scopecontent or archdesc/arrangement">
            <xsl:call-template name="html">
                <xsl:with-param name="templateName">scopecontent</xsl:with-param>
            </xsl:call-template>  
        </xsl:if>
        <xsl:if test="archdesc/controlaccess">
            <xsl:call-template name="html">
                <xsl:with-param name="templateName">controlaccess</xsl:with-param>
            </xsl:call-template>  
        </xsl:if>
        <xsl:if test="archdesc/custodhist or 
            archdesc/prefercite or archdesc/accruals or 
            archdesc/altformavail or archdesc/acqinfo or 
            archdesc/processinfo or archdesc/appraisal or archdesc/originalsloc
            or archdesc/userestrict or archdesc/accessrestrict or archdesc/relatedmaterial
            or archdesc/separatedmaterial">
            <xsl:call-template name="html">
                <xsl:with-param name="templateName">admininfo</xsl:with-param>
            </xsl:call-template> 
        </xsl:if>
        <!--Creates a section for each top level c element  -->
        <xsl:for-each select="archdesc/dsc/c | archdesc/dsc/c01">
            <xsl:call-template name="html">
                <xsl:with-param name="templateName"><xsl:value-of select="concat('dsc',@id)"/></xsl:with-param>
            </xsl:call-template>
        </xsl:for-each>        
    </xsl:template>

    <!-- 
        HTML template -  Generates basic page for individual sections uses the 
        parameter templateName to select main conent area
    -->    
    <xsl:template name="html">
        <!-- Internal parameter used to select page content, default generates the index page -->
        <xsl:param name="templateName">summary</xsl:param>
        <!-- File name based on page content -->
        <xsl:variable name="fileName">
            <xsl:choose>
                <xsl:when test="$templateName = 'summary'">index</xsl:when>
                <xsl:otherwise><xsl:value-of select="$templateName"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- Output html page -->
        <xsl:result-document href="{$targetDir}/{$id}/{$fileName}.html">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <meta http-equiv="Content-Type" content="text/xhtml; charset=utf-8"/>
                <title>
                    <xsl:value-of select="/ead/eadheader/filedesc/titlestmt/titleproper"/>                
                </title>
                <!--<xsl:call-template name="metadata"/>-->
                <link rel="stylesheet" type="text/css" href="{$contentURI}/css/nyuEAD.css"/>
                <script type='text/javascript' src="{$contentURI}/js/jquery.js">&#160;</script>
                <script type='text/javascript' src="{$contentURI}/js/jquery-scrollTo.js">&#160;</script>                
                <script type='text/javascript' src="{$contentURI}/js/jquery-hashchange.min.js">&#160;</script>
                <script type="text/javascript" src="{$contentURI}/js/nyuEAD.js">&#160;</script> 
            </head>
            <body class="{$collectionName}">
                <div id="main">
                    <!-- Calls named template to generate table of contents -->
                    <div id="tocWrapper">
                        <xsl:call-template name="toc"/>
                    </div>
                    <div id="body-container"> 
                        <p id="top"><a href="{$id}.html">Print</a></p>                        
                            <xsl:call-template name="header"/>
                            <div id="main-content">
                                <div id="ajaxContent">
                                <!-- Choses page content based on templateName parameter -->
                                <xsl:choose>
                                    <xsl:when test="$templateName = 'summary'"><xsl:call-template name="summary"/></xsl:when>
                                    <xsl:when test="$templateName = 'bioghist'"><xsl:call-template name="bioghist"/></xsl:when>
                                    <xsl:when test="$templateName = 'scopecontent'"><xsl:call-template name="scopecontent"/></xsl:when>
                                    <xsl:when test="$templateName = 'controlaccess'"><xsl:call-template name="controlaccess"/></xsl:when>
                                    <xsl:when test="$templateName = 'admininfo'">
                                        <h3>Administrative Information</h3>
                                        <xsl:call-template name="admininfo"/>
                                    </xsl:when>
                                    <xsl:when test="starts-with($templateName,'dsc')"><xsl:call-template name="dsc"/></xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>
                                </div>        
                            </div>
                    </div>    
                </div>
            </body>
        </html>
        </xsl:result-document>
    </xsl:template>
    
    <!-- Named templates organizing page contents -->
    <xsl:template name="summary">
        <xsl:apply-templates select="archdesc/did"/>
    </xsl:template>  
    <xsl:template name="bioghist">
        <xsl:apply-templates select="archdesc/bioghist"/>
    </xsl:template>    
    <xsl:template name="scopecontent">
        <xsl:apply-templates select="archdesc/scopecontent"/>
        <xsl:apply-templates select="archdesc/arrangement"/>
    </xsl:template>
    <xsl:template name="controlaccess">
        <xsl:apply-templates select="archdesc/controlaccess"/>
    </xsl:template>
    <xsl:template name="admininfo">
        <xsl:apply-templates select="archdesc/custodhist"/>
        <xsl:apply-templates select="archdesc/accessrestrict"/>
        <xsl:apply-templates select="archdesc/userestrict"/>
        <xsl:apply-templates select="archdesc/prefercite"/>    
        <xsl:apply-templates select="archdesc/relatedmaterial"/>
            <xsl:apply-templates select="archdesc/daogrp"/>
            <xsl:apply-templates select="archdesc/dao"/>
            <xsl:apply-templates select="archdesc/otherfindaid"/>
        <xsl:apply-templates select="archdesc/separatedmaterial"/>
        
        <xsl:apply-templates select="archdesc/phystech"/>
        <xsl:apply-templates select="archdesc/odd"/>
        
        <xsl:apply-templates select="archdesc/altformavail"/>                                
        <xsl:apply-templates select="archdesc/acqinfo"/>
        <xsl:apply-templates select="archdesc/processinfo"/>
        <xsl:apply-templates select="archdesc/appraisal"/>
        <xsl:apply-templates select="archdesc/accruals"/>
        <xsl:apply-templates select="archdesc/originalsloc"/>
        
        <xsl:apply-templates select="archdesc/bibliography"/>
        <xsl:apply-templates select="archdesc/index"/>                                    
        
    </xsl:template>
    <xsl:template name="dsc">
        <div class="{name()}">  
            <xsl:choose>
                <xsl:when test="head">
                    <xsl:apply-templates select="head"/>
                </xsl:when>
                <xsl:otherwise>
                    <h3><xsl:call-template name="anchor"/>Container List</h3>
                </xsl:otherwise>
            </xsl:choose>
            <!--<xsl:if test="p">
                <p>
                <em><xsl:apply-templates select="p"/></em>
                </p>
                </xsl:if>-->
            <!-- Creates a table for container lists, defaults to 6 cells, for up to 4 container lists, one title and a date.  -->
            <table class="containerList">
                <xsl:apply-templates select="."/>
                <tr>
                    <td style="width: 10%;"/>
                    <td style="width: 10%;"/>
                    <td style="width: 10%;"/>
                    <td/>
                    <td style="width: 15%;"/>
                </tr>
                
            </table>
        </div>
    </xsl:template>
    
    <!-- Outputs full finding aid on a single page for printing -->
    <xsl:template match="ead" mode="print">
        <xsl:result-document href="{$targetDir}/{$id}/{$id}.html">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <meta http-equiv="Content-Type" content="text/xhtml; charset=utf-8"/>
                <title>
                    <xsl:value-of select="/ead/eadheader/filedesc/titlestmt/titleproper"/>              
                </title>
                <!--<xsl:call-template name="metadata"/>-->
                <link rel="stylesheet" type="text/css" href="http://dlib.nyu.edu/findingaids/css/nyuEAD.css"/>
                <script type='text/javascript' src="http://dlib.nyu.edu/findingaids/js/jquery.js"></script>
                <script type='text/javascript' src="http://dlib.nyu.edu/findingaids/js/jquery-scrollTo.js"></script>                
                <script type='text/javascript' src='http://dlib.nyu.edu/findingaids/js/jquery-hashchange.min.js'></script>
                <script type="text/javascript" src="http://dlib.nyu.edu/findingaids/js/nyuEAD.js"></script> 
            </head>
            <body>
                <div id="main">         
                        <div id="contents">
                            <xsl:call-template name="header"/>
                            
                            <!-- Summary Information, summary information includes citation -->
                            <xsl:apply-templates select="archdesc/did"/>
                            <xsl:call-template name="returnTop"/>
                            <div id="bioghist">
                            <xsl:apply-templates select="archdesc/bioghist"/>
                            </div>
                            <xsl:call-template name="returnTop"/>
                            <div id="scopecontent">
                            <xsl:apply-templates select="archdesc/scopecontent"/>
                            <xsl:apply-templates select="archdesc/arrangement"/>
                            </div>
                            <xsl:call-template name="returnTop"/>
                            <div id="controlaccess">
                            <xsl:apply-templates select="archdesc/controlaccess"/>
                            </div>
                            <xsl:call-template name="returnTop"/>
                            <!-- Administrative Information  -->
                            <xsl:if test="archdesc/custodhist or 
                                archdesc/prefercite or archdesc/accruals or 
                                archdesc/altformavail or archdesc/acqinfo or 
                                archdesc/processinfo or archdesc/appraisal or archdesc/originalsloc
                                or archdesc/userestrict or archdesc/accessrestrict or archdesc/relatedmaterial
                                or archdesc/separatedmaterial">
                                <div class="adminInfo">
                                <h3 id="adminInfo">Administrative Information</h3>
                                    <xsl:apply-templates select="archdesc/custodhist"/>
                                    <xsl:apply-templates select="archdesc/accessrestrict"/>
                                    <xsl:apply-templates select="archdesc/userestrict"/>
                                    <xsl:apply-templates select="archdesc/prefercite"/>    
                                    <xsl:apply-templates select="archdesc/relatedmaterial"/>
                                        <xsl:apply-templates select="archdesc/daogrp"/>
                                        <xsl:apply-templates select="archdesc/dao"/>
                                        <xsl:apply-templates select="archdesc/otherfindaid"/>
                                    <xsl:apply-templates select="archdesc/separatedmaterial"/>
                                    
                                    <xsl:apply-templates select="archdesc/phystech"/>
                                    <xsl:apply-templates select="archdesc/odd"/>

                                    <xsl:apply-templates select="archdesc/altformavail"/>                                
                                    <xsl:apply-templates select="archdesc/acqinfo"/>
                                    <xsl:apply-templates select="archdesc/processinfo"/>
                                    <xsl:apply-templates select="archdesc/appraisal"/>
                                    <xsl:apply-templates select="archdesc/accruals"/>
                                    <xsl:apply-templates select="archdesc/originalsloc"/>

                                    <xsl:apply-templates select="archdesc/bibliography"/>
                                    <xsl:apply-templates select="archdesc/index"/>                                    
                                    
                                </div>
                            </xsl:if>
        
                            <!--NOTE: orphan element(s) 
                            <xsl:apply-templates select="archdesc/fileplan"/>
                            -->
                            <xsl:call-template name="returnTop"/>
                            <xsl:if test="archdesc/dsc/child::*">
                                <xsl:apply-templates select="archdesc/dsc"/>  
                            </xsl:if>
                            <xsl:call-template name="returnTop"/>
                        </div> 
                </div>
            </body>
        </html>
        </xsl:result-document>
    </xsl:template>
    <xsl:template name="returnTop">                
        <p class="returnTop"><a href="#top">Return to Top »</a></p>
        <hr/>
    </xsl:template>
    <!-- NOTE: problematic namespace   HTML meta tags for use by web search engines for indexing. -->
    <xsl:template name="metadata">
        <meta http-equiv="Content-Type" name="dc.title" content="{concat(/ead/eadheader/filedesc/titlestmt/titleproper,' ',/ead/eadheader/filedesc/titlestmt/subtitle)}"/>
        <meta http-equiv="Content-Type" name="dc.author" content="{/ead/archdesc/did/origination}"/>
        <xsl:for-each select="/ead/archdesc/controlaccess/descendant::*">
            <meta http-equiv="Content-Type" name="dc.subject" content="{.}"/>
        </xsl:for-each>
        <meta http-equiv="Content-Type" name="dc.type" content="text"/>
        <meta http-equiv="Content-Type" name="dc.format" content="manuscripts"/>
        <meta http-equiv="Content-Type" name="dc.format" content="finding aids"/>
    </xsl:template>
    
    <!-- This template creates the for main content area header  -->
    <xsl:template name="header">
        <!--generating image based on archive name-->
        <xsl:variable name="headerSrc">
            <xsl:choose>
                <xsl:when test="$collectionName = 'tamwag'">
                    <xsl:value-of select="concat($contentURI, '/images/tamnew.jpg')"/>
                </xsl:when>
                <xsl:when test="$collectionName = 'fales'">
                    <xsl:value-of select="concat($contentURI, '/images/title2.gif')"/>
                </xsl:when>
                <xsl:when test="$collectionName = 'archives'">
                    <xsl:value-of select="concat($contentURI, '/images/ua_logo.gif')"/>
                </xsl:when>
                <xsl:when test="$collectionName = 'nyhs'">
                    <xsl:value-of select="concat($contentURI, '/images/nyhsa.jpg')"/>
                </xsl:when>
                <xsl:when test="$collectionName = 'phr'">
                    <xsl:value-of select="concat($contentURI, '/images/phr_header.gif')"/>
                </xsl:when>
                <xsl:when test="$collectionName = 'rism'">
                    <xsl:value-of select="concat($contentURI, '/images/rism.gif')"/>
                </xsl:when>
                <xsl:when test="$collectionName = 'bhs'">
                    <xsl:value-of select="concat($contentURI, '/images/72dpiBHSlogo_color_transpar.gif')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <img class="imgHeader" src="{$headerSrc}" alt="{concat(/ead/archdesc/did/repository,' logo')}" title="{string(/ead/archdesc/did/repository)}"/>
        <!--title header-->
        <p id="titleProper">
            <xsl:apply-templates select="/ead/eadheader/filedesc/titlestmt"/> 
        </p>
        <div class="eadHeader">
            <xsl:for-each select="/ead/eadheader/filedesc/publicationstmt">
                <!--formatting is slightly different from the rest of the div-->
                <p>
                    <xsl:apply-templates select="address"/>
                </p>
                <br />
                <xsl:apply-templates select="p"/>
                <p>
                    <xsl:value-of select="publisher"/>
                </p>
                <p>
                    <xsl:value-of select="replace(../titlestmt/author, 'Finding aid prepared by', 'Collection processed by')"/>
                </p>
            </xsl:for-each>
            <!-- Added profiledesc and revisiondesc for NYU display-->
            <xsl:for-each select="/ead/eadheader">
                   <xsl:apply-templates select="profiledesc"/>
                   <xsl:apply-templates select="revisiondesc"/>
            </xsl:for-each>
        </div>  
    </xsl:template>

    <!-- Creates an ordered table of contents in a fixed position div. -->  
    <xsl:template name="toc">
        <div id="toc">
<!--            <xsl:if test="string($collPage)">-->
                <a href="http://dlib.nyu.edu/findingaids/search/?q=&amp;collectionId={$collectionName}" class="display">See all finding aids in this repository</a>
<!--            </xsl:if>-->
            <h3>Table of Contents</h3>
            <dl>
                <!-- 
                    Ajaxtrigger class on toc items trigger page load event. 
                    If javascript is disabled links act as normal links. 
                -->
                <!-- Link to descriptive summary -->
                <xsl:if test="/ead/archdesc/did">
                    <dt>
                        <a class="ajaxtrigger" href="index.html">
                            <xsl:choose>
                                <xsl:when test="archdesc/did/head">
                                    <xsl:value-of select="archdesc/did/head"/>
                                </xsl:when>
                                <xsl:otherwise>Descriptive Summary</xsl:otherwise>
                            </xsl:choose>
                        </a>
                    </dt>
                </xsl:if>
                <!-- Link to biographical note -->
                <xsl:for-each select="/ead/archdesc/bioghist">
                    <dt>                                
                        <a class="ajaxtrigger" href="bioghist.html">
                            <xsl:choose>
                                <xsl:when test="head">
                                    <xsl:value-of select="head"/></xsl:when>
                                <xsl:otherwise>Biographical/Historical Note</xsl:otherwise>
                            </xsl:choose>
                        </a>
                    </dt>   
                </xsl:for-each>
                <!-- Link to scope and content note -->
                <xsl:for-each select="/ead/archdesc/scopecontent">
                    <dt>                                
                        <a class="ajaxtrigger" href="scopecontent.html">
                            <xsl:choose>
                                <xsl:when test="head">
                                    <xsl:value-of select="head"/></xsl:when>
                                <xsl:otherwise>Scope and Content</xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="/ead/archdesc/arrangement"> and Arrangement</xsl:if>
                        </a>
                    </dt>   
                </xsl:for-each>
                <!-- Link to arrangement note -->

                <!-- NOTE: orphan,   Link to arrangement file plan 
                <xsl:for-each select="/ead/archdesc/fileplan">
                    <dt>                                
                        <a><xsl:call-template name="tocLinks"/>
                            <xsl:choose>
                                <xsl:when test="head">
                                    <xsl:value-of select="head"/></xsl:when>
                                <xsl:otherwise>File Plan</xsl:otherwise>
                            </xsl:choose>
                        </a>
                    </dt>   
                </xsl:for-each>
                -->
                
               <!-- Link to access points note-->
                <xsl:for-each select="/ead/archdesc/controlaccess">
                    <dt>                                
                        <a class="ajaxtrigger" href="controlaccess.html">
                            <xsl:choose>
                                <xsl:when test="head">
                                    <xsl:value-of select="head"/></xsl:when>
                                <xsl:otherwise>Access Points</xsl:otherwise>
                            </xsl:choose>
                        </a>
                    </dt>   
                </xsl:for-each>
                <!-- Administrative Information  -->
                <dt><a class="ajaxtrigger" href="admininfo.html">Administrative Information</a></dt>
                
                
                <xsl:for-each select="/ead/archdesc/dsc">
                    <xsl:if test="child::*">
						<xsl:variable name="submenuID">
                        	<xsl:variable name="submenu">
                                <xsl:choose>
                                    <xsl:when test="child::*[@level = 'subfonds'] | child::*[@level = 'subgrp']  | child::*[@level = 'subseries'] | child::*[@level = 'collection'] | child::*[@level = 'recordgrp']  | child::*[@level = 'series'] | child::*[@level = 'fonds']">
                                        <xsl:value-of select="child::*[@level = 'subfonds'][1]/@id | child::*[@level = 'subgrp'][1]/@id 
                                            | child::*[@level = 'subseries'][1]/@id | child::*[@level = 'collection'][1]/@id
                                            | child::*[@level = 'recordgrp'][1]/@id  | child::*[@level = 'series'][1]/@id
                                            | child::*[@level = 'fonds'][1]/@id"/>                    
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>  
                             </xsl:variable>
                             <xsl:value-of select="concat('dsc',$submenu)"/>                                
                        </xsl:variable>
                        <dt>                                    
                            <span id="series1more" class="arrow" style="display:none;"><a href="#" onclick="showLayer('series1');"><img src="../../../css/images/more.gif" style="border:none; margin-right:4px;" alt="Expand menu"/></a> </span> 
                            <span id="series1less" class="arrow" style="display:inline;"><a  href="#" onclick="hideLayer('series1');"><img src="../../../css/images/less.gif" style="border:none; margin-right:4px;" alt="Minimize menu"/></a> </span>                            
							<a class="ajaxanchor" href="{concat($submenuID,'.html')}">
                                <xsl:choose>
                            		<xsl:when test="head">
                                    	<xsl:apply-templates select="child::*/head"/>        
                                   	</xsl:when>
                                    <xsl:otherwise>Container List</xsl:otherwise>
                              	</xsl:choose>
                          	</a>
                        </dt>                
                    </xsl:if>
                </xsl:for-each>
            </dl>
            <xsl:for-each select="/ead/archdesc/dsc">
                
                <!--Creates submenus for collections, record groups and series and fonds, currently goes only one level down, first subseries -->
                <div class="dsc" id="series1">
                    <xsl:for-each select="child::*[@level = 'collection'] | child::*[@level = 'recordgrp']  | child::*[@level = 'series'] | child::*[@level = 'fonds']">
                        <div class="level1">
                            <xsl:variable name="submenuID">
                                <xsl:variable name="submenu">
                                <xsl:choose>
                                    <xsl:when test="child::*[@level = 'subfonds'] | child::*[@level = 'subgrp']  | child::*[@level = 'subseries'] | child::*[@level = 'collection'] | child::*[@level = 'recordgrp']  | child::*[@level = 'series'] | child::*[@level = 'fonds']">
                                        <xsl:value-of select="child::*[@level = 'subfonds'][1]/@id | child::*[@level = 'subgrp'][1]/@id 
                                            | child::*[@level = 'subseries'][1]/@id | child::*[@level = 'collection'][1]/@id
                                            | child::*[@level = 'recordgrp'][1]/@id  | child::*[@level = 'series'][1]/@id
                                            | child::*[@level = 'fonds'][1]/@id"/>                    
                                    </xsl:when>
                                    <xsl:otherwise/>
                                </xsl:choose>  
                                </xsl:variable>
								<xsl:if test="string-length($submenu)">
                           			<xsl:value-of select="concat('dsc',$submenu)"/>
								</xsl:if>
                            </xsl:variable>
                            <!-- For expanding the top level series to show subseries in table of contents -->
                            <p class="dscToc">
                                <xsl:if test="$submenuID != ''">
                                    <span id="{concat($submenuID,'more')}" class="arrow" style="display:none;"><a href="#" onclick="showLayer('{$submenuID}');"><img src="../../../css/images/more.gif" style="border:none; margin-right:4px;" alt="Expand menu"/></a> </span> 
                                    <span id="{concat($submenuID,'less')}" class="arrow" style="display:inline;"><a  href="#" onclick="hideLayer('{$submenuID}');"><img src="../../../css/images/less.gif" style="border:none; margin-right:4px;" alt="Minimize menu"/></a> </span>                                                            
                                </xsl:if>
                                <a class="ajaxanchor" href="{concat('dsc',@id,'.html')}">
                                    <xsl:choose>
                                        <xsl:when test="head">
                                            <xsl:apply-templates select="child::*/head"/>        
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:apply-templates select="child::*/unittitle"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </a>
                            </p>
                            <xsl:if test="$submenuID != ''">
                                <div class="level2" id="{$submenuID}">
                                    <xsl:for-each select="child::*[@level = 'subfonds'] | child::*[@level = 'subgrp']  | child::*[@level = 'subseries'] | child::*[@level = 'collection'] | child::*[@level = 'recordgrp']  | child::*[@level = 'series'] | child::*[@level = 'fonds']">
                                        <xsl:variable name="parentID" select="../@id"/>
                                        <p class="dscToc"><a class="ajaxanchor" href="{concat('dsc',$parentID,'.html','#',@id)}">
                                            <xsl:choose>
                                                <xsl:when test="head">
                                                    <xsl:apply-templates select="child::*/head"/>        
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:apply-templates select="child::*/unittitle"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </a>
                                        </p>
                                    </xsl:for-each>
                                </div>  
                            </xsl:if>
                        </div>
                    </xsl:for-each> 
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>
    
    <!-- Title statement -->
    <xsl:template match="filedesc/titlestmt">
        <xsl:choose>
            <xsl:when test="titleproper[@type = 'filing']">
                <xsl:apply-templates select="titleproper[@type = 'filing']"/>
            </xsl:when>
            <xsl:otherwise><xsl:apply-templates select="titleproper"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Table layout for the summary description, due to IE bugs this is not implemented in CSS -->
    <xsl:template match="archdesc/did">
        <div id="summary" class="archdesc">
            <h3>
                    <xsl:choose>
                        <xsl:when test="head">
                            <xsl:value-of select="head"/>
                        </xsl:when>
                        <xsl:otherwise>
                            Descriptive Summary
                        </xsl:otherwise>
                    </xsl:choose>
            </h3>
            <!-- Determines the order in wich elements from the archdesc did appear, 
                to change the order of appearance for the children of did
                by changing the order of the following statements.-->
            <table>
               <!-- NOTE: repository is not include in descriptive summary for current NYU stylesheet --> 
                <!--<xsl:apply-templates select="repository"/>-->
                <xsl:apply-templates select="origination"/>
                <xsl:apply-templates select="unittitle"/>    
                <xsl:apply-templates select="unitdate"/>
                <xsl:apply-templates select="abstract"/>
                <xsl:apply-templates select="physdesc"/> 
                <!-- NOTE: the follwoing 4 elements are not in the NYU stylesheet either, leaving them in anyway -->                
                <xsl:apply-templates select="physloc"/>        
                <!--<xsl:apply-templates select="langmaterial"/>-->
                <xsl:apply-templates select="materialspec"/>
                <xsl:apply-templates select="container"/>
                <!-- NOTE: Last two items in NYU xsl -->
                <xsl:apply-templates select="unitid"/>
                <xsl:apply-templates select="note"/>
            </table>
        </div>
    </xsl:template>
    <!-- Template calls and formats the children of archdesc/did -->
    <xsl:template match="archdesc/did/repository | archdesc/did/unitid | archdesc/did/origination 
        | archdesc/did/unitdate | archdesc/did/physdesc | archdesc/did/physloc 
        | archdesc/did/abstract | archdesc/did/langmaterial | archdesc/did/materialspec | archdesc/did/container">
       <tr>
        <th>
            <xsl:choose>
                <xsl:when test="@label">
                    <xsl:value-of select="concat(translate( substring(@label, 1, 1 ),
                        'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ), 
                        substring(@label, 2, string-length(@label )))" />
                    <xsl:if test="@type"> [<xsl:value-of select="@type"/>]</xsl:if>
                    <xsl:if test="self::origination">
                        <xsl:choose>
                            <xsl:when test="persname[@role != ''] and contains(persname/@role,' (')">
                                - <xsl:value-of select="substring-before(persname/@role,' (')"/>
                            </xsl:when>
                            <xsl:when test="persname[@role != '']">
                                - <xsl:value-of select="persname/@role"/>  
                            </xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                    </xsl:if>:
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="self::repository">Repository:</xsl:when>
                        <xsl:when test="self::unitid">Call Phrase:</xsl:when>
                        <xsl:when test="self::unitdate">Dates<xsl:if test="@type"> [<xsl:value-of select="@type"/>]</xsl:if>:</xsl:when>
                        <xsl:when test="self::origination">
                            <xsl:choose>
                                <xsl:when test="persname[@role != ''] and contains(persname/@role,' (')">
                                    Creator - <xsl:value-of select="substring-before(persname/@role,' (')"/>
                                </xsl:when>
                                <xsl:when test="persname[@role != '']">
                                    Creator - <xsl:value-of select="persname/@role"/>  
                                </xsl:when>
                                <xsl:otherwise>
                                    Creator        
                                </xsl:otherwise>
                            </xsl:choose>:
                        </xsl:when>
                        <xsl:when test="self::physdesc">Quantity:</xsl:when>
                        <xsl:when test="self::abstract">Abstract:</xsl:when>
                        <xsl:when test="self::physloc">Location:</xsl:when>
                        <xsl:when test="self::langmaterial">Language:</xsl:when>
                        <xsl:when test="self::materialspec">Technical:</xsl:when>
                        <xsl:when test="self::container">Container:</xsl:when>
                        <xsl:when test="self::note">Note:</xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </th>
        <td>
            <xsl:apply-templates/>
        </td>
       </tr>
    </xsl:template>
    <xsl:template match="archdesc/did/unittitle">
        <xsl:choose>
            <xsl:when test="@label">
                <tr>
                    <th><xsl:value-of select="concat(translate( substring(@label, 1, 1 ),
                        'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ), 
                        substring(@label, 2, string-length(@label )),':')" />: 
                    </th>
                    <td>
                        <xsl:apply-templates select="text() |* [not(self::unitdate)]"/>
                    </td>
                </tr>
            </xsl:when>
            <xsl:otherwise>
                <tr>
                    <th>
                        <xsl:text>Title: </xsl:text>
                    </th>
                    <td>
                        <xsl:apply-templates select="text() |* [not(self::unitdate)]"/>
                    </td>
                </tr>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="unitdate">
            <xsl:choose>
                <xsl:when test="./unitdate/@label">
                    <tr>
                        <th>
                            <xsl:value-of select="concat(translate( substring(./unitdate/@label, 1, 1 ),
                                'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ), 
                                substring(./unitdate/@label, 2, string-length(./unitdate/@label )),':')" />
                        </th>
                        <td>
                            <xsl:apply-templates select="./unitdate"/>
                        </td>
                    </tr>
                </xsl:when>
                <xsl:otherwise>
                    <tr>
                        <th>
                            <xsl:text>Dates: </xsl:text>
                        </th>
                        <td>
                            <xsl:apply-templates select="./unitdate"/>
                        </td>
                    </tr>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>  
    <!-- Template calls and formats all other children of archdesc many of 
        these elements are repeatable within the dsc section as well.-->
    <xsl:template match="bibliography | odd[odd[not(@audience = 'internal')]] | accruals | arrangement  | bioghist 
        | accessrestrict | userestrict  | custodhist | altformavail | originalsloc 
        | fileplan | acqinfo | otherfindaid | phystech | processinfo | relatedmaterial
        | scopecontent  | separatedmaterial | appraisal">     
        <div class="{name()}">        
        <xsl:choose>
            <xsl:when test="head"><xsl:apply-templates/></xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="parent::archdesc">
                            <xsl:choose>
                                <xsl:when test="self::bibliography"><h3><xsl:call-template name="anchor"/>Bibliography</h3></xsl:when>
                                <xsl:when test="self::odd"><h3><xsl:call-template name="anchor"/>Other Descriptive Data</h3></xsl:when>
                                <xsl:when test="self::accruals"><h4><xsl:call-template name="anchor"/>Accruals</h4></xsl:when>
                                <xsl:when test="self::arrangement"><h3><xsl:call-template name="anchor"/>Arrangement</h3></xsl:when>
                                <xsl:when test="self::bioghist"><h3><xsl:call-template name="anchor"/>Biography/History</h3></xsl:when>
                                <xsl:when test="self::accessrestrict"><h4><xsl:call-template name="anchor"/>Restrictions on Access</h4></xsl:when>
                                <xsl:when test="self::userestrict"><h4><xsl:call-template name="anchor"/>Restrictions on Use</h4></xsl:when>
                                <xsl:when test="self::custodhist"><h4><xsl:call-template name="anchor"/>Custodial History</h4></xsl:when>
                                <xsl:when test="self::altformavail"><h4><xsl:call-template name="anchor"/>Alternative Form Available</h4></xsl:when>
                                <xsl:when test="self::originalsloc"><h4><xsl:call-template name="anchor"/>Original Location</h4></xsl:when>
                                <xsl:when test="self::fileplan"><h3><xsl:call-template name="anchor"/>File Plan</h3></xsl:when>
                                <xsl:when test="self::acqinfo"><h4><xsl:call-template name="anchor"/>Acquisition Information</h4></xsl:when>
                                <xsl:when test="self::otherfindaid"><h3><xsl:call-template name="anchor"/>Other Finding Aids</h3></xsl:when>
                                <xsl:when test="self::phystech"><h3><xsl:call-template name="anchor"/>Physical Characteristics and Technical Requirements</h3></xsl:when>
                                <xsl:when test="self::processinfo"><h4><xsl:call-template name="anchor"/>Processing Information</h4></xsl:when>
                                <xsl:when test="self::relatedmaterial"><h3><xsl:call-template name="anchor"/>Related Material</h3></xsl:when>
                                <xsl:when test="self::scopecontent"><h3><xsl:call-template name="anchor"/>Scope and Content</h3></xsl:when>
                                <xsl:when test="self::separatedmaterial"><h3><xsl:call-template name="anchor"/>Separated Material</h3></xsl:when>
                                <xsl:when test="self::appraisal"><h4><xsl:call-template name="anchor"/>Appraisal</h4></xsl:when>                        
                            </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <h4><xsl:call-template name="anchor"/>
                            <xsl:choose>
                                <xsl:when test="self::bibliography">Bibliography</xsl:when>
                                <xsl:when test="self::odd">Other Descriptive Data</xsl:when>
                                <xsl:when test="self::accruals">Accruals</xsl:when>
                                <xsl:when test="self::arrangement">Arrangement</xsl:when>
                                <xsl:when test="self::bioghist">Biography/History</xsl:when>
                                <xsl:when test="self::accessrestrict">Restrictions on Access</xsl:when>
                                <xsl:when test="self::userestrict">Restrictions on Use</xsl:when>
                                <xsl:when test="self::custodhist">Custodial History</xsl:when>
                                <xsl:when test="self::altformavail">Alternative Form Available</xsl:when>
                                <xsl:when test="self::originalsloc">Original Location</xsl:when>
                                <xsl:when test="self::fileplan">File Plan</xsl:when>
                                <xsl:when test="self::acqinfo">Acquisition Information</xsl:when>
                                <xsl:when test="self::otherfindaid">Other Finding Aids</xsl:when>
                                <xsl:when test="self::phystech">Physical Characteristics and Technical Requirements</xsl:when>
                                <xsl:when test="self::processinfo">Processing Information</xsl:when>
                                <xsl:when test="self::relatedmaterial">Related Material</xsl:when>
                                <xsl:when test="self::scopecontent">Scope and Content</xsl:when>
                                <xsl:when test="self::separatedmaterial">Separated Material</xsl:when>
                                <xsl:when test="self::appraisal">Appraisal</xsl:when>                       
                            </xsl:choose>
                        </h4>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
        </div>
    </xsl:template>

    <!-- Templates for publication information  -->
    <xsl:template match="/ead/eadheader/filedesc/publicationstmt">
        <h4>Publication Information</h4>
        <p><xsl:apply-templates select="publisher"/>
            <xsl:if test="date">&#160;<xsl:apply-templates select="date"/></xsl:if>
        </p>
        <xsl:if test="address">
            <xsl:apply-templates select="address"/>
        </xsl:if>
    </xsl:template>
   
    <!-- Template for adding link to URLs in address -->
    <xsl:template match="addressline[contains(.,'http://')]">
        <a href="{substring-after(.,'URL: ')}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    <!-- Templates for revision description  -->
    <xsl:template match="/ead/eadheader/profiledesc">
        <p><xsl:apply-templates mode="pretty"/></p>        
    </xsl:template>
    <xsl:template match="/ead/eadheader/revisiondesc">
        <p><xsl:if test="change/item"><xsl:apply-templates select="change/item"/></xsl:if><xsl:if test="change/date">&#160;<xsl:apply-templates select="change/date" mode="pretty"/></xsl:if></p>        
    </xsl:template>
    <xsl:template match="date" mode="pretty">
        <xsl:value-of select="local:stringDate(.)"/> test
    </xsl:template>
    <!-- Formats controlled access terms -->
    <xsl:template match="controlaccess">
        <div class="{name()}">
        <xsl:choose>
            <xsl:when test="head"><xsl:apply-templates select="head"/></xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="parent::archdesc"><h3><xsl:call-template name="anchor"/>Access Points</h3></xsl:when>
                    <xsl:otherwise></xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="p"/>
        <xsl:if test="persname">
            <h4>Subject Names</h4>
            <ul>
                <xsl:for-each select="persname">
                    <li><xsl:apply-templates select="."/></li>
                </xsl:for-each>                        
            </ul>
        </xsl:if>
        <xsl:if test="genreform">
            <h4>Document Type</h4>
            <ul>
                <xsl:for-each select="genreform">
                    <li><xsl:apply-templates select="."/></li>
                </xsl:for-each>
            </ul>     
        </xsl:if>
        <xsl:if test="corpname">
            <h4>Subject Organizations</h4>
            <ul>
                <xsl:for-each select="corpname">
                    <li><xsl:apply-templates select="."/></li>
                </xsl:for-each>
            </ul>            
        </xsl:if>
        <xsl:if test="subject">
            <h4>Subject Topics</h4>
            <ul>
                <xsl:for-each select="subject">
                    <li><xsl:apply-templates select="."/></li>
                </xsl:for-each>                        
            </ul>
        </xsl:if>
        <xsl:if test="geogname">
            <h4>Subject Places</h4>
            <ul>
                <xsl:for-each select="geogname">
                    <li><xsl:apply-templates select="."/></li>
                </xsl:for-each>                        
            </ul>
        </xsl:if>        
        <!-- NOTE: need clarification on order and display -->
        <xsl:if test="famname">
            <h4>Family Name(s)</h4>
            <ul>
                <xsl:for-each select="famname">
                    <li><xsl:apply-templates/> </li>
                </xsl:for-each>                        
            </ul>
        </xsl:if>
        <xsl:if test="function">
            <h4>Function(s)</h4>
            <ul>
                <xsl:for-each select="function">
                    <li><xsl:apply-templates/> </li>
                </xsl:for-each>                        
            </ul>
        </xsl:if>       
        <xsl:if test="occupation">
            <h4>Occupation(s)</h4>
            <ul>
                <xsl:for-each select="occupation">
                    <li><xsl:apply-templates/> </li>
                </xsl:for-each>                        
            </ul>
        </xsl:if>
        </div>
    </xsl:template>
    <!-- Templates for access terms, include search links speicifc to NYU -->
    <xsl:template match="persname">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="genreform">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="corpname">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="subject">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="geogname">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Formats index and child elements, groups indexentry elements by type (i.e. corpname, subject...)-->
    <xsl:template match="index">
       <xsl:choose>
           <xsl:when test="head"/>
           <xsl:otherwise>
               <xsl:choose>
                   <xsl:when test="parent::archdesc">
                       <h3><xsl:call-template name="anchor"/>Index</h3>
                   </xsl:when>
                   <xsl:otherwise>
                       <h4><xsl:call-template name="anchor"/>Index</h4>
                   </xsl:otherwise>
               </xsl:choose>    
           </xsl:otherwise>
       </xsl:choose>
       <xsl:apply-templates select="child::*[not(self::indexentry)]"/>
                <xsl:if test="indexentry/corpname">
                    <h4>Corporate Name(s)</h4>
                    <ul>
                        <xsl:for-each select="indexentry/corpname">
                            <xsl:sort/>
                            <li><xsl:apply-templates select="."/>: &#160;<xsl:apply-templates select="following-sibling::*"/></li>
                        </xsl:for-each>
                     </ul>   
                </xsl:if>
                <xsl:if test="indexentry/famname">
                    <h4>Family Name(s)</h4>
                    <ul>
                        <xsl:for-each select="indexentry/famname">
                            <xsl:sort/>
                            <li><xsl:apply-templates select="."/>: &#160;<xsl:apply-templates select="following-sibling::*"/></li>
                        </xsl:for-each>
                    </ul>    
                </xsl:if>      
                <xsl:if test="indexentry/function">
                    <h4>Function(s)</h4>
                    <ul>
                        <xsl:for-each select="indexentry/function">
                            <xsl:sort/>
                            <li><xsl:apply-templates select="."/>: &#160;<xsl:apply-templates select="following-sibling::*"/></li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                <xsl:if test="indexentry/genreform">
                    <h4>Genre(s)</h4> 
                    <ul>
                        <xsl:for-each select="indexentry/genreform">
                            <xsl:sort/>
                            <li><xsl:apply-templates select="."/>: &#160;<xsl:apply-templates select="following-sibling::*"/></li>
                        </xsl:for-each>           
                    </ul>
                </xsl:if>
                <xsl:if test="indexentry/geogname">
                    <h4>Geographic Name(s)</h4>
                    <ul>
                        <xsl:for-each select="indexentry/geogname">
                            <xsl:sort/>
                            <li><xsl:apply-templates select="."/>: &#160;<xsl:apply-templates select="following-sibling::*"/></li>
                        </xsl:for-each>
                    </ul>                    
                </xsl:if>
                <xsl:if test="indexentry/name">
                    <h4>Name(s)</h4>
                    <ul>
                        <xsl:for-each select="indexentry/name">
                            <xsl:sort/>
                            <li><xsl:apply-templates select="."/>: &#160;<xsl:apply-templates select="following-sibling::*"/></li>
                        </xsl:for-each>
                    </ul>    
                </xsl:if>
                <xsl:if test="indexentry/occupation">
                    <h4>Occupation(s)</h4> 
                    <ul>
                        <xsl:for-each select="indexentry/occupation">
                            <xsl:sort/>
                            <li><xsl:apply-templates select="."/>: &#160;<xsl:apply-templates select="following-sibling::*"/></li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                <xsl:if test="indexentry/persname">
                    <h4>Personal Name(s)</h4>
                    <ul>
                        <xsl:for-each select="indexentry/persname">
                            <xsl:sort/>
                            <li><xsl:apply-templates select="."/>: &#160;<xsl:apply-templates select="following-sibling::*"/></li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                <xsl:if test="indexentry/subject">
                    <h4>Subject(s)</h4> 
                    <ul>
                        <xsl:for-each select="indexentry/subject">
                            <xsl:sort/>
                            <li><xsl:apply-templates select="."/>: &#160;<xsl:apply-templates select="following-sibling::*"/></li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                <xsl:if test="indexentry/title">
                    <h4>Title(s)</h4>
                    <ul>
                        <xsl:for-each select="indexentry/title">
                            <xsl:sort/>
                            <li><xsl:apply-templates select="."/>: &#160;<xsl:apply-templates select="following-sibling::*"/></li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>         
   </xsl:template>
    <xsl:template match="indexentry">
        <dl class="indexEntry">
            <dt><xsl:apply-templates select="child::*[1]"/></dt>
            <dd><xsl:apply-templates select="child::*[2]"/></dd>    
        </dl>
    </xsl:template>
    <xsl:template match="ptrgrp">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- Linking elements. -->
    <xsl:template match="ptr">
        <xsl:choose>
            <xsl:when test="@target">
                <a href="#{@target}"><xsl:value-of select="@target"/></a>
                <xsl:if test="following-sibling::ptr">, </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="ref">
        <xsl:choose>
            <xsl:when test="@target">
                <a href="#{@target}">
                    <xsl:apply-templates/>
                </a>
                <xsl:if test="following-sibling::ref">, </xsl:if>
            </xsl:when>
            <xsl:when test="@ns2:href">
                <a href="#{@ns2:href}">
                    <xsl:apply-templates/>
                </a>
                <xsl:if test="following-sibling::ref">, </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>    
    <xsl:template match="extptr">
        <xsl:choose>
            <xsl:when test="@href">
                <a href="{@href}"><xsl:value-of select="@title"/></a>
            </xsl:when>
            <xsl:when test="@ns2:href"><a href="{@ns2:href}"><xsl:value-of select="@title"/></a></xsl:when>
            <xsl:otherwise><xsl:value-of select="@title"/></xsl:otherwise>
        </xsl:choose> 
    </xsl:template>
    <xsl:template match="extref">
        <xsl:choose>
            <xsl:when test="@href">
                <a href="{@href}"><xsl:value-of select="."/></a>
            </xsl:when>
            <xsl:when test="@ns2:href"><a href="{@ns2:href}"><xsl:value-of select="."/></a></xsl:when>
            <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
        </xsl:choose> 
    </xsl:template>
    
    <!-- NOTE: Does not work with multi-page format
        Creates a hidden anchor tag that allows navigation within the finding aid. 
        In this stylesheet only children of the archdesc and clevel itmes call this template. 
        It can be applied anywhere in the stylesheet as the id attribute is universal. 
    -->
    <xsl:template match="@id">
        <xsl:attribute name="id"><xsl:value-of select="."/></xsl:attribute>
    </xsl:template>
    <xsl:template name="anchor">
        <xsl:choose>
            <xsl:when test="@id">
                <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
            </xsl:otherwise>
            </xsl:choose>
    </xsl:template>
    <xsl:template name="tocLinks">
        <xsl:choose>
            <xsl:when test="self::*/@id">
                <xsl:attribute name="href">#<xsl:value-of select="@id"/></xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="href">#<xsl:value-of select="generate-id(.)"/></xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
 
    <!--Bibref, choose statement decides if the citation is inline, if there is a parent element
    or if it is its own line, typically when it is a child of the bibliography element.-->
    <xsl:template match="bibref">
        <xsl:choose>
            <xsl:when test="parent::p">
                <xsl:choose>
                    <xsl:when test="@ns2:href">
                        <a href="{@ns2:href}"><xsl:apply-templates/></a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <p>
                    <xsl:choose>
                        <xsl:when test="@ns2:href">
                            <a href="{@ns2:href}"><xsl:apply-templates/></a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates/>
                        </xsl:otherwise>
                    </xsl:choose>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
   
    <!-- Formats prefered citiation -->
    <xsl:template match="prefercite">
        <div class="citation">
            <xsl:choose>
                <xsl:when test="head"><xsl:apply-templates/></xsl:when>
                <xsl:otherwise><h4>Preferred Citation</h4><xsl:apply-templates/></xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <!-- Applies a span style to address elements, currently addresses are displayed 
        as a block item, display can be changed to inline, by changing the CSS -->
    <xsl:template match="address">
        <span class="address">
            <xsl:for-each select="child::*">
                <xsl:apply-templates/>
                <xsl:choose>
                    <xsl:when test="lb"/>
                    <xsl:otherwise><br/></xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>            
        </span>    
    </xsl:template>
    
    <!-- Formats headings throughout the finding aid -->
    <xsl:template match="head[parent::*/parent::archdesc]">
        <xsl:choose>
            <xsl:when test="parent::accessrestrict or parent::userestrict or
                parent::custodhist or parent::accruals or
                parent::altformavail or parent::acqinfo or
                parent::processinfo or parent::appraisal or
                parent::originalsloc or parent::prefercite">
                <h4>
                    <xsl:choose>
                        <xsl:when test="parent::*/@id">
                            <xsl:attribute name="id"><xsl:value-of select="parent::*/@id"/></xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="id"><xsl:value-of select="generate-id(parent::*)"/></xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates/>
                </h4>
            </xsl:when>
            <xsl:otherwise>
                <h3>
                    <xsl:choose>
                        <xsl:when test="parent::*/@id">
                            <xsl:attribute name="id"><xsl:value-of select="parent::*/@id"/></xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="id"><xsl:value-of select="generate-id(parent::*)"/></xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates/>
                </h3>                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="head">
        <h4><xsl:apply-templates/></h4>
    </xsl:template>
    
    <!--NOTE: Check Digital Archival Object -->
    <xsl:template match="daogrp">
        <xsl:choose>
            <xsl:when test="parent::archdesc">
                <h3><xsl:call-template name="anchor"/>
                    <xsl:choose>
                    <xsl:when test="@ns2:title">
                       <xsl:value-of select="@ns2:title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        Digital Archival Object
                    </xsl:otherwise>
                    </xsl:choose>
                </h3>
            </xsl:when>
            <xsl:otherwise>
                <h4><xsl:call-template name="anchor"/>
                    <xsl:choose>
                    <xsl:when test="@ns2:title">
                       <xsl:value-of select="@ns2:title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        Digital Archival Object
                    </xsl:otherwise>
                </xsl:choose>
                </h4>
            </xsl:otherwise>
        </xsl:choose>   
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="dao">
        <xsl:choose>
            <xsl:when test="child::*">
                <xsl:apply-templates/> <a href="{@ns2:href}">[<xsl:value-of select="@ns2:href"/>]</a>
            </xsl:when>
            <xsl:otherwise>
                <a href="{@ns2:href}">
                    <xsl:value-of select="@ns2:href"/>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="daoloc">
        <a href="{@ns2:href}">
            <xsl:value-of select="@ns2:title"/>
        </a>
    </xsl:template>
    
    <!--Formats a simple table. The width of each column is defined by the colwidth attribute in a colspec element.-->
    <xsl:template match="table">
        <xsl:for-each select="tgroup">
            <table>
                <tr>
                    <xsl:for-each select="colspec">
                        <td width="{@colwidth}"/>
                    </xsl:for-each>
                </tr>
                <xsl:for-each select="thead">
                    <xsl:for-each select="row">
                        <tr>
                            <xsl:for-each select="entry">
                                <td valign="top">
                                    <strong>
                                        <xsl:value-of select="."/>
                                    </strong>
                                </td>
                            </xsl:for-each>
                        </tr>
                    </xsl:for-each>
                </xsl:for-each>
                <xsl:for-each select="tbody">
                    <xsl:for-each select="row">
                        <tr>
                            <xsl:for-each select="entry">
                                <td valign="top">
                                    <xsl:value-of select="."/>
                                </td>
                            </xsl:for-each>
                        </tr>
                    </xsl:for-each>
                </xsl:for-each>
            </table>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="unitdate">
        <xsl:if test="preceding-sibling::*">&#160;</xsl:if>
        <xsl:choose>
            <xsl:when test="@type = 'bulk'">
                (<xsl:apply-templates/>)                            
            </xsl:when>
            <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="date">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="unittitle">
        <xsl:choose>
            <xsl:when test="child::unitdate[@type='bulk']">
                <xsl:apply-templates select="node()[not(self::unitdate[@type='bulk'])]"/>
                <xsl:apply-templates select="date[@type='bulk']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Following five templates output chronlist and children in a table -->
    <xsl:template match="chronlist">
        <table class="chronlist">
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    <xsl:template match="chronlist/listhead">
        <tr>
            <th>
                <xsl:apply-templates select="head01"/>
            </th>
            <th>
                <xsl:apply-templates select="head02"/>
            </th>
        </tr>
    </xsl:template>
    <xsl:template match="chronlist/head">
        <tr>
            <th colspan="2">
                <xsl:apply-templates/>
            </th>
        </tr>
    </xsl:template>
    <xsl:template match="chronitem">
        <tr>
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="(position() mod 2 = 0)">odd</xsl:when>
                    <xsl:otherwise>even</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <td><xsl:apply-templates select="date"/></td>
            <td><xsl:apply-templates select="descendant::event"/></td>
        </tr>
    </xsl:template>
    <xsl:template match="event">
        <xsl:choose>
            <xsl:when test="following-sibling::*">
                <xsl:apply-templates/><br/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>

    <!-- Output for a variety of list types -->
    <xsl:template match="list">
        <xsl:if test="head"><h4><xsl:value-of select="head"/></h4></xsl:if>
        <xsl:choose>
            <xsl:when test="descendant::defitem">
                <dl>
                    <xsl:apply-templates select="defitem"/>
                </dl>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="@type = 'ordered'">
                        <ol>
                            <xsl:attribute name="class">
                                <xsl:value-of select="@numeration"/>
                            </xsl:attribute>
                            <xsl:apply-templates/>
                        </ol>
                    </xsl:when>
                    <xsl:when test="@numeration">
                        <ol>
                            <xsl:attribute name="class">
                                <xsl:value-of select="@numeration"/>
                            </xsl:attribute>
                            <xsl:apply-templates/>
                        </ol>
                    </xsl:when>
                    <xsl:when test="@type='simple'">
                        <ul>
                            <xsl:attribute name="class">simple</xsl:attribute>
                            <xsl:apply-templates select="child::*[not(head)]"/>
                        </ul>
                    </xsl:when>
                    <xsl:otherwise>
                        <ul>
                            <xsl:apply-templates/>
                        </ul>        
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="list/head"/>
    <xsl:template match="list/item">
        <li><xsl:apply-templates/></li>
    </xsl:template>
    <xsl:template match="defitem">
        <dt><xsl:apply-templates select="label"/></dt>
        <dd><xsl:apply-templates select="item"/></dd>
    </xsl:template>
 
    <!-- Formats list as tabel if list has listhead element  -->         
    <xsl:template match="list[child::listhead]">
        <table>
            <tr>
                <th><xsl:value-of select="listhead/head01"/></th>
                <th><xsl:value-of select="listhead/head02"/></th>
            </tr>
            <xsl:for-each select="defitem">
                <tr>
                    <td><xsl:apply-templates select="label"/></td>
                    <td><xsl:apply-templates select="item"/></td>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:template>

    <!-- Formats notestmt and notes -->
    <xsl:template match="notestmt">
        <h4>Note</h4>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="note">
         <xsl:choose>
             <xsl:when test="parent::notestmt">
                 <xsl:apply-templates/>
             </xsl:when>
             <xsl:otherwise>
                 <xsl:choose>
                     <xsl:when test="@label"><h4><xsl:value-of select="@label"/></h4><xsl:apply-templates/></xsl:when>
                     <xsl:otherwise><h4>Note</h4><xsl:apply-templates/></xsl:otherwise>
                 </xsl:choose>
             </xsl:otherwise>
         </xsl:choose>
     </xsl:template>
    
    <!-- Child elements that should display as paragraphs-->
    <xsl:template match="legalstatus">
        <p><xsl:apply-templates/></p>
    </xsl:template>
    <!-- Puts a space between sibling elements -->
    <xsl:template match="child::*">
        <xsl:if test="preceding-sibling::*">&#160;</xsl:if>
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Generic text display elements -->
    <xsl:template match="p">
        <p><xsl:apply-templates/></p>
    </xsl:template>
    <xsl:template match="lb"><br/></xsl:template>
    <xsl:template match="blockquote">
        <blockquote><xsl:apply-templates/></blockquote>
    </xsl:template>
    <xsl:template match="emph"><em><xsl:apply-templates/></em></xsl:template>
    
    <!--Render elements -->
    <xsl:template match="*[@render = 'bold'] | *[@altrender = 'bold'] ">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><strong><xsl:apply-templates/></strong>
    </xsl:template>
    <xsl:template match="*[@render = 'bolddoublequote'] | *[@altrender = 'bolddoublequote']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><strong>"<xsl:apply-templates/>"</strong>
    </xsl:template>
    <xsl:template match="*[@render = 'boldsinglequote'] | *[@altrender = 'boldsinglequote']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><strong>'<xsl:apply-templates/>'</strong>
    </xsl:template>
    <xsl:template match="*[@render = 'bolditalic'] | *[@altrender = 'bolditalic']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><strong><em><xsl:apply-templates/></em></strong>
    </xsl:template>
    <xsl:template match="*[@render = 'boldsmcaps'] | *[@altrender = 'boldsmcaps']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><strong><span class="smcaps"><xsl:apply-templates/></span></strong>
    </xsl:template>
    <xsl:template match="*[@render = 'boldunderline'] | *[@altrender = 'boldunderline']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><strong><span class="underline"><xsl:apply-templates/></span></strong>
    </xsl:template>
    <xsl:template match="*[@render = 'doublequote'] | *[@altrender = 'doublequote']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if>"<xsl:apply-templates/>"
    </xsl:template>
    <xsl:template match="*[@render = 'italic'] | *[@altrender = 'italic']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><em><xsl:apply-templates/></em>
    </xsl:template>
    <xsl:template match="*[@render = 'singlequote'] | *[@altrender = 'singlequote']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if>'<xsl:apply-templates/>'
    </xsl:template>
    <xsl:template match="*[@render = 'smcaps'] | *[@altrender = 'smcaps']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><span class="smcaps"><xsl:apply-templates/></span>
    </xsl:template>
    <xsl:template match="*[@render = 'sub'] | *[@altrender = 'sub']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><sub><xsl:apply-templates/></sub>
    </xsl:template>
    <xsl:template match="*[@render = 'super'] | *[@altrender = 'super']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><sup><xsl:apply-templates/></sup>
    </xsl:template>
    <xsl:template match="*[@render = 'underline'] | *[@altrender = 'underline']">
        <xsl:if test="preceding-sibling::*"> &#160;</xsl:if><span class="underline"><xsl:apply-templates/></span>
    </xsl:template>

    
    <!-- NYU HELPER TEMPLATES-->
    <xsl:template name="capitalize_first_letter">
        <xsl:param name="string"/>
        <xsl:value-of select="concat( translate( substring( $string, 1, 1 ),'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ), substring( $string, 2, string-length( $string )))"/>
    </xsl:template>
    <xsl:template name="genIDArr">
        <xsl:param name="node"/>
        <xsl:for-each select="$node">
            <xsl:element name="element-{position()}">
                <xsl:value-of select="generate-id()"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <!-- *** Begin templates for Container List *** -->
    <xsl:template match="archdesc/dsc">
        <div class="{name()}">  
        <xsl:choose>
            <xsl:when test="head">
                <h3><xsl:value-of select="head"/></h3>
            </xsl:when>
            <xsl:otherwise>
                <h3>Container List</h3>
            </xsl:otherwise>
        </xsl:choose>
        <!-- Creates a table for container lists, defaults to 6 cells, for up to 4 container lists, one title and a date.  -->
        <table class="containerList">
            <xsl:apply-templates select="*[not(self::head)]"/>
            <tr>
                <td style="width: 10%;"/>
                <td style="width: 10%;"/>
                <td style="width: 10%;"/>
                <td/>
                <td style="width: 15%;"/>
            </tr>
            
        </table>
        </div>
    </xsl:template>
    
    <!--This section of the stylesheet creates a div for each c01 or c 
        It then recursively processes each child component of the c01 by 
        calling the clevel template. -->
    <xsl:template match="c">
        <xsl:call-template name="clevel"/>
        <xsl:for-each select="c">
            <xsl:call-template name="clevel"/> 
            <xsl:for-each select="c">
                <xsl:call-template name="clevel"/>    
                <xsl:for-each select="c">
                    <xsl:call-template name="clevel"/>
                    <xsl:for-each select="c">
                        <xsl:call-template name="clevel"/>
                        <xsl:for-each select="c">
                            <xsl:call-template name="clevel"/> 
                            <xsl:for-each select="c">
                                <xsl:call-template name="clevel"/>
                                <xsl:for-each select="c">
                                    <xsl:call-template name="clevel"/>
                                    <xsl:for-each select="c">
                                        <xsl:call-template name="clevel"/>    
                                    </xsl:for-each>
                                </xsl:for-each>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="c01">
        <xsl:call-template name="clevel"/>
        <xsl:for-each select="c02">
            <xsl:call-template name="clevel"/>
            <xsl:for-each select="c03">
                <xsl:call-template name="clevel"/>
                <xsl:for-each select="c04">
                    <xsl:call-template name="clevel"/>
                    <xsl:for-each select="c05">
                        <xsl:call-template name="clevel"/>
                        <xsl:for-each select="c06">
                            <xsl:call-template name="clevel"/>
                            <xsl:for-each select="c07">
                                <xsl:call-template name="clevel"/>
                                <xsl:for-each select="c08">
                                    <xsl:call-template name="clevel"/>
                                    <xsl:for-each select="c09">
                                        <xsl:call-template name="clevel"/>
                                        <xsl:for-each select="c10">
                                            <xsl:call-template name="clevel"/>
                                            <xsl:for-each select="c11">
                                                <xsl:call-template name="clevel"/>
                                                <xsl:for-each select="c12">
                                                    <xsl:call-template name="clevel"/>
                                                </xsl:for-each>
                                            </xsl:for-each>
                                        </xsl:for-each>
                                    </xsl:for-each>
                                </xsl:for-each>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:for-each>
        <tr>
            <td colspan="5">
                <xsl:call-template name="returnTop"/>
            </td>
        </tr>
    </xsl:template>
    <!--This is a named template that processes all c0* elements  -->
    <xsl:template name="clevel">
    <!--NOTE: clevelMargin is not used by NYU
        Establishes which level is being processed in order to provided indented displays. 
        Indents handled by CSS margins
    -->
        <xsl:variable name="clevelMargin">
            <xsl:choose>
                <xsl:when test="../c">c</xsl:when>
                <xsl:when test="../c01">c01</xsl:when>
                <xsl:when test="../c02">c02</xsl:when>
                <xsl:when test="../c03">c03</xsl:when>
                <xsl:when test="../c04">c04</xsl:when>
                <xsl:when test="../c05">c05</xsl:when>
                <xsl:when test="../c06">c06</xsl:when>
                <xsl:when test="../c07">c07</xsl:when>
                <xsl:when test="../c08">c08</xsl:when>
                <xsl:when test="../c08">c09</xsl:when>
                <xsl:when test="../c08">c10</xsl:when>
                <xsl:when test="../c08">c11</xsl:when>
                <xsl:when test="../c08">c12</xsl:when>
            </xsl:choose>
        </xsl:variable>
    <!-- Establishes a class for even and odd rows in the table for color coding. 
        Colors are Declared in the CSS. -->
        <xsl:variable name="colorClass">
            <xsl:choose>
                <xsl:when test="ancestor-or-self::*[@level='file' or @level='item' or @level='otherlevel']">
                    <xsl:choose>
                        <xsl:when test="(position() mod 2 = 0)">odd_row</xsl:when>
                        <xsl:otherwise>even_row</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- Processes the all child elements of the c or c0* level -->
        <xsl:for-each select=".">
            <xsl:choose>
                <!--Formats Series and Groups  -->
                <xsl:when test="@level='subcollection' or @level='subgrp' or @level='series' 
                    or @level='subseries' or @level='collection'or @level='fonds' or 
                    @level='recordgrp' or @level='subfonds' or @level='class' or (@level='otherlevel' and not(child::did/container))">
                    <tr> 
                        <xsl:attribute name="class">
                            <xsl:choose>
                                <xsl:when test="@level='subcollection' or @level='subgrp' or @level='subseries' or @level='subfonds'">subseries</xsl:when>
                                <xsl:otherwise>series</xsl:otherwise>
                            </xsl:choose>    
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="did/container">
                            <xsl:for-each select="descendant::did[container][1]/container">   
                            <!-- Container Headers -->                                
                                <td>    
                                    <xsl:value-of select="@type"/><br/><xsl:value-of select="."/>       
                                </td>    
                            </xsl:for-each>   
                                <!-- Extra column for date -->
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="count(did/container) &lt; 1">
                                            <xsl:attribute name="colspan">
                                                <xsl:text>3</xsl:text>
                                            </xsl:attribute>
                                        </xsl:when>
                                        <xsl:when test="count(did/container) = 1">
                                            <xsl:attribute name="colspan">
                                                <xsl:text>2</xsl:text>
                                            </xsl:attribute>
                                        </xsl:when>
                                        <xsl:otherwise/>
                                    </xsl:choose>
                                    <xsl:text>&#160;</xsl:text>
                                </td>
                                <td>
                                    <xsl:call-template name="anchor"/>
                                    <xsl:apply-templates select="did" mode="dsc"/>
                                    <xsl:apply-templates select="child::*[not(did) and not(self::did)]" mode="dsc"/>
                                </td>
                            </xsl:when>
                            <xsl:otherwise>
                                <td colspan="5">
                                    <xsl:call-template name="anchor"/>
                                    <xsl:apply-templates select="did" mode="dsc"/>
                                    <xsl:apply-templates select="child::*[not(did) and not(self::did)]"/>
                                </td>
                            </xsl:otherwise>
                        </xsl:choose>
                    </tr>
                </xsl:when>
             
                <!-- Items/Files--> 
                <xsl:when test="@level='file' or @level='item' or (@level='otherlevel'and child::did/container)">
                  <!-- Variables to  for Conainer headings, used only if headings are different from preceding heading -->
                    <xsl:variable name="container" select="string(did/container[1]/@type)"/>
                    <xsl:variable name="container2" select="string(did/container[2]/@type)"/>
                    <xsl:variable name="container3" select="string(did/container[3]/@type)"/>
                    <xsl:variable name="container4" select="string(did/container[4]/@type)"/>
                    <!-- Counts contianers for current and preceding instances and if different inserts a heading -->
                    <xsl:variable name="containerCount" select="count(did/container)"/>
                    <xsl:variable name="sibContainerCount" select="count(preceding-sibling::*[1]/did/container)"/>
                    <!-- Variable estabilishes previouse container types for comparisson to current container. -->
                    <xsl:variable name="sibContainer" select="string(preceding-sibling::*[1]/did/container[1]/@type)"/>
                    <xsl:variable name="sibContainer2" select="string(preceding-sibling::*[1]/did/container[2]/@type)"/>
                    <xsl:variable name="sibContainer3" select="string(preceding-sibling::*[1]/did/container[3]/@type)"/>
                    <xsl:variable name="sibContainer4" select="string(preceding-sibling::*[1]/did/container[4]/@type)"/>
                    <!-- NOTE: NYU has a not statment to exclude RSIM numbers? 
                        Tests to see if current container type is different from previous container type, if it is a new row with container type headings is outout -->
                    <xsl:if test="$container != $sibContainer or $container2 != $sibContainer2 or $container3 != $sibContainer3 or $container4 != $sibContainer4 or$containerCount != $sibContainerCount">
                        <xsl:if test="did/container">
                            <tr>
                                <xsl:for-each select="did/container">    
                                    <th class="containerHeader">    
                                        <xsl:value-of select="@type"/>
                                    </th>    
                                </xsl:for-each>
                                    <xsl:choose>
                                        <xsl:when test="count(did/container) &lt; 1">
                                            <th  class="containerHeader" colspan="3"><xsl:text>&#160;</xsl:text></th>
                                        </xsl:when>
                                        <xsl:when test="count(did/container) = 1">
                                            <th  class="containerHeader" colspan="2"><xsl:text>&#160;</xsl:text></th>
                                        </xsl:when>
                                        <xsl:when test="count(did/container) &gt; 2"/>
                                        <xsl:otherwise><th class="containerHeader"><xsl:text>&#160;</xsl:text></th></xsl:otherwise>
                                    </xsl:choose>               
                                <th class="containerHeader">
                                    <xsl:text>Title</xsl:text>
                                </th>
                                <th class="containerHeader">
                                    <xsl:text>Date</xsl:text>
                                </th>
                            </tr>
                        </xsl:if> 
                  </xsl:if>
                    <tr class="{$colorClass}"  id="{@id}"> 

                        <!-- Containers -->    
                        <xsl:for-each select="did/container">    
                            <td class="container"><xsl:value-of select="@type" /><xsl:text>:</xsl:text>&#160;<xsl:value-of select="."/></td>    
                        </xsl:for-each>
                        <xsl:choose>
                            <xsl:when test="count(did/container) &lt; 1">
                                <td colspan="3"><xsl:text>&#160;</xsl:text></td>
                            </xsl:when>
                            <xsl:when test="count(did/container) = 1">
                                <td colspan="2"><xsl:text>&#160;</xsl:text></td>
                            </xsl:when>
                            <xsl:when test="count(did/container) &gt; 2"/>
                            <xsl:otherwise><td><xsl:text>&#160;</xsl:text></td></xsl:otherwise>
                        </xsl:choose>                           
                        <td>                            
                            <xsl:apply-templates select="did" mode="dsc"/>   
                                <xsl:apply-templates select="*[not(self::did) and 
                                not(self::c) and not(self::c02) and not(self::c03) and
                                not(self::c04) and not(self::c05) and not(self::c06) and not(self::c07)
                                and not(self::c08) and not(self::c09) and not(self::c10) and not(self::c11) and not(self::c12)]" mode="dsc"/>
                        </td>
                        <!-- Added column for unitdate -->
                        <td>
                            <xsl:if test="did/unitdate">
                                <xsl:for-each select="did/unitdate">
                                    <xsl:apply-templates/>
                                </xsl:for-each>
                            </xsl:if>
                        </td>
                    </tr> 
                </xsl:when>
                <xsl:otherwise>
                    <tr class="{$colorClass}" id="{@id}"> 
                        <td colspan="5">
                            <xsl:apply-templates select="did" mode="dsc"/>
                            <xsl:apply-templates select="*[not(self::did) and 
                                not(self::c) and not(self::c02) and not(self::c03) and
                                not(self::c04) and not(self::c05) and not(self::c06) and not(self::c07)
                                and not(self::c08) and not(self::c09) and not(self::c10) and not(self::c11) and not(self::c12)]" mode="dsc"/>  
                        </td>
                    </tr>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
   
   <!-- Templates for children of the dsc -->
   <xsl:template match="*" mode="dsc">
            <xsl:apply-templates select="child::*[not(head)]"/>
   </xsl:template>

    <!-- Container list child element templates use mode="dsc" -->    
    <xsl:template match="did" mode="dsc">
        <xsl:choose>
            <xsl:when test="../@level='subcollection' or ../@level='subgrp' or ../@level='series' 
                or ../@level='subseries'or ../@level='collection'or ../@level='fonds' or 
                ../@level='recordgrp' or ../@level='subfonds'">    
                <h3>
                    <xsl:call-template name="component-did-core"/>
                </h3>
            </xsl:when>
            <!--Otherwise render the text in its normal font.-->
            <xsl:otherwise>
                <p><xsl:call-template name="component-did-core"/></p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="component-did-core">
        <xsl:apply-templates select="unittitle" mode="dsc"/>
        <xsl:apply-templates select="origination" mode="dsc"/>
        <xsl:apply-templates select="physdesc" mode="dsc"/>
        <br/>
    </xsl:template>
    <xsl:template match="unittitle" mode="dsc">
        <span class="unittitle">
            <xsl:apply-templates/><br/>
        </span>
    </xsl:template>
    <xsl:template mode="dsc" match="origination">
        <xsl:value-of select="."/>
        <xsl:if test="child::*/@role"> (<xsl:value-of select="substring-before(child::*/@role,'(')"/>)</xsl:if>
        <br/>
    </xsl:template>
    <xsl:template match="physdesc" mode="dsc">
        <xsl:apply-templates/><br/>
    </xsl:template>
    <xsl:template match="index" mode="dsc">
        <p>
            <xsl:choose>
                <xsl:when test="head"><xsl:value-of select="concat(head,' ')"/> </xsl:when>
                <xsl:otherwise>See also: </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="indexentry" mode="dsc"/>
        </p>    
    </xsl:template>   
    <xsl:template match="indexentry" mode="dsc">
        <xsl:if test="preceding-sibling::indexentry">, </xsl:if>
        <xsl:choose>
            <xsl:when test="ref">
                <a href="{concat('#',ref/@target)}"><xsl:value-of select="child::*[1]"/></a>
            </xsl:when>
            <xsl:otherwise><xsl:apply-templates mode="dsc"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Series of templates for different DAO display. -->
    <!-- DAO display, thumbnails when only one thumbnail and one service object are present -->
    <xsl:template match="dao[@ns2:role = 'thumb'] | dao[@ns2:role = 'Image-Thumb']  | dao[@ns2:role = 'Image-Thumbnail']" mode="dsc">
        <xsl:choose>
                <xsl:when test="count(../dao) &gt; 2">
                  <p>  <xsl:value-of select="concat(@ns2:role,': ')"/>
                        <a class="daoLink" href="openWindow({@ns2:href})" title="{@ns2:role}"><xsl:value-of select="@ns2:href"/></a>
                   </p>   
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="service-uri" select="../dao[not(@ns2:role = 'thumb') and not(@ns2:role = 'Image-Thumb') and not(@ns2:role = 'Image-Thumbnail')][1]/@ns2:href"/>
                <p><a href="{$service-uri}" class="daoLink" rel="external">
                    <img src="{@ns2:href}" alt="Click to enlarge"/>    
                </a>
                </p>
            </xsl:otherwise>
        </xsl:choose>     
    </xsl:template>
    <!-- DAO for service object -->
    <xsl:template match="dao[@ns2:role = 'service'] | dao[@ns2:role = 'Image-Service']" mode="dsc">
        <xsl:choose>
            <xsl:when test="count(../dao) &gt; 2">
               <p>Service Image:  <a class="daoLink" href="{@ns2:href}" rel="external" title="{@ns2:role}"><xsl:value-of select="@ns2:href"/></a></p>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    <!-- DAO for sub-master -->

    <xsl:template match="dao[@ns2:role = 'sub-master'] | dao[@ns2:role = 'Image-Sub-master'] | dao[@ns2:role = 'Image-Sub-Master']" mode="dsc">
        <xsl:choose>
            <xsl:when test="count(../dao) &gt; 2">
               <p> Image Sub-master:  <a class="daoLink" href="{@ns2:href}" rel="external" title="{@ns2:role}"><xsl:value-of select="@ns2:href"/></a></p>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    <!-- DAO for master -->
    <xsl:template match="dao[@ns2:role = 'master'] | dao[@ns2:role = 'Image-Master']" mode="dsc">
        <xsl:choose>
            <xsl:when test="count(../dao) &gt; 2">
                <p>Image Master: <a class="daoLink" href="{@ns2:href}"  rel="external" title="{@ns2:role}"><xsl:value-of select="@ns2:href"/></a></p>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    <!-- DAO default template -->
    <xsl:template match="dao" mode="dsc">       
      <p>  <xsl:choose>
            <xsl:when test="descendant::daodesc">
                <xsl:value-of select="descendant::daodesc/child::*" />
            </xsl:when>						
            <xsl:when test="@ns2:title">
                <xsl:value-of select="@ns2:title" />
            </xsl:when>
            <xsl:when test="@ns2:label">
                <xsl:value-of select="@ns2:label" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Digital Object :</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        &#160;<a class="daoLink" href="{@ns2:href}" rel="external"><xsl:value-of select="@ns2:href"/></a><br/></p>
    </xsl:template>  
    <xsl:template match="note" mode="dsc">
        <p class="note">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

</xsl:stylesheet>
