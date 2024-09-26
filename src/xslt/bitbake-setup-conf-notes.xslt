<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>

<xsl:template match="/">
<xsl:text>
### Shell environment set up for builds. ###

You can now run 'bitbake &lt;target&gt;'

If you have not set MACHINE in your local.conf you can run
'MACHINE=xxxxx bitbake &lt;target&gt;'

Common targets are:
    </xsl:text><xsl:value-of select='config/targets/default/text()'/><xsl:text>
</xsl:text>
<xsl:apply-templates select='config/targets/target'/>
<xsl:text>
You can also run generated qemu images with a command like 'runqemu qemux86-64'.

Other commonly useful commands are:
 - 'devtool' and 'recipetool' handle common recipe tasks
 - 'bitbake-layers' handles common layer tasks
 - 'oe-pkgdata-util' handles common target package tasks
</xsl:text>
</xsl:template>

<xsl:template match='config/targets/target'>
<xsl:text>    </xsl:text><xsl:value-of select='text()'/><xsl:text>
</xsl:text>
</xsl:template>

</xsl:stylesheet>
