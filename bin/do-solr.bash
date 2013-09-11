#!/bin/bash

. ../conf/eadpublisher.conf

# Die if there is more than one argument
if [ $# -gt 1 ]; then
	echo 1>&2 Usage: $0 EADID or $0
	exit 127
fi

COLL=`expr "$*" : '\(.*/\)' | sed "s/\///"`
FAID=`expr "$*" : '.*\(/.*\)' | sed "s/\///"`

EADS=$CONTENT_STAGING_PATH/ead/$COLL/$FAID.xml

for e in $EADS; do
  	ARCHIVETYPE=`dirname $e | sed "s/\/.*\///"`
  	eadid=`grep \<eadid.*\>[_[:alnum:]]*\</eadid\> $e | sed "s/.*<eadid[^>]*>//" | sed "s/<\/eadid>.*//"`
#		solrFile=`basename $e | sed "s/\.xml/\.solr\.xml/"`
    solrFile="$eadid.solr.xml"
#		htmlFile=`basename $e | sed "s/\.xml/\.html/"`
#		contentFile=`basename $e | sed "s/\.xml/_content.html/"`
#		echo $contentFile
		# make the file for solr
		echo Writing solr index file for $e
		echo Saxon Path: $SAXON_PATH 
		# eventually the uri should be a pid returned by the pid manager
		#SOLR 1
  		  transform_output_1=$(java -jar $SAXON_PATH -s:$e -o:$CONTENT_STAGING_PATH/solr1/$ARCHIVETYPE/$solrFile -xsl:$APP_PATH/xsl/write4solr.xsl collectionName=$ARCHIVETYPE sourceFilename=`basename $e` uri=$CONTENT_URI/html/$ARCHIVETYPE/$eadid eadMode=inter)
		#SOLR 2
  		  transform_output_2=$(java -jar $SAXON_PATH -s:$e -o:$CONTENT_STAGING_PATH/solr2/$ARCHIVETYPE/$solrFile -xsl:$APP_PATH/xsl/write4solr.xsl collectionName=$ARCHIVETYPE sourceFilename=`basename $e` uri=$CONTENT_URI/html/$ARCHIVETYPE/$eadid eadMode=intra)
    if [[ $tranform_output_1 =~ "Error reported by XML" ]]; then
        echo $transform_output_1
    elif [[ $transform_output_2 =~ "Error reorted by XML" ]]; then
        echo $transform_output_2
    else
        echo \<solrFile\>$solrFile\</solrFile\>
    fi

done

