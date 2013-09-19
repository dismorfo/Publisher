#!/bin/bash

# find the path of this file

SOURCE="${BASH_SOURCE[0]}"

while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

PARENT_DIR="$(dirname "$DIR")"

# Add Publisher configurations
. $PARENT_DIR/conf/eadpublisher.conf

if [ $# -gt 1 ]; then # Die if there is more than one argument
  echo 1>&2 Usage: $0 EADID or $0
  exit 127 
fi

COLL=`expr "$*" : '\(.*/\)' | sed "s/\///"`

FAID=`expr "$*" : '.*\(/.*\)' | sed "s/\///"`

SOLRID=`expr "$*" | sed "s/\//_/"`

EAD=$CONTENT_PATH/ead/$COLL/$FAID.xml
HTML=$CONTENT_PATH/html/$COLL/$FAID.html
IFRAME=$CONTENT_PATH/html/$COLL/${FAID}_content.html
TOC=$CONTENT_PATH/html/$COLL/${FAID}_toc.html

SOLR1S=$CONTENT_STAGING_PATH/solr1/$COLL/$FAID.solr.xml
SOLR2S=$CONTENT_STAGING_PATH/solr2/$COLL/$FAID.solr.xml

URL1=$SOLR1_URI/update
URL2=$SOLR2_URI/update

`rm $EAD`

`rm $HTML`

`rm $IFRAME`

`rm $TOC`

`rm $SOLR1S`

`rm $SOLR2S`


SOLR1COM="<delete><id>${SOLRID}</id></delete>"

SOLR2COM="<delete><query>id:${SOLRID}*</query></delete>"

echo $SOLR2COM

for s in $SOLR1S; do
	if [[ ${s} == *${*}* ]]; then
	    echo $SOLRID
		curl $URL1 --data-binary $SOLR1COM
	  	echo
	fi
done

# send the commit command to make sure all the changes are flushed and visible
curl $URL1 --data-binary '<commit/>'

for s in $SOLR2S; do
	if [[ ${s} == *${*}* ]]; then
		curl $URL2 --data-binary $SOLR2COM
	  	echo
	fi
done

# send the commit command to make sure all the changes are flushed and visible
curl $URL2 --data-binary '<commit/>'