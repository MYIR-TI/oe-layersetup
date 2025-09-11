<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>
<xsl:template match="/">
<xsl:text>{
  "version": "1.0",
</xsl:text>
<xsl:text>  "description": "</xsl:text><xsl:value-of select='config/description/text()'/><xsl:text>",
</xsl:text>
<xsl:apply-templates select='config/repos' mode='repo-list'/>
<xsl:variable name='loFragmentFilename' select="config/local-conf-template/@name"/>
<xsl:variable name='loFragmentName' select="substring-before($loFragmentFilename,'.conf')"/>
<xsl:text>  "bitbake-setup": {
    "configurations": [
      {
        "name": "</xsl:text><xsl:value-of select='config/distro/@name'/><xsl:text>",
        "description": "</xsl:text><xsl:value-of select='config/distro/description/text()'/><xsl:text>",
        "bb-layers": [ </xsl:text><xsl:apply-templates select='config/repos' mode='layer-list'/><xsl:text> ],
        "oe-fragments": [ "oe-layersetup/localconf/</xsl:text><xsl:value-of select='$loFragmentName'/><xsl:text>"</xsl:text><xsl:apply-templates select='config/local-conf'/><xsl:text> ],
        "oe-fragments-one-of": {
          "machine": {
            "description": "Available target machines",
            "options": [ </xsl:text><xsl:apply-templates select='config/machines'/><xsl:text> ]
          },
          "distro": {
            "description": "Available distributions",
            "options": [ </xsl:text><xsl:apply-templates select='config/distro/configs'/><xsl:text> ]
          }
        }
      }
    ]
  }
}
</xsl:text>
</xsl:template>

<xsl:template match='config/repos' mode='repo-list'>
<xsl:text>  "sources": {
    "oe-layersetup": {
      "git-remote": {
        "remotes": {
          "origin": {
            "uri": "https://git.ti.com/git/arago-project/oe-layersetup.git"
          }
        },
        "rev": "master"
      },
      "path": "oe-layersetup"
    },
    "bitbake": {
      "git-remote": {
        "remotes": {
          "origin": {
            "uri": "</xsl:text><xsl:value-of select='/config/bitbake/@url'/><xsl:text>"
          }
        },
        "rev": "</xsl:text><xsl:value-of select='/config/bitbake/@branch'/><xsl:text>"
      },
      "path": "bitbake"
    },
</xsl:text>
<xsl:apply-templates select='repo[not(@disabled) or @disabled="no"]' mode='repo-list'/>
<xsl:text>  },
</xsl:text>
</xsl:template>

<xsl:template match='config/repos/repo' mode='repo-list'>
<xsl:text>    "</xsl:text><xsl:value-of select='@name'/><xsl:text>": {
      "git-remote": {
        "remotes": {
          "origin": {
            "uri": "</xsl:text><xsl:value-of select='@url'/><xsl:text>"
          }
        },
        "rev": "</xsl:text><xsl:value-of select='@branch'/><xsl:text>"
      },
      "path": "</xsl:text><xsl:value-of select='@name'/><xsl:text>"
    }</xsl:text>
<xsl:if test="position() != last()">
<xsl:text>,</xsl:text>
</xsl:if>
<xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match='config/repos' mode='layer-list'>
<xsl:for-each select='repo[not(@disabled) or @disabled="no"]'>
<xsl:apply-templates select='.' mode='layer-list'/>
<xsl:text>,</xsl:text>
</xsl:for-each>
<xsl:text>"oe-layersetup"</xsl:text>
</xsl:template>

<xsl:template match='config/repos/repo' mode='layer-list'>
<xsl:variable name='loRepo' select='@name'/>
<xsl:choose>
<xsl:when test='layers/layer'>
<xsl:for-each select='layers/layer'>
<xsl:variable name='loLayer' select='text()'/>
<xsl:text>"</xsl:text><xsl:value-of select='$loRepo'/><xsl:text>/</xsl:text><xsl:value-of select='$loLayer'/><xsl:text>"</xsl:text><xsl:if test="position() != last()">
<xsl:text>,</xsl:text>
</xsl:if>
</xsl:for-each>
</xsl:when>
<xsl:otherwise>
<xsl:text>"</xsl:text><xsl:value-of select='$loRepo'/><xsl:text>"</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match='config/distro/configs'>
<xsl:for-each select='config'>
<xsl:variable name='loConfig' select='text()'/>
<xsl:text>"distro/</xsl:text><xsl:value-of select='$loConfig'/><xsl:text>"</xsl:text><xsl:if test="position() != last()">
<xsl:text>,</xsl:text>
</xsl:if>
</xsl:for-each>
</xsl:template>

<xsl:template match='config/machines'>
<xsl:for-each select='machine'>
<xsl:variable name='loMachine' select='text()'/>
<xsl:text>"machine/</xsl:text><xsl:value-of select='$loMachine'/><xsl:text>"</xsl:text><xsl:if test="position() != last()">
<xsl:text>,</xsl:text>
</xsl:if>
</xsl:for-each>
</xsl:template>

<xsl:template match='config/local-conf'>
    <xsl:text>, "oe-layersetup/localconf/configs/</xsl:text><xsl:value-of select='$arConfigName'/><xsl:text>.conf"</xsl:text>
</xsl:template>

</xsl:stylesheet>
