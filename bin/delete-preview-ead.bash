#!/bin/bash

# find the path of this file
SOURCE="${BASH_SOURCE[0]}"

# resolve $SOURCE until the file is no longer a symlink
while [ -h "$SOURCE" ]; do
  
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  
  SOURCE="$(readlink "$SOURCE")"
  
  # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"

done

DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

PARENT_DIR="$(dirname "$DIR")"

# Add Publisher configurations
. $PARENT_DIR/conf/eadpublisher.conf

# Die if there is more than one argument
if [ $# -gt 1 ]; then
  echo 1>&2 Usage: $0 EADID or $0
  exit 127 
fi

COLL=`expr "$*" : '\(.*/\)' | sed "s/\///"`
FAID=`expr "$*" : '.*\(/.*\)' | sed "s/\///"`
EAD=$CONTENT_STAGING_PATH/ead/$COLL/$FAID.xml
HTML=$CONTENT_STAGING_PATH/html/$COLL/$FAID
SOLR1S=$CONTENT_STAGING_PATH/solr1/$COLL/$FAID.solr.xml
SOLR2S=$CONTENT_STAGING_PATH/solr2/$COLL/$FAID.solr.xml

echo Removing EAD file \($FAID.xml\) from $EAD >> $APP_PATH/log.out
rm $EAD

echo Removing $FAID HTML folder \($HTM\) >> $APP_PATH/log.out
rm -rf $HTML

echo Removing $FAID Solr 1 \($SOLR1\) >> $APP_PATH/log.out
rm $SOLR1S

echo Removing $FAID Solr 2 \($SOLR2\) >> $APP_PATH/log.out
rm $SOLR2S