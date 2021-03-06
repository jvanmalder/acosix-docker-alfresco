FROM ${docker.from.id}:${docker.from.version}

# Add local transformation tooling
RUN install_clean \
    build-essential \
    autoconf \
    automake \
    autopoint \
    chrpath \
    debhelper \
    dh-autoreconf \
    dh-strip-nondeterminism \
    libfile-stripnondeterminism-perl \
    m4 \
    po-debconf \
    libclang1-7 \
    libsigsegv2 \
    doxygen \
    libbz2-1.0 \
    libbz2-dev \
    libdjvulibre21 \
    libdjvulibre-dev \
    libexif12 \    
    libexif-dev \
    libfftw3-3 \
    libfftw3-dev \
    libfontconfig1 \
    libfontconfig1-dev \
    libfreetype6 \
    libfreetype6-dev \
    libgdk-pixbuf2.0-0 \
    libgdk-pixbuf2.0-dev \
    libglib2.0-0 \
    libglib2.0-dev \
    libharfbuzz0b \
    libharfbuzz-dev \
    libharfbuzz-gobject0 \
    libjbig0 \
    libjbig-dev \
    libjpeg8 \
    libjpeg8-dev \
    liblcms2-2 \
    liblcms2-dev \
    liblqr-1-0 \
    liblqr-1-0-dev \
    liblzma5 \
    liblzma-dev \
    libobjc4 \
    libobjc-5-dev \
    libpng16-16 \
    libpng-dev \
    libpotrace0 \
    libpthread-stubs0-dev \
    libtiffxx5 \
    libtiff5-dev \
    libwmf-bin \
    libwmf-dev \
    libzzip-0-13 \
    libzzip-dev \
    zlib1g \
    zlib1g-dev \
    libopenjp2-7 \
    libopenjp2-7-dev \
  && wget -O /tmp/ImageMagick.tar.gz https://www.imagemagick.org/download/ImageMagick-${imagemagick.version}.tar.gz \
  && cd /tmp \
  && tar xzf /tmp/ImageMagick.tar.gz \
  && cd /tmp/ImageMagick-${imagemagick.version} \
  && ./configure --prefix=/var/lib/ImageMagick-${imagemagick.version} --with-x=no \
  && make \
  && make install \
  && cd / \
  && rm -rf /tmp/ImageMagick-${imagemagick.version} /tmp/ImageMagick.tar.gz \
  && apt-get autoremove -y \
    build-essential \
    autoconf \
    automake \
    autopoint \
    chrpath \
    debhelper \
    dh-autoreconf \
    dh-strip-nondeterminism \
    libfile-stripnondeterminism-perl \
    m4 \
    po-debconf \
    doxygen \
    libbz2-dev \
    libdjvulibre-dev \
    libexif-dev \
    libfftw3-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libgdk-pixbuf2.0-dev \
    libglib2.0-dev \
    libharfbuzz-dev \
    libjbig-dev \
    libjpeg8-dev \
    liblcms2-dev \
    liblqr-1-0-dev \
    liblzma-dev \
    libobjc-5-dev \
    libpng-dev \
    libtiff5-dev \
    libwmf-dev \
    zlib1g-dev \
    libzzip-dev \
    libopenjp2-7-dev

RUN wget -O /tmp/wkhtmltox.deb https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb \
   && install_clean \
     fontconfig \
     xfonts-75dpi \
     xfonts-base \
     libjpeg8 \
     libx11-6 \
     libxcb1 \
     libxext6 \
     libxrender1 \
   && apt install -y /tmp/wkhtmltox.deb \
   && rm /tmp/wkhtmltox.deb

# add Alfresco PDF Renderer
COPY *.tgz /tmp/
RUN tar xzf /tmp/alfresco-pdf-renderer-*-linux.tgz \
   && mv alfresco-pdf-renderer /usr/bin/ \
   && rm /tmp/alfresco-pdf-renderer-*-linux.tgz \
   && chmod 755 /usr/bin/alfresco-pdf-renderer

# add prepared files that would be too awkward to handle via RUN / sed
COPY *.jar alfresco.xml alfresco-logrotate.d initAlfresco.sh prepareWarFiles.js alfresco-ng.conf repository-config defaultArtifacts /tmp/

# apply our Alfresco Repository default configurations
RUN mkdir -p /srv/alfresco/config /srv/alfresco/modules /etc/tomcat8/Catalina/localhost \
   && mv /tmp/*.jar /srv/alfresco/modules/ \
   && mv /tmp/alfresco-global.properties /srv/alfresco/config/ \
   && mv /tmp/alfresco /srv/alfresco/config/ \
   && find /srv/alfresco/config -type d -exec chmod +x '{}' \; \
   && mv /tmp/alfresco.xml /etc/tomcat8/Catalina/localhost/ \
   && mv /tmp/alfresco-logrotate.d /etc/logrotate.d/alfresco \
   && touch /var/lib/tomcat8/logs/.alfresco-logrotate-dummy \
   && mv /tmp/prepareWarFiles.js /var/lib/tomcat8/ \
   && chown -R tomcat8:tomcat8 /srv/alfresco \
   && mv /tmp/alfresco-ng.conf /etc/syslog-ng/conf.d/alfresco-ng.conf \
   && mv /tmp/initAlfresco.sh /etc/my_init.d/50_initAlfresco.sh \
   && chmod +x /etc/my_init.d/50_initAlfresco.sh

# Public HTTP ports for reverse-proxy: 8080 / 8081 (assumed secured via SSL)
# Private HTTP ports for SOLR: 8082 / 8083 (active SSL)
# JMX / RMI port: 5001 (aligned with SOLR + Share images so that each havea a distinct port - it's hard to forward JMX / RMI otherwise due JVM having to know the public port you're exposing via Docker)
# Various protocol ports: 10025 (inboundSMTP) / 10445,10137-10139 (CIFS/SMB) / 10021 FTP (active) / 11000-11099 FTP (passive)
EXPOSE 8080 8081 8082 8083 5001 10445 10137-10139 10025 10021 11000-11099

# we also support /srv/alfresco/keystore and /srv/alfresco/defaultArtifacts but don't want to force a volume to be auto-created if not bound
VOLUME ["/srv/alfresco/data"]

ARG maven_required_artifacts='org.orderofthebee.support-tools:support-tools-repo:amp:1.0.0.0,de.fmaul:javascript-console-repo:amp:0.6'
ARG alfresco_platform_version=6.1.2-ga
ARG alfresco_api_explorer_version=6.0.7-ga
ARG alfresco_mmt_version=6.0
ARG alfresco_root_version=6.0.1
ARG alfresco_aos_version=1.2.2
ARG alfresco_vti_bin_version=1.2.2
ARG alfresco_share_services_version=6.0.c
ARG alfresco_platform_war_artifact=
ARG alfresco_platform_root_war_artifact=
ARG maven_active_repositories='[{"id": "alfresco", "baseUrl": "https://artifacts.alfresco.com/nexus/content/groups/public", "user": null, "password": null}, {"id": "alfresco_ee", "baseUrl": "https://artifacts.alfresco.com/nexus/content/groups/private", "user": null, "password": null}, {"id": "central", "baseUrl": "https://repo1.maven.org/maven2", "user": null, "password": null}, {"id": "ossrh", "baseUrl": "https://oss.sonatype.org/content/repositories/snapshots", "user": null, "password": null}]'
ARG jmx_rmi_port=5001
ARG install_aos=true
ARG install_share_services=true
ARG install_api_explorer=true

ENV MAVEN_REQUIRED_ARTIFACTS=$maven_required_artifacts
ENV ALFRESCO_PLATFORM_VERSION=$alfresco_platform_version
ENV ALFRESCO_API_EXPLORER_VERSION=$alfresco_api_explorer_version
ENV ALFRESCO_MMT_VERSION=$alfresco_mmt_version
ENV ALFRESCO_ROOT_VERSION=$alfresco_root_version
ENV ALFRESCO_AOS_VERSION=$alfresco_aos_version
ENV ALFRESCO_VTI_BIN_VERSION=$alfresco_vti_bin_version
ENV ALFRESCO_SHARE_SERVICES_VERSION=$alfresco_share_services_version
ENV ALFRESCO_PLATFORM_WAR_ARTIFACT=$alfresco_platform_war_artifact
ENV ALFRESCO_PLATFORM_ROOT_WAR_ARTIFACT=$alfresco_platform_root_war_artifact
ENV MAVEN_ACTIVE_REPOSITORIES=$maven_active_repositories
ENV INSTALL_AOS=$install_aos
ENV INSTALL_SHARE_SERVICES=$install_share_services
ENV INSTALL_API_EXPLORER=$install_api_explorer
ENV JMX_RMI_PORT=$jmx_rmi_port

# build your custom Alfresco now instead of on first run
RUN jjs -scripting /var/lib/tomcat8/prepareWarFiles.js -- /tmp \
   && mv /tmp/*.war /var/lib/tomcat8/webapps/ \
   && mv /tmp/*.jar /srv/alfresco/modules/ || true \
   && rm -f /tmp/*.jar /tmp/*.amp /tmp/*.war* /tmp/PUT_ARTIFACTS_HERE

LABEL vendor="${docker.labels.vendor}" \
   ${docker.labels.namespace}.version="${project.version.majorVersion}.${project.version.minorVersion}.${project.version.incrementalVersion}" \
   ${docker.labels.namespace}.is-beta="" \
   ${docker.labels.namespace}.is-production="" \
   ${docker.labels.namespace}.release-date="${docker.labels.release-date}" \
   ${docker.labels.namespace}.maintainer="${docker.labels.maintainer}"
