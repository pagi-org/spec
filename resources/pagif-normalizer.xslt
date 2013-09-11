<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8"
	            indent="yes"/>
	<xsl:template match="node() | @*">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="//*[@v]">
		<xsl:element name="{local-name()}" namespace="{namespace-uri()}">
			<xsl:attribute name="k">
				<xsl:value-of select="@k"/>
			</xsl:attribute>
			<xsl:element name="val" namespace="{namespace-uri()}">
				<xsl:attribute name="{concat(substring-before(local-name(), 'Prop'),substring-before(local-name(), 'Feat'))}">
					<xsl:value-of select="@v"/>
				</xsl:attribute>
			</xsl:element>
		</xsl:element>
		<xsl:copy-of select="node()"/>
	</xsl:template>
</xsl:stylesheet>
