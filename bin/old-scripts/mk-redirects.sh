#!/bin/bash

set -x

CONF_FILE=/var/www/sites/findingaids/dev/publisher/conf/eadpublisher.conf

. $CONF_FILE

REDIRECTS=$APP_PATH/apache/findingaid_redirects.conf

exit

for REPO_DIR in $CONTENT_PATH/ead/*
do
	REPOSITORY_DIR=`basename $REPO_DIR`
	pushd $REPO_DIR >/dev/null
	for XML in *.xml
	do
		FILENAME=`echo $XML | sed 's/.xml$//'`
		EADID=`xpath $XML '/ead/eadheader/eadid/text()' 2>/dev/null`
		EADID=`echo $EADID | sed 's/^[ \t]*//;s/[ \t]*$//'`
		if [ -z "$EADID" ]; then
			echo "EADID not set in $XML" 1>&2
			continue
		fi
		OLD_URL_PATH=/findingaids/html/$REPOSITORY_DIR/$FILENAME.html
		NEW_URL=$CONTENT_URI/html/$EADID/
		echo -e "Redirect permanent $OLD_URL_PATH $NEW_URL\n"
	done
	popd >/dev/null
done

