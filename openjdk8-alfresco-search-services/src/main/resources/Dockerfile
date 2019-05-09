FROM ${docker.from.id}:${docker.from.version}

# add prepared files that would be too awkward to handle via RUN / sed
COPY downloadASS.js initASS.sh startASS.sh ASS-logrotate.d ass-ng.conf defaultArtifacts /tmp/

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

ARG alfresco_ass_version=1.2.1
ARG alfresco_ass_artifact=
ARG maven_active_repositories='[{"id": "alfresco", "baseUrl": "https://artifacts.alfresco.com/nexus/content/groups/public", "user": null, "password": null}, {"id": "alfresco_ee", "baseUrl": "https://artifacts.alfresco.com/nexus/content/groups/private", "user": null, "password": null}, {"id": "central", "baseUrl": "https://repo1.maven.org/maven2", "user": null, "password": null}, {"id": "ossrh", "baseUrl": "https://oss.sonatype.org/content/repositories/snapshots", "user": null, "password": null}]'
ARG rmi_port=5003

ENV ALFRESCO_ASS_VERSION=$alfresco_ass_version
ENV ALFRESCO_ASS_ARTIFACT=$alfresco_ass_artifact
ENV MAVEN_ACTIVE_REPOSITORIES=$maven_active_repositories
ENV RMI_PORT=$rmi_port

EXPOSE 8983 $rmi_port

# build your custom ASS now instead of on first run
RUN jjs -scripting /srv/alfresco-search-services/downloadASS.js -- /tmp \
   && unzip -qq "/tmp/alfresco-search-services-*.zip" -d /var/lib/ \
   && rm -rf /tmp/alfresco-search-services-*.zip \
   && sed -i 's/^#SOLR_HOME=/SOLR_HOME=\/srv\/alfresco-search-services\/solrhome/' /var/lib/alfresco-search-services/solr.in.sh \
   && sed -i 's/^SOLR_LOGS_DIR=.*/SOLR_LOGS_DIR=\/var\/log\/alfresco-search-services/' /var/lib/alfresco-search-services/solr.in.sh \
   && sed -i 's/^LOG4J_PROPS=.*/LOG4J_PROPS=\/var\/lib\/alfresco-search-services\/logs\/log4j.properties/' /var/lib/alfresco-search-services/solr.in.sh \
   && sed -i '/-remove_old_solr_logs/d' /var/lib/alfresco-search-services/solr/bin/solr \
   && sed -i '/-archive_gc_logs/d' /var/lib/alfresco-search-services/solr/bin/solr \
   && sed -i '/-archive_console_logs/d' /var/lib/alfresco-search-services/solr/bin/solr \
   && sed -i '/-rotate_solr_logs/ a echo "Removed log rotation handling"' /var/lib/alfresco-search-services/solr/bin/solr \
   && sed -i '/-rotate_solr_logs/d' /var/lib/alfresco-search-services/solr/bin/solr \
   && sed -i '/set that as the rmi server hostname/,/fi/ s/SOLR_HOST/JMX_HOST/' /var/lib/alfresco-search-services/solr/bin/solr \
   && sed -i 's/rootLogger=WARN, file, CONSOLE/rootLogger=WARN, file/' /var/lib/alfresco-search-services/logs/log4j.properties \
   && sed -i 's/\.RollingFileAppender$/.DailyRollingFileAppender/' /var/lib/alfresco-search-services/logs/log4j.properties \
   && sed -i 's/MaxFileSize=4MB$/DatePattern='.'yyyy-MM-dd/' /var/lib/alfresco-search-services/logs/log4j.properties \
   && sed -i 's/MaxBackupIndex=9$/Append=true/' /var/lib/alfresco-search-services/logs/log4j.properties \
   && sed -i 's/yyyy-MM-dd HH:mm:ss.SSS/ISO8601/' /var/lib/alfresco-search-services/logs/log4j.properties \
   && mkdir -p /srv/alfresco-search-services/solrhome /srv/alfresco-search-services/contentstore /var/log/alfresco-search-services \
   && mv /var/lib/alfresco-search-services/solrhome/* /srv/alfresco-search-services/solrhome/ \
   && rm -rf /var/lib/alfresco-search-services/solr/docs /var/lib/alfresco-search-services/solrhome \
   && chown -R ass:ass /var/lib/alfresco-search-services /srv/alfresco-search-services/solrhome /srv/alfresco-search-services/contentstore /var/log/alfresco-search-services \
   && echo "#JMX_HOST=" >> /var/lib/alfresco-search-services/solr.in.sh

# having SOLR core configurations in an externalised volume is optional - index is expected to be always externalised
# we also support /srv/alfresco-search-services/defaultArtifacts but don't want to force a volume to be auto-created if not bound
VOLUME ["/srv/alfresco-search-services/index", "/srv/alfresco-search-services/coreConfigs"]

LABEL vendor="${docker.labels.vendor}" \
   ${docker.labels.namespace}.version="${project.version.majorVersion}.${project.version.minorVersion}.${project.version.incrementalVersion}" \
   ${docker.labels.namespace}.is-beta="" \
   ${docker.labels.namespace}.is-production="" \
   ${docker.labels.namespace}.release-date="${docker.labels.release-date}" \
   ${docker.labels.namespace}.maintainer="${docker.labels.maintainer}"