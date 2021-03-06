FROM ${docker.from.id}:${docker.from.version}

# add prepared files that would be too awkward to handle via RUN / sed
COPY downloadASS.js initASS.sh startASS.sh ASS-logrotate.d ass-ng.conf /tmp/

RUN groupadd -g 12001 ass \
   && useradd -s /bin/false -g ass -u 12001 -M ass \
   && mkdir -p /srv/alfresco-search-services \
   && mv /tmp/downloadASS.js /srv/alfresco-search-services/ \ 
   && mv /tmp/ASS-logrotate.d /etc/logrotate.d/alfresco-search-services \
   && mv /tmp/ass-ng.conf /etc/syslog-ng/conf.d/ass-ng.conf \
   && mkdir -p /etc/my_init.d \
   && mv /tmp/initASS.sh /etc/my_init.d/20_initAlfrescoSearchServices.sh \
   && chmod +x /etc/my_init.d/20_initAlfrescoSearchServices.sh \
   && mkdir /etc/service/alfresco-search-services \
   && mv /tmp/startASS.sh /etc/service/alfresco-search-services/run \
   && chmod +x /etc/service/alfresco-search-services/run \
   && chown -R ass:ass /srv/alfresco-search-services

ENV ALFRESCO_ASS_VERSION=1.2.1 \
   ALFRESCO_ASS_ARTIFACT= \
   MAVEN_ACTIVE_REPOSITORIES=alfresco,alfresco_ee,central,ossrh \
   MAVEN_REPOSITORIES_central_URL=https://repo1.maven.org/maven2 \
   MAVEN_REPOSITORIES_alfresco_URL=https://artifacts.alfresco.com/nexus/content/groups/public \
   MAVEN_REPOSITORIES_alfresco_ee_URL=https://artifacts.alfresco.com/nexus/content/groups/private \
   MAVEN_REPOSITORIES_ossrh_URL=https://oss.sonatype.org/content/repositories/snapshots \
   RMI_PORT=5003

EXPOSE 8983 5003

# having SOLR core configurations in an externalised volume is optional - index is expected to be always externalised
# we also support /srv/alfresco-search-services/defaultArtifacts but don't want to force a volume to be auto-created if not bound
VOLUME ["/srv/alfresco-search-services/index", "/srv/alfresco-search-services/coreConfigs"]

LABEL vendor="${docker.labels.vendor}" \
   ${docker.labels.namespace}.version="${project.version.majorVersion}.${project.version.minorVersion}.${project.version.incrementalVersion}" \
   ${docker.labels.namespace}.is-beta="" \
   ${docker.labels.namespace}.is-production="" \
   ${docker.labels.namespace}.release-date="${docker.labels.release-date}" \
   ${docker.labels.namespace}.maintainer="${docker.labels.maintainer}"