<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>
<xsl:template match="/">
<xsl:text>{
  "version": "1.0",
</xsl:text>
<xsl:text>  "description": "</xsl:text><xsl:value-of select='config/description/text()'/><xsl:text>",
</xsl:text>
<xsl:apply-templates select='config/repos'/>
<xsl:text>  "configuration": {
    "bitbake-setup": {
      "default": {
        "description": "Default build configuration",
         "template": "oe-layersetup-</xsl:text><xsl:value-of select='$arConfigName'/><xsl:text>",
         "targets": [ "bitbake -k </xsl:text><xsl:value-of select='config/targets/default/text()'/><xsl:text>" ]
      }
    }
  }
}
</xsl:text>
</xsl:template>

<xsl:template match='config/repos'>
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
<xsl:apply-templates select='repo[not(@disabled) or @disabled="no"]'/>
<xsl:text>  },
</xsl:text>
</xsl:template>

<xsl:template match='config/repos/repo'>
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

</xsl:stylesheet>
