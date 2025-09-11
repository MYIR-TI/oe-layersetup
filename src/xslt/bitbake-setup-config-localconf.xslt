<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>

<xsl:template match="/">
<xsl:apply-templates select='config/local-conf'/>
</xsl:template>

<xsl:template match='config/local-conf'>
<xsl:text>BB_CONF_FRAGMENT_SUMMARY = "Config specific overrides for </xsl:text><xsl:value-of select='$arConfigName'/><xsl:text>"
BB_CONF_FRAGMENT_DESCRIPTION = "Config specific overrides for </xsl:text><xsl:value-of select='$arConfigName'/><xsl:text>"

</xsl:text>
<xsl:for-each select='line'>
<xsl:value-of select='text()'/>
<xsl:text>
</xsl:text>
</xsl:for-each>
</xsl:template>

</xsl:stylesheet>
