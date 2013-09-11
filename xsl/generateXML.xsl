<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

    <!-- The following templates format the display of various RENDER attributes. -->
    
    <xsl:template match="*/title">
        <xsl:choose>
            <xsl:when test="@render='italic'">
                &lt;i&gt;<xsl:apply-templates/>&lt;/i&gt;
            </xsl:when>
            <xsl:when test="@render='bold'">
                &lt;b&gt;<xsl:apply-templates/>&lt;/b&gt;
            </xsl:when>
            <xsl:when test="@render='bolditalic'">
                &lt;b&gt;&lt;i&gt;<xsl:apply-templates/>&lt;/i&gt;&lt;/b&gt;
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
                &lt;u&gt;<xsl:apply-templates/>&lt;/u&gt;
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*/emph">
        <xsl:choose>
            <xsl:when test="@render='italic'">
                &lt;i&gt;<xsl:apply-templates/>&lt;/i&gt;
            </xsl:when>
            <xsl:when test="@render='bold'">
                &lt;b&gt;<xsl:apply-templates/>&lt;/b&gt;
            </xsl:when>
            <xsl:when test="@render='bolditalic'">
                &lt;b&gt;&lt;i&gt;<xsl:apply-templates/>&lt;/i&gt;&lt;/b&gt;
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
                &lt;u&gt;<xsl:apply-templates/>&lt;/u&gt;
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
   
   <!--generates html equivalent of line break(lb)-->
  <xsl:template match="lb">
    &lt;br/&gt;
  </xsl:template>
    

 
 

        
        
</xsl:stylesheet>
