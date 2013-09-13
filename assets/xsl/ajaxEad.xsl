<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--param that determines type of archive: fales, archives, rism or tamwag. Determines css style-->
    <xsl:param name="collectionName"/>

     <!--param that grabs solr host name from eadsearch conf file-->
    <xsl:param name="solrHost"/>
    <!--generates html from some display markup in ead-->
    <xsl:include href="generateHTML.xsl"/>
    <!--global variables declared here. Mostly used in the dsc template-->
    <xsl:include href="globalVars.xsl"/>
    <!--contains dsc templates-->
    <xsl:include href="dscTemplate.xsl"/>
    <xsl:output method="html" indent="yes" name="html"/>
    <xsl:template match="/">

        <xsl:apply-templates select="ead"/>
    </xsl:template>

    <xsl:template match="ead">
        <!--determines output file name from incoming parameter and eadid element from ead-->
<!--        <xsl:variable name="outputfile"
            select="concat('data/html/',$collectionName,'/',eadheader/eadid,'.html')"/>
        <xsl:result-document href="{$outputfile}" format="html">-->
            <html>
                <head>
                    <title>
                        <xsl:value-of select="eadheader/filedesc/titlestmt/titleproper"/>
                    </title>
                    <link rel="stylesheet" type="text/css" href="http://dlibdev.nyu.edu/eadpublisher/css/ead.css"/>
                 
                 <script src="http://dlibdev.nyu.edu/eadpublisher/js/ead.js" type="text/javascript" charset="utf-8"/>
                 <script src="http://dlibdev.nyu.edu/eadpublisher/js/ajaxSearch.js" type="text/javascript" charset="utf-8"/>
                   
                </head>
                <!--setHeights sets the height of content div to the window height and prevents scroll bar for the whole page-->
                <body onload="setHeights()" style="overflow:hidden">
                    <xsl:call-template name="generateEad"/>
                </body>
            </html>
 <!--       </xsl:result-document>-->

    </xsl:template>

    <xsl:template name="generateEad">
        <table id="generateEad">
            <tr>
                <a name="#top"/>
                <!--generates table of contents-->
                <xsl:call-template name="navigation"/>
                <!--outputs content-->
                <xsl:call-template name="content"/>
            </tr>
        </table>
    </xsl:template>

    <xsl:template name="navigation">
        <!--Table of contents. The background and font color change according to the parameter value-->
        <td id="{$collectionName}" class="toc">
                <p id="tocHeader">Table of Contents</p>
                <!--link to descriptive summary-->
            <xsl:if test="archdesc/did">
                
                <a href="#{$didLink}" class="display">
                    <xsl:value-of select="archdesc/did/head"/>
                </a>
            </xsl:if>
            <!--link to biographical note-->
            <xsl:if test="archdesc/bioghist">
                <a href="#{$bioghistLink}" class="display">
                    <xsl:value-of select="archdesc/bioghist/head"/>
                </a>
            </xsl:if>
            <!--link to scope and content note-->
            <xsl:if test="archdesc/scopecontent">
                <a href="#{$scopeLink}" class="display">
                    <xsl:value-of select="archdesc/scopecontent/head"/>
                </a>
                </xsl:if>
            <!--link to arrangement note-->
            <xsl:if test="archdesc/arrangement">
                <a href="#{$arrangementLink}" class="display">
                    <xsl:value-of select="archdesc/arrangement/head"/>
                </a>
            </xsl:if>
                <xsl:if test="archdesc/userestrict | ead/archdesc/accessrestrict">
                    <a href="#Restrictions" class="display">Restrictions</a>
                </xsl:if>
            <!--link to access points note-->
            <xsl:if test="archdesc/controlaccess">
                <a href="#{$accessPointLink}" class="display">
                    <xsl:value-of select="archdesc/controlaccess/head"/>
            </a>
            </xsl:if>
            <!--link to related material-->
                <xsl:if test="archdesc/relatedmaterial">
                    <a href="#{$relatedLink}" class="display">Related Material</a>
                </xsl:if>
            <!--link to separated material-->
                <xsl:if test="archdesc/separatedmaterial">
                    <a href="#{$separatedLink}" class="display">Separated Material</a>
                </xsl:if>
            <!--link to administrative information-->
                <xsl:if
                    test="archdesc/acqinfo | archdesc/processinfo | archdesc/prefercite | archdesc/custodialhist| archdesc/altformavailable | archdesc/appraisal | 
                    archdesc/accruals">

                    <a href="#Administrative" class="display">Administrative Information</a>
                </xsl:if>
            <!--link to other finding aid-->
                <xsl:if test="archdesc/otherfindaid">
                    <a href="#{$otherfindaidLink}" class="display">
                        <xsl:value-of select="archdesc/otherfindaid/head"/>
                    </a>
                </xsl:if>
                <!--link to other descriptive data-->
                <xsl:if test="archdesc/odd">
                    <a href="#{$oddLink}" class="display">
                        <xsl:value-of select="archdesc/odd/head"/>
                    </a>
                </xsl:if>

                <!--link to bibliography-->
                <xsl:if test="archdesc/bibliography/*">

                    <a href="#{$bibLink}" class="display">
                        <xsl:value-of select="archdesc/bibliography/head"/>
                    </a>
                </xsl:if>
            <!--link to other keywords-->
                <xsl:if test="archdesc/index/head">
                   
                    <a href="#{$indexLink}" class="display">
                        <xsl:value-of select="archdesc/index/head"/>
                    </a>
                </xsl:if>

                <!--link to container description-->
                <xsl:if test="string(archdesc/dsc)">
                     <a href="#" class="serialsTOC">
                        <img id="serialsImg" src="http://dlib.nyu.edu/eadapp/images/arrowdn.gif"
                            border="0" onclick="clickSeries()"/>
                    </a>
                    <xsl:text> </xsl:text>
                    <a href="#{$containerLink}" class="serialsTOC">
                        <xsl:value-of select="archdesc/dsc/head"/>
                    </a>

                    <div id="divSeries">
                        <!--generates series and subseries titles-->
                        <xsl:call-template name="processSerials">
                            <!--depending on the type of component, use c01 or c node-->
                            <xsl:with-param name="processSeriesNode" select="archdesc/dsc/c01 | archdesc/dsc/c[@level='series']"/>
                            <xsl:with-param name="processSubSeriesNode" select="archdesc/dsc/c01/c02[@level='subseries'] | archdesc/dsc/c[@level='series']/c[@level='subseries']"/>
                        </xsl:call-template>
                    </div>
                </xsl:if>
                <div id="divSearch">
		<input class="inputBorder" type="text" name="q" size="20">
		<input value="Go" type="submit">
		</div>
		<div id="searchResults"></div>
           
        </td>

    </xsl:template>

    
    <xsl:template name="content">
        <!--table cell containing content-->
        <td  id="displayContent">
            <div id="divEad">
                <xsl:call-template name="eadHeader"/>
                <div id="content">
                    <xsl:call-template name="archdesc-did"/>
                    <xsl:call-template name="archdesc-bioghist"/>
                    <xsl:call-template name="archdesc-scopecontent"/>
                    <xsl:call-template name="archdesc-arrangement"/>
                  <xsl:call-template name="archdesc-relatedmaterial"/>
                    <xsl:call-template name="archdesc-separatedmaterial"/>
                    <xsl:call-template name="archdesc-otherfindaid"/>
                    <xsl:call-template name="archdesc-restrict"/>
                    <xsl:call-template name="archdesc-control"/>
                    <xsl:call-template name="archdesc-admininfo"/>
                    <xsl:call-template name="archdesc-index"/>
                    <xsl:call-template name="archdesc-bibliography"/>
                    <xsl:call-template name="archdesc-odd"/>
                    <xsl:call-template name="dsc"/>
                    
                </div>
            </div>
        </td>

    </xsl:template>

    <xsl:template name="eadHeader">
        <!--generating image based on archive name-->
        <xsl:variable name="imgPath">
            <xsl:choose>
                <xsl:when test="$collectionName = 'tamwag'">
                    <xsl:text>http://dlib.nyu.edu/eadapp/images/tamnew.jpg</xsl:text>
                </xsl:when>
                <xsl:when test="$collectionName = 'fales'">
                    <xsl:text>http://dlib.nyu.edu/eadapp/images/title2.gif</xsl:text>
                </xsl:when>
                <xsl:when test="$collectionName = 'archives'">
                    <xsl:text>http://dlib.nyu.edu/eadapp/images/ua_logo.gif</xsl:text>
                </xsl:when>
                <xsl:when test="$collectionName = 'rism'">
                    <xsl:text>http://dlib.nyu.edu/eadapp/images/rism.gif</xsl:text>
                </xsl:when>
                <xsl:when test="$collectionName = 'bhs'">
                    <xsl:text>http://dlib.nyu.edu/eadapp/images/72dpiBHSlogo_color_transpar.gif</xsl:text>
                </xsl:when>
            </xsl:choose>

        </xsl:variable>
        <a name="top">
            <img src="{$imgPath}" class="imgHeader"/>
        </a>
        <!--creating title header-->
        <xsl:for-each select="eadheader/filedesc/titlestmt">
            <p id="titleProper">
                <xsl:apply-templates select="titleproper"/>
            </p>
        </xsl:for-each>
        <div class="eadHeader">
            <xsl:for-each select="eadheader/filedesc/publicationstmt">
                <!--formatting is slightly different from the rest of the div-->
                <p class="eadAddress">
                    <xsl:apply-templates select="address"/>
                </p>
                <xsl:value-of select="p"/>
                <br/>
                <xsl:value-of select="publisher"/>
                <br/>
                <xsl:value-of select="../titlestmt/author"/>
                <br/>

            </xsl:for-each>
           
            <!-- added profiledesc and revisiondesc -->
            <xsl:for-each select="eadheader">

                <xsl:value-of select="profiledesc"/>
                <br/>
                <xsl:value-of select="revisiondesc"/>
                <br/>

            </xsl:for-each>
        </div>
        <hr/>
    </xsl:template>
   
   <!--some addresses don't have line breal. This template handles that-->
    <xsl:template match="addressline[not(lb) and not(contains(.,'http://')) and (name(../..) = 'publicationstmt')]">
        <!--add extra line break to separate address from contact info--> 
        <xsl:if test="position() = 5">
            <br/>
        </xsl:if>
        <xsl:apply-templates/><br/>
        
    </xsl:template>
    <xsl:template match="date">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!--if node matches this, don't do anything-->
    <xsl:template match="num"/>
  
  <!--creating anchor link if addressline has a url-->
    <xsl:template match="addressline[contains(.,'http://')]">
        <a href="{substring-after(.,'URL: ')}"> <xsl:apply-templates/></a>
    </xsl:template>
    
    <!--This template rule formats the top-level did element. -->
    <xsl:template name="archdesc-did">
        <xsl:variable name="file" select="eadheader/eadid"/>
           
        <!--For each element of the did, this template inserts the value of the LABEL attribute or, if none is present, a default value. -->

        <xsl:for-each select="archdesc/did">
            <table width="100%">
                <tr>
                    <td width="5%"> </td>
                    <td width="20%"> </td>
                    <td width="75%"> </td>
                </tr>
                <tr>
                    <td colspan="3">
                        <h3>
                            <a name="{$didLink}"/>
                            <xsl:apply-templates select="head"/>
                        </h3>
                    </td>
                </tr>


                <xsl:if test="origination">
                    <xsl:for-each select="origination">
                        <xsl:choose>
                            <xsl:when test="@label">
                                <tr>
                                    <td> </td>
                                    <td>
                                        <b>
                                            <xsl:value-of select="@label"/>: </b>
                                    </td>
                                    <td>
                                        <xsl:apply-templates select="."/>
                                    </td>
                                </tr>
                            </xsl:when>
                            <xsl:otherwise>
                                <tr>
                                    <td> </td>
                                    <td>
                                        <b>
                                            <xsl:text>Creator: </xsl:text>
                                        </b>
                                    </td>
                                    <td>
                                        <xsl:apply-templates select="."/>
                                    </td>
                                </tr>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:if>

                <!-- Tests for and processes various permutations of unittitle and unitdate. -->
                <xsl:for-each select="unittitle">
                    <xsl:choose>
                        <xsl:when test="@label">
                            <tr>
                                <td> </td>
                                <td>
                                    <b>
                                        <xsl:value-of select="@label"/>: </b>
                                </td>
                                <td>
                                    <xsl:apply-templates select="text() |* [not(self::unitdate)]"/>
                                </td>
                            </tr>
                        </xsl:when>
                        <xsl:otherwise>
                            <tr>
                                <td> </td>
                                <td>
                                    <b>
                                        <xsl:text>Title: </xsl:text>
                                    </b>
                                </td>
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
                                    <td> </td>
                                    <td>
                                        <b>
                                            <xsl:value-of select="./unitdate/@label"/>
                                        </b>
                                    </td>
                                    <td>
                                        <xsl:apply-templates select="./unitdate"/>
                                    </td>
                                </tr>
                            </xsl:when>
                            <xsl:otherwise>
                                <tr>
                                    <td> </td>
                                    <td>
                                        <b>
                                            <xsl:text>Dates: </xsl:text>
                                        </b>
                                    </td>
                                    <td>
                                        <xsl:apply-templates select="./unitdate"/>
                                    </td>
                                </tr>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:for-each>


                <!-- Processes the unit date if it is not a child of unit title but a child of did, the current context. -->
                <xsl:if test="unitdate">
                    <xsl:for-each select="unitdate">
                        <xsl:choose>
                            <xsl:when test="./@label">
                                <tr>
                                    <td> </td>
                                    <td>
                                        <b>
                                            <xsl:value-of select="./@label"/>
                                        </b>
                                    </td>
                                    <td>
                                        <xsl:apply-templates select="."/>
                                    </td>
                                </tr>
                            </xsl:when>
                            <xsl:otherwise>
                                <tr>
                                    <td> </td>
                                    <td>
                                        <b>
                                            <xsl:text>Dates: </xsl:text>
                                        </b>
                                    </td>
                                    <td>
                                        <xsl:apply-templates select="."/>
                                    </td>
                                </tr>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:if>

                <xsl:if test="abstract">
                    <xsl:choose>
                        <xsl:when test="@label">
                            <tr>
                                <td> </td>
                                <td>
                                    <b>
                                        <xsl:value-of select="@label"/>
                                    </b>
                                </td>
                                <td>
                                    <xsl:apply-templates select="abstract"/>
                                </td>
                            </tr>
                        </xsl:when>
                        <xsl:otherwise>
                            <tr>
                                <td> </td>
                                <td>
                                    <b>
                                        <xsl:text>Abstract: </xsl:text>
                                    </b>
                                </td>
                                <td>
                                    <xsl:apply-templates select="abstract"/>
                                </td>
                            </tr>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>

                <xsl:if test="physdesc">
                    <xsl:choose>
                        <xsl:when test="@label">
                            <tr>
                                <td> </td>
                                <td>
                                    <b>
                                        <xsl:value-of select="@label"/>
                                    </b>
                                </td>
                                <td>
                                    <xsl:apply-templates select="physdesc"/>
                                </td>
                            </tr>
                        </xsl:when>

                        <xsl:otherwise>
                            <tr>
                                <td> </td>
                                <td>
                                    <b>
                                        <xsl:text>Quantity: </xsl:text>
                                    </b>
                                </td>
                                <td>
                                    <xsl:apply-templates select="physdesc"/>
                                </td>
                            </tr>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>


                <xsl:if test="unitid">
                    <xsl:choose>
                        <xsl:when test="@label">
                            <tr>
                                <td> </td>
                                <td>
                                    <b>
                                        <xsl:value-of select="@label"/>
                                    </b>
                                </td>
                                <td>
                                    <xsl:apply-templates select="unitid"/>
                                </td>
                            </tr>
                        </xsl:when>

                        <xsl:otherwise>
                            <tr>
                                <td> </td>
                                <td>
                                    <b>
                                        <xsl:text>Call Phrase: </xsl:text>
                                    </b>
                                </td>
                                <td>
                                    <xsl:apply-templates select="unitid"/>

                                </td>
                            </tr>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>


                <xsl:if test="note">
                    <xsl:for-each select="note">
                        <xsl:choose>
                            <xsl:when test="@label">
                                <tr>
                                    <td> </td>
                                    <td>
                                        <b>
                                            <xsl:value-of select="@label"/>
                                        </b>
                                    </td>
                                </tr>
                                <xsl:for-each select="p">
                                    <tr>
                                        <td> </td>
                                        <td>
                                            <xsl:apply-templates/>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </xsl:when>

                            <xsl:otherwise>
                                <tr>
                                    <td> </td>
                                    <td>
                                        <b>
                                            <xsl:text>Note: </xsl:text>
                                        </b>
                                    </td>
                                    <td>
                                        <xsl:apply-templates select="note"/>
                                    </td>
                                </tr>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:if>
            </table>
            <hr/>

        </xsl:for-each>
    </xsl:template>

    <!--This template rule formats the top-level bioghist element. -->
    <xsl:template name="archdesc-bioghist">
        <xsl:variable name="file" select="eadheader/eadid"/>
        

        <xsl:if test="archdesc/bioghist/*">
            <xsl:for-each select="archdesc/bioghist">
                <xsl:apply-templates/>
                <hr/>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="archdesc/bioghist/head">
        <h3>
            <a name="{$bioghistLink}"/>
            <xsl:apply-templates/>
        </h3>
    </xsl:template>

    <xsl:template match="archdesc/bioghist/p">
        <p style="margin-left: 30pt">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="archdesc/bioghist/bioghist">
        <h3>
            <xsl:apply-templates select="head"/>
        </h3>
        <xsl:for-each select="p">
            <p style="margin-left: 30pt">
                <xsl:apply-templates select="."/>
            </p>
        </xsl:for-each>
    </xsl:template>

    <!--This template rule formats a chronlist element. -->
    <xsl:template match="*/chronlist">

        <table width="100%" cellpadding="3">

            <tr>
                <td width="5%"> </td>
                <td width="30%"> </td>
                <td width="65%"> </td>
            </tr>

            <xsl:for-each select="head">
                <xsl:apply-templates/>
            </xsl:for-each>

            <xsl:for-each select="listhead">
                <tr>
                    <td>
                        <b>
                            <xsl:apply-templates select="head01"/>
                        </b>
                    </td>
                    <td>
                        <b>
                            <xsl:apply-templates select="head02"/>
                        </b>
                    </td>
                </tr>
            </xsl:for-each>

            <xsl:for-each select="chronitem">
                <tr>
                    <td/>
                    <td>
                        <xsl:apply-templates select="date"/>
                    </td>
                    <td>

                        <xsl:for-each select="event | eventgrp/event">
                            <xsl:apply-templates/>
                            <br/>
                        </xsl:for-each>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:template>

    <!--This template rule formats the scopecontent element. -->
    <xsl:template name="archdesc-scopecontent">
        <xsl:if test="archdesc/scopecontent/*">
            <xsl:for-each select="archdesc/scopecontent">
                <xsl:apply-templates/>
            </xsl:for-each>
            <hr/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="archdesc/scopecontent/head">
        <h3>
            <a name="{$scopeLink}"/>
            <xsl:apply-templates/>
        </h3>
    </xsl:template>

    <!-- This formats an organization list embedded in a scope content statement. -->
    <xsl:template match="archdesc/scopecontent/arrangement">
        <xsl:for-each select="p">
            <p style="margin-left: 30pt">
                <xsl:apply-templates select="."/>
            </p>
        </xsl:for-each>
        <xsl:for-each select="list">
            <xsl:for-each select="item">
                <p style="margin-left: 60pt">
                    <a>
                        <xsl:attribute name="href">#series<xsl:number/>
                        </xsl:attribute>
                        <xsl:apply-templates select="."/>
                    </a>
                </p>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="archdesc/scopecontent/p">
        <p style="margin-left: 30pt">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <!--This template rule formats the arrangement element. -->
    <xsl:template name="archdesc-arrangement">
        <xsl:if test="archdesc/arrangement/*">
            <xsl:for-each select="archdesc/arrangement">
                <table width="100%">
                    <tr><td width="5%"> </td><td width="5%"> </td>
                        <td width="90%"> </td></tr>
                    
                    <tr><td colspan="3"> <h3><a name="{$arrangementLink}"></a>
                        <xsl:apply-templates select="head"/>
                    </h3>
                    </td></tr>
                    
                    <xsl:for-each select="p">
                        <tr><td> </td><td colspan="2">
                            <xsl:apply-templates select="."/>
                        </td></tr>
                    </xsl:for-each>
                    
                    
                    <xsl:for-each select="list">
                        <tr><td> </td><td colspan="2">
                            <xsl:apply-templates select="head"/>
                        </td></tr>
                        <xsl:for-each select="item">
                            <tr><td> </td><td> </td><td colspan="1">
                                <a><xsl:attribute name="href">#series<xsl:number/>
                                </xsl:attribute>
                                    <xsl:apply-templates select="."/>
                                </a>
                            </td></tr>
                        </xsl:for-each>
                    </xsl:for-each>
                </table>
            </xsl:for-each>
          
            <hr/>
        </xsl:if>
    </xsl:template>
    <!--This template rule formats the top-level relatedmaterial element. -->
    
    <xsl:template name="archdesc-relatedmaterial">
        <xsl:if test="archdesc/relatedmaterial/*">
            <h3><a name="{$relatedLink}"/>
                <b><xsl:apply-templates select="archdesc/relatedmaterial/head"/></b></h3>
            <xsl:for-each select="archdesc/relatedmaterial">
                <xsl:apply-templates select="*[not(self::head)]"/> 
            </xsl:for-each>
            <hr/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="archdesc/relatedmaterial/p">
        <p style="margin-left : 30pt">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <!--This template rule formats the top-level separatedmaterial element. -->
    
    <xsl:template name="archdesc-separatedmaterial">
        <xsl:if test="//separatedmaterial">
            <h3><a name="{$separatedLink}"/>
                <b><xsl:apply-templates select="//separatedmaterial/head"/></b></h3>
            <xsl:for-each select="archdesc/separatedmaterial">
                <xsl:apply-templates select="*[not(self::head)]"/> 
            </xsl:for-each>
            <hr/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="archdesc/separatedmaterial/p">
        <p style="margin-left : 30pt">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <!--This template rule formats the top-level otherfindaid element. -->
    
    <xsl:template name="archdesc-otherfindaid">
        <xsl:if test="archdesc/otherfindaid">
            <xsl:for-each select="archdesc/otherfindaid">
                <h3><a name="{$otherfindaidLink}"/>
                    <b><xsl:apply-templates select="head"/>
                    </b></h3>
                <xsl:for-each select="p">
                    <p style="margin-left : 30pt">
                        <xsl:apply-templates select="."/>
                    </p>
                </xsl:for-each>
      
            </xsl:for-each>
            <hr/>
        </xsl:if>
    </xsl:template>
    
    
    <!--This template rule formats a top-level accessretrict element. -->
    <xsl:template name="archdesc-restrict">
        <xsl:if test="archdesc/accessrestrict/* | archdesc/userestrict/*">
            <h3>
                <a name="Restrictions"/>
                <b><xsl:text>Restrictions</xsl:text>
                </b></h3>
            <xsl:for-each select="archdesc/accessrestrict">
                <h4 style="margin-left : 15pt"><b><xsl:value-of select="head"/></b></h4>
                <xsl:for-each select="p">
                    <p style="margin-left : 30pt">
                        <xsl:apply-templates select="."/>
                    </p>
                </xsl:for-each>
            </xsl:for-each>
            
            <xsl:for-each select="archdesc/userestrict">
                <h4 style="margin-left : 15pt"><b><xsl:value-of select="head"/></b></h4>
                <xsl:for-each select="p">
                    <p style="margin-left : 30pt">
                        <xsl:apply-templates select="."/>
                    </p>
                </xsl:for-each>
            </xsl:for-each>
    
            <hr/>
        </xsl:if>
    </xsl:template>
    
    <!--access points-->
    <xsl:template name="archdesc-control">
        <xsl:if test="archdesc/controlaccess/*">
            <xsl:for-each select="archdesc/controlaccess">
                <table width="100%">
                    <tr><td width="5%"> </td><td width="5%"> </td>
                        <td width="90%"> </td></tr>
                    
                    <tr><td colspan="3"><h3><a name="{$accessPointLink}"></a>
                        <xsl:apply-templates select="head"/>
                    </h3> </td></tr>
                    
                    <tr><td> </td><td colspan="2">
                        <xsl:apply-templates select="p"/>
                    </td></tr>
                    
                    <xsl:for-each select="./controlaccess">
                        <tr><td> </td><td colspan="2"><b>
                            <xsl:apply-templates select="head"/>
                        </b></td></tr>
                        
                        <xsl:for-each select="name | subject | corpname | persname | genreform | 
                            famname | title | geogname | occupation">
                            
                            <xsl:sort select="."/>
                            
                            <tr><td></td><td></td><td>
				<xsl:if test="string(.)">

                                 <xsl:variable name="queryType">
				<!--empty message for bug workaround-->
				<xsl:message/>
                                <xsl:choose>
                                    <xsl:when test="../head = 'Subject Names:'">
                                        <xsl:text>subject.person.lcsh:</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="../head = 'Subject Organizations:'">
                                        <xsl:text>subject.organization.lcnaf:</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="../head = 'Subject Topics:'">
                                        <xsl:text>subject.lcsh:</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="../head = 'Subject Places:'">
                                        <xsl:text>coverage.geographical.lcsh:</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="../head = 'Document Types:'">
                                        <xsl:text>type.att:</xsl:text>
                                    </xsl:when>
                                </xsl:choose>
                                </xsl:variable>
				
				<xsl:choose>
                                <xsl:when test="self::persname | self::corpname | self::subject | self::geogname | self::genreform">
                                <a href="{concat($solrHost,$solrQueryURL,'fq=',$queryType,.)}">
                                <xsl:apply-templates select="."/>
                                </a>
                                </xsl:when>
    				<xsl:otherwise>
                                <xsl:apply-templates select="."/>
				</xsl:otherwise></xsl:choose></xsl:if>
                            </td></tr>
                        </xsl:for-each>
                    </xsl:for-each>
                </table>
            </xsl:for-each>
       
            <hr/>
        </xsl:if>
    </xsl:template>
    
    <!-- admininfo -->
    
    <xsl:template name="archdesc-admininfo">
        <xsl:if test="archdesc/prefercite//text() | archdesc/custodhist//text() | 
            archdesc/altformavail//text() |
            archdesc/acqinfo//text() | 
            archdesc/processinfo//text() | archdesc/appraisal//text() | 
            archdesc/accruals//text()">
            <h3><a name="Administrative"/>
                <xsl:text>Administrative Information</xsl:text>
            </h3>
            <xsl:call-template name="archdesc-custodhist"/>
            <xsl:call-template name="archdesc-altform"/>
            <xsl:call-template name="archdesc-prefercite"/>
            <xsl:call-template name="archdesc-acqinfo"/>
            <xsl:call-template name="archdesc-processinfo"/>
            <xsl:call-template name="archdesc-appraisal"/>
            <xsl:call-template name="archdesc-accruals"/>
      
            <hr/>
        </xsl:if>
    </xsl:template>
    
    <!--This template rule formats a top-level custodhist element. -->
    <xsl:template name="archdesc-custodhist">
        <xsl:if test="archdesc/custodhist/*">
            <xsl:for-each select="archdesc/custodhist">
                <h4 style="margin-left : 15pt">
                    <a name="a16"></a>
                    <b><xsl:apply-templates select="head"/>
                    </b></h4>
                <xsl:for-each select="p">
                    <p style="margin-left : 30pt">
                        <xsl:apply-templates select="."/>
                    </p>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    
    <!--This template rule formats a top-level altformavailable element. -->
    <xsl:template name="archdesc-altform">
        <xsl:if test="archdesc/altformavailable/*">
            <xsl:for-each select="archdesc/altformavailable">
                <h4 style="margin-left : 15pt">
                    <a name="a17"></a>
                    <b><xsl:apply-templates select="head"/>
                    </b></h4>
                <xsl:for-each select="p">
                    <p style="margin-left : 30pt">
                        <xsl:apply-templates select="."/>
                    </p>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    
    
    <!--This template rule formats a top-level prefercite element. -->
    <xsl:template name="archdesc-prefercite">
        <xsl:if test="archdesc/prefercite/*">
            <xsl:for-each select="archdesc/prefercite">
                <h4 style="margin-left : 15pt">
                    <a name="a18"></a>
                    <b><xsl:apply-templates select="head"/>
                    </b></h4>
                <xsl:for-each select="p">
                    <p style="margin-left : 30pt">
                        <xsl:apply-templates select="."/>
                    </p>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    
    <!--This template rule formats a top-level acqinfo element. -->
    <xsl:template name="archdesc-acqinfo">
        <xsl:if test="archdesc/acqinfo/*">
            <xsl:for-each select="archdesc/acqinfo">
                <h4 style="margin-left : 15pt"> 
                    <a name="a19"></a>
                    <b><xsl:apply-templates select="head"/>
                    </b></h4>
                <xsl:for-each select="p">
                    <p style="margin-left : 30pt">
                        <xsl:apply-templates select="."/>
                    </p>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <!--This template rule formats a top-level procinfo element. -->
    <xsl:template name="archdesc-processinfo">
        <xsl:if test="archdesc/processinfo/*">
            <xsl:for-each select="archdesc/processinfo">
                <h4 style="margin-left : 15pt">
                    <a name="a20"></a>
                    <b><xsl:apply-templates select="head"/>
                    </b></h4>
                <xsl:for-each select="p">
                    <p style="margin-left : 30pt">
                        <xsl:apply-templates select="."/>
                    </p>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <!--This template rule formats a top-level appraisal element. -->
    <xsl:template name="archdesc-appraisal">
        <xsl:if test="archdesc/appraisal/*">
            <xsl:for-each select="archdesc/appraisal">
                <h4 style="margin-left : 15pt"> 
                    <a name="a21"></a>
                    <b><xsl:apply-templates select="head"/>
                    </b></h4>
                <xsl:for-each select="p">
                    <p style="margin-left : 30pt">
                        <xsl:apply-templates select="."/>
                    </p>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <!--This template rule formats a top-level accruals element. -->
    <xsl:template name="archdesc-accruals">
        <xsl:if test="archdesc/accruals/*">
            <xsl:for-each select="archdesc/accruals">
                <h4 style="margin-left : 15pt">
                    <a name="a22"></a>
                    <b><xsl:apply-templates select="head"/>
                    </b></h4>
                <xsl:for-each select="p">
                    <p style="margin-left : 25pt">
                        <xsl:apply-templates select="."/>
                    </p>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <!--This template rule formats the top-level index element. -->
    <xsl:template name="archdesc-index">
        <xsl:if test="archdesc/index/*">
            <xsl:for-each select="archdesc/index">
                <h3><a name="{$indexLink}"/>
                    <b><xsl:apply-templates select="head"/>
                    </b></h3>
                <xsl:for-each select="p">
                    <p style="margin-left : 30pt">
                        <xsl:apply-templates select="."/>
                    </p>
                </xsl:for-each>
            </xsl:for-each>
  
            <hr/>
        </xsl:if>
    </xsl:template>
    
    <!--This template rule formats the top-level bibliography element. -->
    <xsl:template name="archdesc-bibliography">
        <xsl:if test="ead/archdesc/bibliography/*">
            <xsl:for-each select="archdesc/bibliography">
                <h3><a name="{$bibLink}"></a>
                    <b><xsl:apply-templates select="head"/>
                    </b></h3>
                <xsl:for-each select="p">
                    <xsl:for-each select="bibref">
                        <p style="margin-left : 30pt">
                            <xsl:apply-templates select="."/>
                        </p>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:for-each>
            <hr/>
        </xsl:if>
    </xsl:template>
    
    <!--This template rule formats the top-level odd element. -->
    <xsl:template name="archdesc-odd">
        <xsl:if test="archdesc/odd/*">
            <xsl:for-each select="archdesc/odd">
                <h3><a name="{$oddLink}"></a>
                    <b><xsl:apply-templates select="head"/>
                    </b></h3>
                <xsl:for-each select="p">
                    <p style="margin-left : 30pt"> 
                        <xsl:apply-templates select="."/>
                    </p>
                </xsl:for-each>
            </xsl:for-each>
    
            <hr/>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
