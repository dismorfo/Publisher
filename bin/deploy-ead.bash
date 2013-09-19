#!/bin/bash

# deploy-ead.bash
# shell script to deploy ead html files from staging to production; also post solr file to solr service

# Read the conf file
. ../conf/eadpublisher.conf

# Die if there is more than one argument
if [ $# -gt 1 ]; then
	echo 1>&2 Usage: $0 EADDIR/EADID or $0
	exit 127
fi

COLL=`expr "$*" : '\(.*/\)' | sed "s/\///"`
FAID=`expr "$*" : '.*\(/.*\)' | sed "s/\///"`

EAD=$CONTENT_STAGING_PATH/ead/$COLL/$FAID.xml
HTML=$CONTENT_STAGING_PATH/html/$COLL/$FAID
INDEX=$CONTENT_STAGING_PATH/html/$COLL/$FAID/index.html
SOLR1S=$CONTENT_STAGING_PATH/solr1/$COLL/$FAID.solr.xml
SOLR2S=$CONTENT_STAGING_PATH/solr2/$COLL/$FAID.solr.xml
URL1=$SOLR1_URI/update
URL2=$SOLR2_URI/update

if [ ! -e $EAD ]; then
    echo Warning: no file exists at $EAD
    exit 1;
fi

if [ ! -d $HTML ]; then
    echo Warning: no directory exists at $HTML
    exit 1;
fi

if [ ! -e $INDEX ]; then
    echo Warning: no file exists at $INDEX
    exit 1;
fi


if [ ! -e $SOLR1S ]; then
    echo Warning: no file exists at $SOLR1S
    exit 1;
fi

if [ ! -e $SOLR2S ]; then
    echo Warning: no file exists at $SOLR2S
    exit 1;
fi

umask 002

# Move the EAD into the published area
mv $EAD $CONTENT_PATH/ead/$COLL/

if [ ! -d $CONTENT_PATH/html/$COLL/$FAID ]; then
  mkdir $CONTENT_PATH/html/$COLL/$FAID
fi

mv -f $HTML/* $CONTENT_PATH/html/$COLL/$FAID/
rm -rf $HTML

for s in $SOLR1S; do
  if [[ ${s} == *${*}* ]]; then
    curl $URL1 --data-binary @$s -H 'Content-type:text/xml; charset=utf-8' 
    echo
  fi
done

# send the commit command to make sure all the changes are flushed and visible
for s in $SOLR2S; do
  if [[ ${s} == *${*}* ]]; then
    curl $URL2 --data-binary @$s -H 'Content-type:text/xml; charset=utf-8' 
    echo
  fi
done

# send the commit command to make sure all the changes are flushed and visible
curl $URL1 --data-binary '<commit/>'
curl $URL2 --data-binary '<commit/>'