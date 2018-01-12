<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:domain="urn:jboss:domain:5.0"
                xmlns:ut="urn:jboss:domain:undertow:3.0"
                exclude-result-prefixes="domain ut">

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="//domain:server//domain:management//domain:security-realms">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <domain:security-realm name="UndertowRealm">
                <domain:server-identities>
                    <domain:ssl>
                        <domain:keystore>
                            <xsl:attribute name="path">keycloak.jks</xsl:attribute>
                            <xsl:attribute name="relative-to">jboss.server.config.dir</xsl:attribute>
                            <xsl:attribute name="keystore-password">changeit</xsl:attribute>
                        </domain:keystore>
                    </domain:ssl>
                </domain:server-identities>
                <domain:authentication>
                    <domain:truststore>
                        <xsl:attribute name="path">keycloak.jks</xsl:attribute>
                        <xsl:attribute name="relative-to">jboss.server.config.dir</xsl:attribute>
                        <xsl:attribute name="keystore-password">changeit</xsl:attribute>
                    </domain:truststore>
                </domain:authentication>
            </domain:security-realm>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="//ut:subsystem/ut:server[@name='default-server']">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <ut:https-listener name="https">
                <xsl:attribute name="socket-binding">https</xsl:attribute>
                <xsl:attribute name="security-realm">UndertowRealm</xsl:attribute>
                <xsl:attribute name="verify-client">REQUESTED</xsl:attribute>
            </ut:https-listener>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
