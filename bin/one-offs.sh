#!/bin/bash

. ../conf/eadpublisher.conf

# create the outward-facing index page for dlib finding aids
java -jar /usr/local/saxon/saxon8.jar -s ../conf/fa.xml ../xsl/2faIndex.xsl CONTENT_URI=$CONTENT_URI CONTENT_PATH=$CONTENT_PATH SOLR1_URI=$SOLR1_URI
