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

SOLR1=$CONTENT_STAGING_PATH/solr1/$COLL/$FAID.solr.xml

SOLR2=$CONTENT_STAGING_PATH/solr2/$COLL/$FAID.solr.xml

echo [`date`] Open file $SOURCE with arguments $* >> $APP_PATH/log.out

echo [`date`] Delete EAD file $EAD >> $APP_PATH/log.out
rm $EAD

echo [`date`] Delete HTML folder $HTML >> $APP_PATH/log.out
rm -rf $HTML

echo [`date`] Delete Solr 1 file $SOLR1 >> $APP_PATH/log.out
rm $SOLR1S

echo [`date`] Delete Solr 2 file $SOLR2 >> $APP_PATH/log.out
rm $SOLR2S

echo [`date`] Close file $SOURCE >> $APP_PATH/log.out