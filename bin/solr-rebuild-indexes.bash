#!/bin/bash

# reload-solr-indexes.bash
# Repost all the files in $CONTENT_STAGING_PATH/solr* to the Solr indexes

# Read the conf file
. ../conf/eadpublisher.conf


SOLR1_DIR=$CONTENT_STAGING_PATH/solr1
SOLR2_DIR=$CONTENT_STAGING_PATH/solr2

URL1=$SOLR1_URI/update
URL2=$SOLR2_URI/update


for s in $SOLR1_DIR/*/*; do
	if [[ ${s} == *${*}* ]]; then
		curl $URL1 --data-binary @$s -H 'Content-type:application/xml; charset=utf-8' 
	  	echo
	fi
done

#send the commit command to make sure all the changes are flushed and visible
curl $URL1 --data-binary '<commit/>' -H 'Content-type:application/xml'

for s in $SOLR2_DIR/*/*; do
	if [[ ${s} == *${*}* ]]; then
		curl $URL2 --data-binary @$s -H 'Content-type:application/xml; charset=utf-8' 
	  	echo
	fi
done

#send the commit command to make sure all the changes are flushed and visible
curl $URL2 --data-binary '<commit/>' -H 'Content-type:application/xml'

