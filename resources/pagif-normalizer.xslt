<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" version="1.0" encoding="UTF-8"
                indent="yes" />
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="//*[@value]">
        <xsl:element name="{local-name()}" namespace="{namespace-uri()}">
            <xsl:attribute name="key"><xsl:value-of select="@key"/></xsl:attribute>
            <xsl:element name="value" namespace="{namespace-uri()}">
                <xsl:attribute name="{substring-before(local-name(), '-')}">
                    <xsl:value-of select="@value"/>
                </xsl:attribute>
            </xsl:element>
        </xsl:element>
        <xsl:copy-of select="node()"/>
    </xsl:template>
</xsl:stylesheet>
