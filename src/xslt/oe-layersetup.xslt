<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>
<xsl:template match="/"># This file takes repo entries in the format
# repo name,repo uri,repo branch,repo commit[,layers=layer1:layer2...:layern]

<xsl:apply-templates select='config/motd'/>
<xsl:apply-templates select='config/bitbake'/>
<xsl:apply-templates select='config/repos'/>
<xsl:apply-templates select='config/bblayers-conf-template'/>
<xsl:apply-templates select='config/local-conf-template'/>
<xsl:apply-templates select='config/tools/tool[@type="oe-layersetup"]'/>
<xsl:apply-templates select='config/local-conf'/>
</xsl:template>

<xsl:template match='config/motd'>
<xsl:for-each select='line'>MOTD: <xsl:value-of select='text()'/><xsl:text>
</xsl:text>
</xsl:for-each>
<xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match='config/bitbake'>
<xsl:text>bitbake,</xsl:text><xsl:value-of select='@url'/>,<xsl:value-of select='@branch'/>,<xsl:value-of select='@commit'/><xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match='config/repos'>
<xsl:apply-templates select='repo'/>
<xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match='config/repos/repo'>
<xsl:if test='@disabled="true"'>#</xsl:if>
<xsl:value-of select='@name'/>,<xsl:value-of select='@url'/>,<xsl:value-of select='@branch'/>,<xsl:value-of select='@commit'/>
<xsl:apply-templates select='layers'/>
<xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match='config/repos/repo/layers'>,layers=<xsl:for-each select='layer'><xsl:value-of select='text()'/>
<xsl:if test="position() != last()">
<xsl:text>:</xsl:text>
</xsl:if>
</xsl:for-each>
</xsl:template>

<xsl:template match='config/bblayers-conf-template'>
<xsl:text>OECORELAYERCONF=./sample-files/</xsl:text><xsl:value-of select='@name'/><xsl:text>.sample
</xsl:text>
</xsl:template>

<xsl:template match='config/local-conf-template'>
<xsl:text>OECORELOCALCONF=./sample-files/</xsl:text><xsl:value-of select='@name'/><xsl:text>.sample
</xsl:text>
</xsl:template>

<xsl:template match='config/tools/tool'>
<xsl:for-each select='var'>
<xsl:value-of select='@name'/>=<xsl:value-of select='@value'/>
<xsl:text>
</xsl:text>
</xsl:for-each>
</xsl:template>

<xsl:template match='config/local-conf'>
<xsl:for-each select='line'>
LOCALCONF:<xsl:value-of select='text()'/>
</xsl:for-each>
<xsl:text>
</xsl:text>
</xsl:template>

</xsl:stylesheet>
