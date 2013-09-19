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
	echo 1>&2 Usage: $0 EADID or $0
	exit 127
fi

echo Executing file $SOURCE >> $APP_PATH/log.out

COLL=`expr "$*" : '\(.*/\)' | sed "s/\///"`

FAID=`expr "$*" : '.*\(/.*\)' | sed "s/\///"`

EADS=$CONTENT_STAGING_PATH/ead/$COLL/$FAID.xml

if [[ $COLL == 'nyhs' || $COLL == 'NYHS' ]]; then
   collPage='http://dlib.nyu.edu/affiliates/NYHS/findingaids/'
fi

for e in $EADS; do
  ARCHIVETYPE=`dirname $e | sed "s/\/.*\///"`

  echo Writing HTML version for file $e >> $APP_PATH/log.out
  
  echo archive: $ARCHIVETYPE >> $APP_PATH/log.out
  
  # echo Running: copping $APP_PATH/files/shared/assets/php/toc.php $CONTENT_STAGING_PATH/html/$ARCHIVETYPE/$FAID/toc.php >> $APP_PATH/log.out
  	
  newDir=`basename $e | sed "s/\.xml//"`

  # make the html file
  eadid=`grep \<eadid.*\>[_[:alnum:][:space:]]*\</eadid\> $e | sed "s/.*<eadid[^>]*>//" | sed "s/<\/eadid>.*//" | sed "s/[ ]//g"`

  # make sure the file was created by the AT.
  ns_check=`grep urn:isbn:1-931666-22-9 $e`
	
  if [ ! ${#ns_check} -gt 0 ]; then
    echo "EAD probably not exported from Archivists Toolkit. Exiting"
    exit
  fi

  echo Input EAD: $e
  
  echo Saxon Path: $SAXON_PATH

  if [ ${#eadid} -gt 0 ]; then
    transform_output=$(java -jar $SAXON_PATH -s:$e -xsl:$APP_PATH/xsl/ead2html.xsl targetDir=$CONTENT_STAGING_PATH/html/$COLL collectionName=$ARCHIVETYPE searchURI=$SEARCH_URI contentURI=$CONTENT_URI collPage=$collPage 2>&1)
  else
    echo "No <eadid> value, no transform"
  fi

  if [[ $transform_output =~ "Error reported by XML" ]]; then
    echo $transform_output
  elif [[ $transform_output =~ "java.io.FileNotFoundException:" ]]; then
    echo $transform_output
  else
    echo $transform_output
    echo \<eadid\>$eadid\</eadid\>			
  fi
  
  cp "$APP_PATH/files/shared/assets/php/toc.php" "$CONTENT_STAGING_PATH/html/$ARCHIVETYPE/$FAID/toc.php" >> $APP_PATH/log.out
  
  
done