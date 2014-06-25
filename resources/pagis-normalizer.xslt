<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pagi="http://pagi.org/schema"
                xmlns="http://pagi.org/schema">
	<xsl:output method="xml" version="1.0"
	            encoding="UTF-8" indent="yes"/>

	<xsl:template name="arityDefaults">
		<xsl:attribute name="minArity">0</xsl:attribute>
		<xsl:attribute name="maxArity">unbounded</xsl:attribute>
	</xsl:template>

	<xsl:template name="includeChildren">
		<xsl:param name="apply" select="@* | node()"/>
		<!-- This will override any of the default attributes set with anything available on the element. -->
		<xsl:apply-templates select="$apply">
			<xsl:sort select="@name"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="@* | node()" priority="1">
		<xsl:copy>
			<xsl:call-template name="includeChildren"/>
		</xsl:copy>

	</xsl:template>

	<xsl:template match="//pagi:floatProperty" priority="10">
		<xsl:copy>
			<xsl:call-template name="arityDefaults"/>
			<xsl:attribute name="minRange">-3.4028235E38</xsl:attribute>
			<xsl:attribute name="maxRange">3.4028235E38</xsl:attribute>
			<xsl:call-template name="includeChildren"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="//pagi:integerProperty" priority="10">
		<xsl:copy>
			<xsl:call-template name="arityDefaults"/>
			<xsl:attribute name="minRange">-2147483648</xsl:attribute>
			<xsl:attribute name="maxRange">2147483647</xsl:attribute>
			<xsl:call-template name="includeChildren"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="//pagi:booleanProperty" priority="10">
		<xsl:copy>
			<xsl:call-template name="arityDefaults"/>
			<xsl:call-template name="includeChildren"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="//pagi:stringProperty" priority="10">
		<xsl:copy>
			<xsl:call-template name="arityDefaults"/>
			<xsl:call-template name="includeChildren"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="//pagi:enumProperty" priority="10">
		<xsl:copy>
			<xsl:call-template name="arityDefaults"/>
			<xsl:call-template name="includeChildren"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="//pagi:edgeType" priority="10">
		<xsl:copy>
			<xsl:attribute name="name">
				<xsl:value-of select="@name"/>
			</xsl:attribute>

			<xsl:call-template name="arityDefaults"/>

			<xsl:attribute name="targetMinArity">0</xsl:attribute>
			<xsl:attribute name="targetMaxArity">unbounded</xsl:attribute>

			<xsl:call-template name="includeChildren">
				<xsl:with-param name="apply" select="@*[contains(name(), 'Arity')] | pagi:description | pagi:targetNodeType"/>
			</xsl:call-template>

			<xsl:if test="@targetNodeType">
				<xsl:element name="targetNodeType">
					<xsl:attribute name="name">
						<xsl:value-of select="@targetNodeType"/>
					</xsl:attribute>
				</xsl:element>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="//pagi:edgeTypeExtension" priority="10">
		<xsl:copy>
			<xsl:attribute name="name">
				<xsl:value-of select="@name"/>
			</xsl:attribute>

			<xsl:call-template name="includeChildren">
				<xsl:with-param name="apply" select="@*[contains(name(), 'Arity')] | pagi:description | pagi:targetNodeType"/>
			</xsl:call-template>

			<xsl:if test="@targetNodeType">
				<xsl:element name="targetNodeType">
					<xsl:attribute name="name">
						<xsl:value-of select="@targetNodeType"/>
					</xsl:attribute>
				</xsl:element>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
