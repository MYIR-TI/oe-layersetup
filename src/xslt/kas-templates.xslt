<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>

<xsl:template match="/">---
header:
  version: 17

<xsl:apply-templates select='bblayers-conf-template'/>
<xsl:apply-templates select='local-conf-template'/>
</xsl:template>

<xsl:template match='bblayers-conf-template'>
<xsl:text>bblayers_conf_header:
</xsl:text>
<xsl:text>  oe-layersetup-bblayers-conf-template: |</xsl:text>
<xsl:for-each select='line'>
<xsl:text>
</xsl:text>
<xsl:variable name='normal-line' select='normalize-space(text())'/>
<xsl:if test='string-length($normal-line) > 0'>
<xsl:text>    </xsl:text><xsl:value-of select='text()'/>
</xsl:if>
</xsl:for-each>
<xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match='local-conf-template'>
<xsl:text>local_conf_header:
</xsl:text>
<xsl:text>  oe-layersetup-local-conf-template: |</xsl:text>
<xsl:for-each select='line'>
<xsl:text>
</xsl:text>
<xsl:variable name='normal-line' select='normalize-space(text())'/>
<xsl:if test='string-length($normal-line) > 0'>
<xsl:text>    </xsl:text><xsl:value-of select='text()'/>
</xsl:if>
</xsl:for-each>
<xsl:apply-templates select='/config/local-conf'/>
<xsl:text>
</xsl:text>
</xsl:template>

</xsl:stylesheet>
