<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>

<xsl:template match="/">
    <xsl:text>BB_CONF_FRAGMENT_SUMMARY = "</xsl:text><xsl:value-of select='local-conf-template/summary/text()'/><xsl:text>"
BB_CONF_FRAGMENT_DESCRIPTION = "</xsl:text><xsl:value-of select='local-conf-template/description/text()'/><xsl:text>"

</xsl:text>
<xsl:apply-templates select='local-conf-template'/>
</xsl:template>

<xsl:template match='local-conf-template'>
<xsl:for-each select='line'>
<xsl:value-of select='text()'/>
<xsl:text>
</xsl:text>
</xsl:for-each>
</xsl:template>

</xsl:stylesheet>
