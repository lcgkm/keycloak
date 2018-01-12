<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:domain="urn:jboss:domain:5.0"
                xmlns:tx="urn:jboss:domain:transactions:3.0"
                xmlns:jgroups="urn:jboss:domain:jgroups:4.0"
                xmlns:ut="urn:jboss:domain:undertow:3.0"
                exclude-result-prefixes="domain tx jgroups ut">

    <xsl:output method="xml" indent="yes"/>

     <xsl:template match="//tx:subsystem/tx:core-environment">
        <xsl:copy>
            <xsl:attribute name="node-identifier">${jboss.tx.node.id}</xsl:attribute>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="//ut:subsystem/ut:server[@name='default-server']/ut:http-listener[@name='default']">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <xsl:attribute name="proxy-address-forwarding">true</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <!--
    <xsl:template match="//domain:socket-binding-group">
        <xsl:copy>
            <xsl:copy-of select="@*|node()"/>
            <socket-binding xmlns="urn:jboss:domain:5.0" name="proxy-https" port="443"/>
        </xsl:copy>
    </xsl:template>
    -->

    <xsl:template match="//jgroups:subsystem/jgroups:channels/jgroups:channel">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <xsl:attribute name="stack">${env.JGROUPS_STACK:udp}</xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="//jgroups:subsystem/jgroups:stacks/jgroups:stack[@name='udp']/jgroups:protocol[@type='PING']">
        <xsl:comment> PING was removed in favor of JDBC_PING </xsl:comment>
        <protocol xmlns="urn:jboss:domain:jgroups:5.0" type="JDBC_PING">
            <property name="datasource_jndi_name">java:jboss/datasources/KeycloakDS</property>
        </protocol>
    </xsl:template>

    <xsl:template match="//jgroups:subsystem/jgroups:stacks/jgroups:stack[@name='tcp']/jgroups:protocol[@type='MPING']">
        <xsl:comment> MPING was removed in favor of JDBC_PING </xsl:comment>
        <protocol xmlns="urn:jboss:domain:jgroups:5.0" type="JDBC_PING">
            <property name="datasource_jndi_name">java:jboss/datasources/KeycloakDS</property>
        </protocol>
    </xsl:template>

    <xsl:template match="/domain:server/domain:socket-binding-group/domain:socket-binding[@name='jgroups-mping']">
        <xsl:comment> jgroups-mping was removed at switch to JDBC_PING </xsl:comment>
    </xsl:template>

    <xsl:template match="/domain:server/domain:interfaces/domain:interface[@name='private']">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <nic xmlns="urn:jboss:domain:5.0" name="eth0"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
