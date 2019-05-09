#!/bin/bash

if [[ -z "$(ls -A /srv/alfresco-solr4/solrhome/templates/rerank)" && -z "$(ls -A /srv/alfresco-solr4/solrhome/templates/vanilla)" ]]
then
    # old SOLR 4 version may not provide any templates
    echo "SOLR 4 version does not provide usable core templates - using default workspace-SpacesStore config as vanilla template"
    mv /srv/alfresco-solr4/solrhome/workspace-SpacesStore /srv/alfresco-solr4/solrhome/templates/vanilla
    rm /srv/alfresco-solr4/solrhome/templates/vanilla/core.properties
fi