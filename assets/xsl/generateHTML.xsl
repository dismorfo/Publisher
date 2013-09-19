<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ns2="http://www.w3.org/1999/xlink" version="2.0" xpath-default-namespace="urn:isbn:1-931666-22-9">


  <!--Added by Brian Hoffman 2008
      Small templates to convert EAD tags to HTML-->
  <xsl:template match="text()">
    <xsl:value-of select="."/>
    <!--
	<xsl:if test="following-sibling::title">
	<xsl:apply-templates select="following-sibling::title[1]"/>
	</xsl:if>
	<xsl:if test="following-sibling::emph">
	<xsl:apply-templates select="following-sibling::emph[1]"/>
	</xsl:if>
    -->
  </xsl:template>
  <xsl:template match="head">
	
	<xsl:choose>
		<xsl:when test="not(following-sibling::*) and not(preceding-sibling::*)">
			<!--Sometimes the AT outputs elements with nothing but a <head> tag-->
		</xsl:when>
		<xsl:when test="ancestor::c[@level = 'series'] and parent::scopecontent">
			<i><xsl:value-of select="." /><xsl:text>: </xsl:text>
		</i>
		</xsl:when>
		
		<xsl:otherwise>
	
    <xsl:variable name="fontSize">
      <xsl:choose>
	<xsl:when test="ancestor::c and contains(name(..),'restrict')">
	  <xsl:text>4</xsl:text>
	</xsl:when>
	<xsl:when test="ancestor::prefercite | ancestor::custodhist | ancestor::altformavail | ancestor::acqinfo | ancestor::processinfo | ancestor::appraisal | ancestor::accruals | ancestor::accessrestrict | ancestor::userestrict">
		<xsl:text>4</xsl:text>
		</xsl:when>
	<xsl:otherwise>
	  <xsl:text>3</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:element name="h{$fontSize}">
      <xsl:value-of select="node() | text()" />
    </xsl:element>

</xsl:otherwise>
</xsl:choose>
  </xsl:template>

  <xsl:template match="p">
    <p>
	<xsl:apply-templates />
	</p>


  </xsl:template>


  <xsl:template match="address">
      <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="addressline">
    <xsl:value-of select="text() | node()" />
    <br />
  </xsl:template>

  <!-- The following templates format the display of various RENDER attributes. -->
  
  <xsl:template match="*/title">
    <xsl:choose>
      <xsl:when test="@render='italic'">
	<i><xsl:apply-templates/></i>
      </xsl:when>
      <xsl:when test="@render='bold'">
	<b><xsl:apply-templates/></b>
      </xsl:when>
      <xsl:when test="@render='bolditalic'">
	<b><i><xsl:apply-templates/></i></b>
      </xsl:when>
      <xsl:when test="@render='super'">
	<sup><xsl:apply-templates/></sup>
      </xsl:when>
      <xsl:when test="@render='sub'">
	<sub><xsl:apply-templates/></sub>
      </xsl:when>
      <xsl:when test="@render='quoted'">
	&#x201C;<xsl:apply-templates/>&#x201D;
      </xsl:when>
      <xsl:when test="@render='underlined'">
	<u><xsl:apply-templates/></u>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*/emph">
    <xsl:choose>
      <xsl:when test="@render='italic'">
	<i><xsl:apply-templates/></i>
      </xsl:when>
      <xsl:when test="@render='bold'">
	<b><xsl:apply-templates/></b>
      </xsl:when>
      <xsl:when test="@render='bolditalic'">
	<b><i><xsl:apply-templates/></i></b>
      </xsl:when>
      <xsl:when test="@render='super'">
	<sup><xsl:apply-templates/></sup>
      </xsl:when>
      <xsl:when test="@render='sub'">
	<sub><xsl:apply-templates/></sub>
      </xsl:when>
      <xsl:when test="@render='quoted'">
	&#x201C;<xsl:apply-templates/>&#x201D;
      </xsl:when>
      <xsl:when test="@render='underlined'">
	<u><xsl:apply-templates/></u>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!--generates html equivalent of line break(lb)-->
  <xsl:template match="lb">
    <br/>
  </xsl:template>
  <xsl:template match="num">
    <xsl:value-of select="." />
  </xsl:template>
  <!-- This template converts a Ref element into an HTML anchor. -->
  <xsl:template match="archdesc//ref | archdesc//extref">
    <xsl:choose>
      <xsl:when test="@href|@ns2:href">
	<a href="{@href|@ns2:href}" target="_blank">
	  <xsl:value-of select="."/>
	</a>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template> 
  <!-- Converts an ID attribute into the name attribute of an HTML anchor to form the target of a Ref element. -->
  <xsl:template match="*[@id]">
    <a name="{@id}"/>
    <xsl:value-of select="."/>
  </xsl:template>
  <!--This template rule formats a list element. -->
  <xsl:template match="*/list">
    <xsl:for-each select="item">
      <p style="margin-left: 60pt">
	<xsl:apply-templates/>
      </p>
    </xsl:for-each>
  </xsl:template>
  <!--Formats a simple table. The width of each column is defined by the colwidth attribute in a colspec element. -->
  <xsl:template match="*/table">
    <xsl:for-each select="tgroup">
      <table width="100%">
	<tr>
	  <xsl:for-each select="colspec">
	    <td width="{@colwidth}"></td>
	  </xsl:for-each>
	</tr>
	<xsl:for-each select="thead">
	  <xsl:for-each select="row">
	    <tr>
	      <xsl:for-each select="entry">
		<td valign="top"><b><xsl:value-of select="."/></b>
		</td>
	      </xsl:for-each>
	    </tr>
	  </xsl:for-each>
	</xsl:for-each>
	<xsl:for-each select="tbody">
	  <xsl:for-each select="row">
	    <tr>
	      <xsl:for-each select="entry">
		<td valign="top"><xsl:value-of select="."/></td>
	      </xsl:for-each>
	    </tr>
	  </xsl:for-each>
	</xsl:for-each>
      </table>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
