<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>
<xsl:template match="/">
<xsl:text>---
header:
  version: 17
  includes:
</xsl:text>
<xsl:apply-templates select='config/bblayers-conf-template'/>
<xsl:apply-templates select='config/local-conf-template'/>
<xsl:apply-templates select='config/targets/default'/>
<xsl:if test='config/bitbake|config/repos'>
<xsl:text>
</xsl:text>
<xsl:call-template name='repos'/>
</xsl:if>
<xsl:apply-templates select='config/local-conf'/>
</xsl:template>

<xsl:template match='config/targets/default'>
<xsl:text>
target: </xsl:text><xsl:value-of select='text()'/><xsl:text>
</xsl:text>
</xsl:template>

<xsl:template name='repos'>repos:
<xsl:apply-templates select='config/bitbake'/>
<xsl:apply-templates select='config/repos/repo[not(@disabled) or @disabled="no"]'/>
</xsl:template>

<xsl:template match='config/bitbake'>  bitbake:
<xsl:text>    url: "</xsl:text><xsl:value-of select='@url'/><xsl:text>"
</xsl:text>
<xsl:text>    branch: "</xsl:text><xsl:value-of select='@branch'/><xsl:text>"
</xsl:text>
<xsl:if test='@commit != "HEAD"'>
<xsl:text>    commit: "</xsl:text><xsl:value-of select='@commit'/><xsl:text>"
</xsl:text>
</xsl:if>
<xsl:text>    layers:
</xsl:text>
<xsl:text>      .: disabled
</xsl:text>
</xsl:template>

<xsl:template match='config/repos/repo'>
<xsl:text>
</xsl:text>
<xsl:text>  </xsl:text><xsl:value-of select='@name'/><xsl:text>:
</xsl:text>
<xsl:text>    url: "</xsl:text><xsl:value-of select='@url'/><xsl:text>"
</xsl:text>
<xsl:text>    branch: "</xsl:text><xsl:value-of select='@branch'/><xsl:text>"
</xsl:text>
<xsl:if test='@commit != "HEAD"'>
<xsl:text>    commit: "</xsl:text><xsl:value-of select='@commit'/><xsl:text>"
</xsl:text>
</xsl:if>
<xsl:apply-templates select='layers'/>
</xsl:template>

<xsl:template match='config/repos/repo/layers'>
<xsl:if test="*">
<xsl:text>    layers:
</xsl:text>
<xsl:for-each select='layer'>
<xsl:text>      </xsl:text><xsl:value-of select='text()'/>:
</xsl:for-each>
</xsl:if>
</xsl:template>

<xsl:template match='config/bblayers-conf-template'>
<xsl:text>    - </xsl:text><xsl:value-of select='$arTemplatePrefix'/><xsl:text>/templates/</xsl:text><xsl:value-of select='@name'/><xsl:text>.yml
</xsl:text>
</xsl:template>

<xsl:template match='config/local-conf-template'>
<xsl:text>    - </xsl:text><xsl:value-of select='$arTemplatePrefix'/><xsl:text>/templates/</xsl:text><xsl:value-of select='@name'/><xsl:text>.yml
</xsl:text>
</xsl:template>

<xsl:template match='config/local-conf'>
<xsl:text>
local_conf_header:
  oe-layersetup-local-conf-config-specific: |
</xsl:text>
<xsl:for-each select='line'>
<xsl:text>    </xsl:text><xsl:value-of select='text()'/><xsl:text>
</xsl:text>
</xsl:for-each>
</xsl:template>

</xsl:stylesheet>
