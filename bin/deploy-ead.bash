#!/bin/bash

# shell script to deploy ead html files from staging to production; also post solr file to solr service

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


echo [`date`] Open file $SOURCE with arguments $* >> $APP_PATH/log.out

if [ $# -gt 1 ]; then # Die if there is more than one argument
  echo 1>&2 Usage: $0 EADID or $0 >> $APP_PATH/log.out
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
  echo Warning: no file exists at $EAD >> $APP_PATH/log.out
  exit 1;
fi

if [ ! -d $HTML ]; then
  echo [`date`] Warning: no directory exists at $HTML >> $APP_PATH/log.out
  exit 1;
fi

if [ ! -e $INDEX ]; then
  echo [`date`] Warning: no file exists at $INDEX >> $APP_PATH/log.out
  exit 1;
fi

if [ ! -e $SOLR1S ]; then
  echo [`date`] Warning: no file exists at $SOLR1S >> $APP_PATH/log.out
  exit 1;
fi

if [ ! -e $SOLR2S ]; then
  echo [`date`] Warning: no file exists at $SOLR2S >> $APP_PATH/log.out
  exit 1;
fi

echo [`date`] Set umask to 002 >> $APP_PATH/log.out
umask 002

# Move the EAD into the published area

if [ ! -d $CONTENT_PATH/ead/$COLL/ ]; then
  echo [`date`] Path $CONTENT_PATH/ead/$COLL/ does not exist >> $APP_PATH/log.out
  mkdir -p $CONTENT_PATH/ead/$COLL
  if [ -d $CONTENT_PATH/ead/$COLL/ ]; then
    echo [`date`] Path $CONTENT_PATH/ead/$COLL/ is now available >> $APP_PATH/log.out
  fi  
fi

echo [`date`] Attempting to move EAD $EAD into the published area $CONTENT_PATH/ead/$COLL/ >> $APP_PATH/log.out

mv $EAD $CONTENT_PATH/ead/$COLL/

# test if file is in prod path
if [ ! -d $CONTENT_PATH/ead/$COLL/$EAD ]; then
  echo [`date`] $EAD is now in published area $CONTENT_PATH/ead/$COLL/$EAD >> $APP_PATH/log.out
fi

if [ ! -d $CONTENT_PATH/html/$COLL/$FAID ]; 
  then
    echo [`date`] Path $CONTENT_PATH/html/$COLL/$FAID does not exist >> $APP_PATH/log.out
    mkdir -p $CONTENT_PATH/html/$COLL/$FAID
  
    if [-d $CONTENT_PATH/html/$COLL/$FAID ];
      then
        # Folder is now available
        echo [`date`] Path $CONTENT_PATH/html/$COLL/$FAID is now available >> $APP_PATH/log.out  
    else
      # Service can't create folder
      echo [`date`] Fail to create path $CONTENT_PATH/html/$COLL/$FAID >> $APP_PATH/log.out
      # Fail and flag error
      # exit 1;
    fi
fi

echo [`date`] Attempting to move files inside $HTML into the published area $CONTENT_PATH/html/$COLL/$FAID/ >> $APP_PATH/log.out
mv -f $HTML/* $CONTENT_PATH/html/$COLL/$FAID/

rm -rf $HTML

for s in $SOLR1S; do
  if [[ ${s} == *${*}* ]]; then
    
    echo [`date`] Sent $SOLR1S to $URL1 >> $APP_PATH/log.out  
    curl $URL1 --data-binary @$s -H 'Content-type:text/xml; charset=utf-8' >> $APP_PATH/log.out
    
    # send the commit command to make sure all the changes are flushed and visible
    # curl "$URL1?softCommit=true" --data-binary '<commit/>' -H 'Content-type:text/xml; charset=utf-8' >> $APP_PATH/log.out
    curl "$URL1" --data-binary '<commit/>' -H 'Content-type:text/xml; charset=utf-8' >> $APP_PATH/log.out
        
  fi
done

# send the commit command to make sure all the changes are flushed and visible
for s in $SOLR2S; do
  if [[ ${s} == *${*}* ]]; then
    
    echo [`date`] Sent $SOLR2S to $URL2 >> $APP_PATH/log.out
    curl $URL2 --data-binary @$s -H 'Content-type:text/xml; charset=utf-8' >> $APP_PATH/log.out
        
    # send the commit command to make sure all the changes are flushed and visible
    # curl "$URL2" --data-binary '<commit/>' -H 'Content-type:text/xml; charset=utf-8' >> $APP_PATH/log.out
    curl "$URL2?softCommit=true" --data-binary '<commit/>' -H 'Content-type:text/xml; charset=utf-8' >> $APP_PATH/log.out
    
  fi
done

echo [`date`] Close file $SOURCE >> $APP_PATH/log.out

exit 0