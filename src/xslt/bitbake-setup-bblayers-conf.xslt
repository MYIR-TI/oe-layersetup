<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>

<xsl:template match="/">
<xsl:apply-templates select='config/bblayers-conf-template'/>
<xsl:text>
BBLAYERS ?= " \
</xsl:text>
<xsl:apply-templates select='config/repos'/>
<xsl:text>"
</xsl:text>
</xsl:template>

<xsl:template match='bblayers-conf-template'>
<xsl:for-each select='line'>
<xsl:value-of select='text()'/>
<xsl:text>
</xsl:text>
</xsl:for-each>
</xsl:template>

<xsl:template match='config/repos'>
<xsl:apply-templates select='repo[not(@disabled) or @disabled="no"]'/>
<xsl:text>    ##OEROOT##/../oe-layersetup
</xsl:text>
</xsl:template>

<xsl:template match='config/repos/repo'>
<xsl:variable name='loRepo' select='@name'/>
<xsl:choose>
<xsl:when test='layers/layer'>
<xsl:for-each select='layers/layer'>
<xsl:variable name='loLayer' select='text()'/>
<xsl:text>    ##OEROOT##/../</xsl:text><xsl:value-of select='$loRepo'/><xsl:text>/</xsl:text><xsl:value-of select='$loLayer'/><xsl:text>
</xsl:text>
</xsl:for-each>
</xsl:when>
<xsl:otherwise>
<xsl:text>    ##OEROOT##/../</xsl:text><xsl:value-of select='$loRepo'/><xsl:text>
</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

</xsl:stylesheet>
