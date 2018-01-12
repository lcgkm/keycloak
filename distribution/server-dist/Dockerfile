FROM library/openjdk:latest
MAINTAINER lcgkm321.max@gmail.com

ENV KEYCLOAK_VERSION 4.0.0.CR1-SNAPSHOT
# Enables signals getting passed from startup script to JVM
# ensuring clean shutdown when container is stopped.
ENV LAUNCH_JBOSS_IN_BACKGROUND 1
ENV JGROUPS_STACK tcp
ENV KEYCLOAK_HOME /opt/keycloak
ENV MAVEN_REPO_URL http://nexus.smec.sap.corp:8081/nexus/content/groups/allrepository
WORKDIR $KEYCLOAK_HOME

COPY deploy/docker-entrypoint.sh ./
COPY target/keycloak-$KEYCLOAK_VERSION/ .
COPY deploy/ .

# http://www.keycloak.org/docs/2.5/server_installation/topics/network/https.html
RUN keytool -importkeystore \
        -deststorepass changeit -destkeypass changeit \
        -destkeystore standalone/configuration/keycloak.jks -deststoretype pkcs12 \
        -srckeystore ssl/cert.p12 -srcstoretype PKCS12 -srcstorepass changeit \
        -alias keycloak; \
    echo "yes" | keytool -import -trustcacerts \
        -file ssl/sso_ca.crt -alias sso_ca \
        -keystore standalone/configuration/keycloak.jks -storepass changeit

RUN curl $MAVEN_REPO_URL/net/sf/saxon/Saxon-HE/9.8.0-3/Saxon-HE-9.8.0-3.jar \
        -o ./saxon9he.jar; \
    java -jar ./saxon9he.jar \
        -s:standalone/configuration/standalone-ha.xml \
        -xsl:./setLogLevel.xsl \
        -o:standalone/configuration/standalone-ha.xml && \
    java -jar ./saxon9he.jar \
        -s:standalone/configuration/standalone-ha.xml \
        -xsl:./changeDatabase.xsl \
        -o:standalone/configuration/standalone-ha.xml && \
    java -jar ./saxon9he.jar \
        -s:standalone/configuration/standalone-ha.xml \
        -xsl:./setCluster.xsl \
        -o:standalone/configuration/standalone-ha.xml && \
    java -jar ./saxon9he.jar \
        -s:standalone/configuration/standalone-ha.xml \
        -xsl:./setHTTPS.xsl \
        -o:standalone/configuration/standalone-ha.xml && \
    rm setLogLevel.xsl; \
    rm changeDatabase.xsl; \
    rm setCluster.xsl; \
    rm setHTTPS.xsl; \
    rm saxon9he.jar

#Install mysql jdbc connector
RUN mkdir -p modules/system/layers/base/org/mariadb/jdbc/main; \
    mv module.xml modules/system/layers/base/org/mariadb/jdbc/main/; \
    cd modules/system/layers/base/org/mariadb/jdbc/main/ && \
    curl -O $MAVEN_REPO_URL/org/mariadb/jdbc/mariadb-java-client/2.1.1/mariadb-java-client-2.1.1.jar

EXPOSE 8080 8443

ENTRYPOINT [ "./docker-entrypoint.sh" ]

#CMD ["-b", "0.0.0.0"]
CMD ["-b", "0.0.0.0", "--server-config", "standalone-ha.xml"]

