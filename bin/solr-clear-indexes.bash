#!/bin/bash

# deploy-ead.bash
# shell script to deploy ead html files from staging to production; also post solr file to solr service

# Read the conf file
. ../conf/eadpublisher.conf



# Die if there is one or more argument
if [ $# -gt 0 ]; then
	echo 1>&2 Usage: This script takes no arguments.
	exit 127
fi


URL1=$SOLR1_URI/update
URL2=$SOLR2_URI/update

SOLR1COM="<delete><query>*:*</query></delete>"
SOLR2COM="<delete><query>*:*</query></delete>"

curl $URL1 --data-binary $SOLR1COM
echo
curl $URL1 --data-binary '<commit/>'

curl $URL2 --data-binary $SOLR2COM
echo
#send the commit command to make sure all the changes are flushed and visible
curl $URL2 --data-binary '<commit/>'



