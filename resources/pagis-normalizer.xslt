<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:pagi="http://pagi.digitalreasoning.com/pagis">
<xsl:output method="xml" version="1.0"
	      encoding="UTF-8" indent="yes"/>




<xsl:template match="node() | @*">
    <xsl:copy>

      <xsl:if test="contains(name(),'Property') and not(@minArity)">
	<xsl:attribute name="minArity">0</xsl:attribute>
      </xsl:if>

      <xsl:if test="contains(name(),'Property') and not(@maxArity)">
	<xsl:attribute name="maxArity">unbounded</xsl:attribute>
      </xsl:if>

      <xsl:if test="name()='edgeType' and not(@minArity)">
	<xsl:attribute name="minArity">0</xsl:attribute>
      </xsl:if>

      <xsl:if test="name()='edgeType' and not(@maxArity)">
	<xsl:attribute name="maxArity">unbounded</xsl:attribute>
      </xsl:if>

      <xsl:if test="name()='integerProperty' and not(@minRange)">
	<xsl:attribute name="minRange">-2147483648</xsl:attribute>
      </xsl:if>

      <xsl:if test="name()='integerProperty' and not(@maxRange)">
	<xsl:attribute name="maxRange">2147483647</xsl:attribute>
      </xsl:if>

      <xsl:if test="name()='floatProperty' and not(@minRange)">
	<xsl:attribute name="minRange">-3.4028235E38</xsl:attribute>
      </xsl:if>

      <xsl:if test="name()='floatProperty' and not(@maxRange)">
	<xsl:attribute name="maxRange">3.4028235E38</xsl:attribute>
      </xsl:if>


	<xsl:apply-templates select="@* | node()">
		<xsl:sort select="@name"/>
	</xsl:apply-templates>


    </xsl:copy>

  </xsl:template>


</xsl:stylesheet>
