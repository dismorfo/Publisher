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

# Die if there is more than one argument
if [ $# -gt 1 ]; then
	echo [`date`] 1>&2 Usage: $0 EADID or $0  >> $APP_PATH/log.out
	exit 127
fi

echo [`date`] Open file $SOURCE >> $APP_PATH/log.out

COLL=`expr "$*" : '\(.*/\)' | sed "s/\///"`

FAID=`expr "$*" : '.*\(/.*\)' | sed "s/\///"`

EADS=$CONTENT_STAGING_PATH/ead/$COLL/$FAID.xml

if [[ $COLL == 'nyhs' || $COLL == 'NYHS' ]]; then
   collPage='http://dlib.nyu.edu/affiliates/NYHS/findingaids/'
fi

for e in $EADS; do
  ARCHIVETYPE=`dirname $e | sed "s/\/.*\///"`

  echo [`date`] Writing HTML version for file $e >> $APP_PATH/log.out
  
  echo [`date`] Archive: $ARCHIVETYPE >> $APP_PATH/log.out
  
  newDir=`basename $e | sed "s/\.xml//"`

  # make the html file
  eadid=`grep \<eadid.*\>[_[:alnum:][:space:]]*\</eadid\> $e | sed "s/.*<eadid[^>]*>//" | sed "s/<\/eadid>.*//" | sed "s/[ ]//g"`

  # make sure the file was created by the AT.
  ns_check=`grep urn:isbn:1-931666-22-9 $e`
	
  if [ ! ${#ns_check} -gt 0 ]; then
    echo [`date`] EAD probably not exported from Archivists Toolkit. Exiting. >> $APP_PATH/log.out
    exit
  fi

  echo [`date`] Input EAD: $e >> $APP_PATH/log.out
  
  if [ ${#eadid} -gt 0 ]; then
    transform_output=$(java -jar $SAXON_PATH -s:$e -xsl:$APP_PATH/assets/xsl/ead2html.xsl targetDir=$CONTENT_STAGING_PATH/html/$COLL collectionName=$ARCHIVETYPE searchURI=$SEARCH_URI contentURI=$CONTENT_URI collPage=$collPage 2>&1)
  else
    echo [`date`] No eadid value, no transform >> $APP_PATH/log.out
  fi

  if [[ $transform_output =~ "Error reported by XML" ]]; then
    echo [`date`] $transform_output >> $APP_PATH/log.out
    
  elif [[ $transform_output =~ "java.io.FileNotFoundException:" ]]; then
    echo [`date`] $transform_output >> $APP_PATH/log.out
    
  else
    echo [`date`] $transform_output >> $APP_PATH/log.out
    echo \<eadid\>$eadid\</eadid\>			
  fi
  
  cp "$APP_PATH/files/shared/assets/php/toc.php" "$CONTENT_STAGING_PATH/html/$ARCHIVETYPE/$FAID/toc.php" >> $APP_PATH/log.out
  
done