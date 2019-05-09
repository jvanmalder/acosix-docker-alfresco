FROM ${docker.from.id}:${docker.from.version}

# add prepared files that would be too awkward to handle via RUN / sed
COPY share-config-custom.xml share.xml share-logrotate.d initShare.sh prepareWarFiles.js share-ng.conf defaultArtifacts /tmp/

# apply our Alfresco Share default configurations
RUN mv /tmp/share-logrotate.d /etc/logrotate.d/share \
   && mkdir -p /srv/alfresco/config/alfresco/web-extension /srv/alfresco/modules /etc/tomcat8/Catalina/localhost \
   && mv /tmp/share-config-custom.xml /srv/alfresco/config/alfresco/web-extension/ \
   && mv /tmp/share.xml /etc/tomcat8/Catalina/localhost/ \
   && touch /var/lib/tomcat8/logs/.share-logrotate-dummy \
   && mv /tmp/prepareWarFiles.js /var/lib/tomcat8/ \
   && mv /tmp/share-ng.conf /etc/syslog-ng/conf.d/share-ng.conf \
   && mv /tmp/initShare.sh /etc/my_init.d/50_initShare.sh \
   && chmod +x /etc/my_init.d/50_initShare.sh

ARG maven_required_artifacts=
ARG alfresco_mmt_version=6.0
ARG alfresco_share_version=6.0.c
ARG maven_active_repositories='[{"id": "alfresco", "baseUrl": "https://artifacts.alfresco.com/nexus/content/groups/public", "user": null, "password": null}, {"id": "alfresco_ee", "baseUrl": "https://artifacts.alfresco.com/nexus/content/groups/private", "user": null, "password": null}, {"id": "central", "baseUrl": "https://repo1.maven.org/maven2", "user": null, "password": null}, {"id": "ossrh", "baseUrl": "https://oss.sonatype.org/content/repositories/snapshots", "user": null, "password": null}]'
ARG jmx_rmi_port=5002

ENV MAVEN_REQUIRED_ARTIFACTS=$maven_required_artifacts
ENV ALFRESCO_MMT_VERSION=$alfresco_mmt_version
ENV ALFRESCO_SHARE_VERSION=$alfresco_share_version
ENV MAVEN_ACTIVE_REPOSITORIES=$maven_active_repositories
ENV JMX_RMI_PORT=$jmx_rmi_port

EXPOSE 8080 8081 $jmx_rmi_port

# build your custom Share now instead of on first run
RUN jjs -scripting /var/lib/tomcat8/prepareWarFiles.js -- /tmp \
   && mv /tmp/*.war /var/lib/tomcat8/webapps/ \
   && mv /tmp/*.jar /srv/alfresco/modules/ || true \
   && rm -f /tmp/*.jar /tmp/*.amp /tmp/*.war* /tmp/PUT_ARTIFACTS_HERE

# we support /srv/alfresco/keystore and /srv/alfresco/defaultArtifacts but don't want to force a volume to be auto-created if not bound

LABEL vendor="${docker.labels.vendor}" \
   ${docker.labels.namespace}.version="${project.version.majorVersion}.${project.version.minorVersion}.${project.version.incrementalVersion}" \
   ${docker.labels.namespace}.is-beta="" \
   ${docker.labels.namespace}.is-production="" \
   ${docker.labels.namespace}.release-date="${docker.labels.release-date}" \
   ${docker.labels.namespace}.maintainer="${docker.labels.maintainer}"