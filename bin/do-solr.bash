# find the path of this file

SOURCE="${BASH_SOURCE[0]}"

while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

PARENT_DIR="$(dirname "$DIR")"

. $PARENT_DIR/conf/eadpublisher.conf # Add Publisher configurations

if [ $# -gt 1 ]; then # Die if there is more than one argument
	echo 1>&2 Usage: $0 EADID or $0
	exit 127 
fi

COLL=`expr "$*" : '\(.*/\)' | sed "s/\///"`

FAID=`expr "$*" : '.*\(/.*\)' | sed "s/\///"`

echo Executing file $SOURCE with argument $COLL and $FAID >> $APP_PATH/log.out

EADS=$CONTENT_STAGING_PATH/ead/$COLL/$FAID.xml

for e in $EADS; do

  	ARCHIVETYPE=`dirname $e | sed "s/\/.*\///"`

  	eadid=`grep \<eadid.*\>[_[:alnum:]]*\</eadid\> $e | sed "s/.*<eadid[^>]*>//" | sed "s/<\/eadid>.*//"`

    solrFile="$eadid.solr.xml"

    # make the file for solr
    echo Writing solr index file for $e >> $APP_PATH/log.out

    echo Saxon Path: $SAXON_PATH 
    # eventually the uri should be a pid returned by the pid manager
    
    # SOLR 1
    transform_output_1=$(java -jar $SAXON_PATH -s:$e -o:$CONTENT_STAGING_PATH/solr1/$ARCHIVETYPE/$solrFile -xsl:$APP_PATH/xsl/write4solr.xsl collectionName=$ARCHIVETYPE sourceFilename=`basename $e` uri=$CONTENT_URI/html/$ARCHIVETYPE/$eadid eadMode=inter)
	
	echo Solr 1: Attempting to transform $e into $solrFile >> $APP_PATH/log.out
	
	echo $transform_output_1 >> $APP_PATH/log.out
	
	# SOLR 2
    transform_output_2=$(java -jar $SAXON_PATH -s:$e -o:$CONTENT_STAGING_PATH/solr2/$ARCHIVETYPE/$solrFile -xsl:$APP_PATH/xsl/write4solr.xsl collectionName=$ARCHIVETYPE sourceFilename=`basename $e` uri=$CONTENT_URI/html/$ARCHIVETYPE/$eadid eadMode=intra)
    
	echo Solr 2: Attempting to transform $e into $solrFile >> $APP_PATH/log.out
	
	echo $transform_output_2 >> $APP_PATH/log.out

    if [[ $tranform_output_1 =~ "Error reported by XML" ]]; then
      echo SOLR 1: Unable to transformed $e into $solrFile >> $APP_PATH/log.out
    elif [[ $transform_output_2 =~ "Error reorted by XML" ]]; then
      echo SOLR 2: Unable to transformed $e into $solrFile >> $APP_PATH/log.out
    else
      echo SOLR 1: $e was successfully transformed into $SOLR1_HOME/$COLL/$solrFile >> $APP_PATH/log.out
      echo SOLR 2: $e was successfully transformed into $SOLR2_HOME/$COLL/$solrFile >> $APP_PATH/log.out
      echo \<solrFile\>$solrFile\</solrFile\>
    fi

done