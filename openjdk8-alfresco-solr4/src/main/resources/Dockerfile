FROM ${docker.from.id}:${docker.from.version}

# add prepared files that would be too awkward to handle via RUN / sed
COPY initSolr4.sh copyTemplate.sh solr4-logrotate.d solr4-ng.conf prepareSolr4Files.js defaultArtifacts /tmp/
COPY defaultKeystore /tmp/defaultKeystore/

# apply our SOLR 4 default configurations
RUN mv /tmp/solr4-logrotate.d /etc/logrotate.d/alfresco-solr4 \
   && mv /tmp/prepareSolr4Files.js /var/lib/tomcat8/ \
   && mv /tmp/solr4-ng.conf /etc/syslog-ng/conf.d/solr4-ng.conf \
   && mv /tmp/initSolr4.sh /etc/my_init.d/50_initSolr4.sh \
   && chmod +x /etc/my_init.d/50_initSolr4.sh \
   && mkdir -p /srv/alfresco-solr4/modules \
   && mv /tmp/defaultKeystore /srv/alfresco-solr4/ \
   && chmod 600 /srv/alfresco-solr4/defaultKeystore/* \
   && chown -R tomcat8:tomcat8 /srv/alfresco-solr4/defaultKeystore

ARG maven_required_artifacts=
ARG alfresco_solr4_version=6.7
ARG alfresco_solr4_war_artifact=
ARG alfresco_solr4_config_zip_artifact=
ARG maven_active_repositories='[{"id": "alfresco", "baseUrl": "https://artifacts.alfresco.com/nexus/content/groups/public", "user": null, "password": null}, {"id": "alfresco_ee", "baseUrl": "https://artifacts.alfresco.com/nexus/content/groups/private", "user": null, "password": null}, {"id": "central", "baseUrl": "https://repo1.maven.org/maven2", "user": null, "password": null}, {"id": "ossrh", "baseUrl": "https://oss.sonatype.org/content/repositories/snapshots", "user": null, "password": null}]'
ARG jmx_rmi_port=5003

ENV MAVEN_REQUIRED_ARTIFACTS=$maven_required_artifacts
ENV ALFRESCO_SOLR4_VERSION=$alfresco_solr4_version
ENV ALFRESCO_SOLR4_WAR_ARTIFACT=$alfresco_solr4_war_artifact
ENV ALFRESCO_SOLR4_CONFIG_ZIP_ARTIFACT=$alfresco_solr4_config_zip_artifact
ENV MAVEN_ACTIVE_REPOSITORIES=$maven_active_repositories
ENV JMX_RMI_PORT=$jmx_rmi_port

EXPOSE 8080 8081 8082 8083 $jmx_rmi_port

RUN jjs -scripting /var/lib/tomcat8/prepareSolr4Files.js -- /tmp \
   && mkdir -p /srv/alfresco-solr4/solrhome \
   && unzip -qq "/tmp/config.zip" -d /srv/alfresco-solr4/solrhome/ \
   && mv /tmp/*.jar /srv/alfresco-solr4/modules/ || true \
   && mkdir -p /etc/tomcat8/Catalina/localhost \
   && mv /srv/alfresco-solr4/solrhome/context.xml /etc/tomcat8/Catalina/localhost/solr4.xml \
   && sed -i 's/@@ALFRESCO_SOLR4_DIR@@/\/srv\/alfresco-solr4\/solrhome/' /etc/tomcat8/Catalina/localhost/solr4.xml \
   && sed -i 's/@@ALFRESCO_SOLR4_MODEL_DIR@@/\/srv\/alfresco-solr4\/index\/_models/' /etc/tomcat8/Catalina/localhost/solr4.xml \
   && sed -i 's/@@ALFRESCO_SOLR4_CONTENT_DIR@@/\/srv\/alfresco-solr4\/index\/_content/' /etc/tomcat8/Catalina/localhost/solr4.xml \
   && sed -i '/<\/Context>/i <Resources>' /etc/tomcat8/Catalina/localhost/solr4.xml \
   && sed -i '/<\/Context>/i <PostResources base="/srv/alfresco-solr4/modules" className="org.apache.catalina.webresources.DirResourceSet" webAppMount="/WEB-INF/lib" />' /etc/tomcat8/Catalina/localhost/solr4.xml \
   && sed -i '/<\/Context>/i </Resources>' /etc/tomcat8/Catalina/localhost/solr4.xml \
   && sed -i 's/rootLogger=ERROR, file, CONSOLE/rootLogger=ERROR, file/' /srv/alfresco-solr4/solrhome/log4j-solr.properties \
   && sed -i 's/File=solr\.log/File=\${catalina.base}\/logs\/solr.log/' /srv/alfresco-solr4/solrhome/log4j-solr.properties \
   && bash /tmp/copyTemplate.sh \
   && rm -rf /srv/alfresco-solr4/solrhome/workspace-SpacesStore /srv/alfresco-solr4/solrhome/archive-SpacesStore \
   && mkdir -p /srv/alfresco-solr4/index/_content \
   && mkdir -p /srv/alfresco-solr4/index/_models \
   && chown -R tomcat8:tomcat8 /srv/alfresco-solr4/solrhome \
   && chown -R tomcat8:tomcat8 /srv/alfresco-solr4/index \
   && mv /tmp/*.war /var/lib/tomcat8/webapps/ \
   && rm -f /tmp/*.zip /tmp/*.war*

# having SOLR core configurations in an externalised volume is optional - index is expected to be always externalised
# we also support /srv/alfresco-solr4/defaultArtifacts but don't want to force a volume to be auto-created if not bound
VOLUME ["/srv/alfresco-solr4/index", "/srv/alfresco-solr4/coreConfigs", "/srv/alfresco-solr4/keystore"]

LABEL vendor="${docker.labels.vendor}" \
   ${docker.labels.namespace}.version="${project.version.majorVersion}.${project.version.minorVersion}.${project.version.incrementalVersion}" \
   ${docker.labels.namespace}.is-beta="" \
   ${docker.labels.namespace}.is-production="" \
   ${docker.labels.namespace}.release-date="${docker.labels.release-date}" \
   ${docker.labels.namespace}.maintainer="${docker.labels.maintainer}"