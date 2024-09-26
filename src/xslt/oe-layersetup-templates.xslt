<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>

<xsl:template match="/">
<xsl:apply-templates select='bblayers-conf-template'/>
<xsl:apply-templates select='local-conf-template'/>
</xsl:template>

<xsl:template match='bblayers-conf-template'>
<xsl:for-each select='line'>
<xsl:value-of select='text()'/>
<xsl:text>
</xsl:text>
</xsl:for-each>
</xsl:template>

<xsl:template match='local-conf-template'>
<xsl:for-each select='line'>
<xsl:value-of select='text()'/>
<xsl:text>
</xsl:text>
</xsl:for-each>
</xsl:template>

</xsl:stylesheet>
