#!/bin/bash

# deploy-ead.bash
# shell script to deploy ead html files from staging to production; also post solr file to solr service

# Read the conf file
. ../conf/eadpublisher.conf

# Die if there is more than one argument
if [ $# -gt 1 ]; then
	echo 1>&2 Usage: $0 EADID or $0
	exit 127
fi

# Do All if no argument
if [$# -gt 0 ]; then
	$* = "*/*"
fi

COLL=`expr "$*" : '\(.*/\)' | sed "s/\///"`
FILEID=`expr "$*" : '.*\(/.*\)' | sed "s/\///"`

EAD_DIR=$CONTENT_PATH/ead
HTML_DIR=$CONTENT_PATH/html

#SOLR1S=$CONTENT_STAGING_PATH/solr1/*/*.solr.xml
#SOLR2S=$CONTENT_STAGING_PATH/solr2/*/*.solr.xml

URL1=$SOLR1_URI/update
URL2=$SOLR2_URI/update

#`rm -f $SOLR1S`

#`rm -f $SOLR2S`


for d in $EAD_DIR/*; do
	if [[ ${d} == *${*}* ]]; then
		REPOSITORY_ID=`basename ${d}`
		echo $REPOSITORY_ID
		for e in $d/*; do
			eadbn=`basename $e | sed "s/\.xml//"`
			# make the html file

			eadid=`grep \<eadid.*\>[_[:alnum:][:space:]]*\</eadid\> $e | sed "s/.*<eadid[^>]*>//" | sed "s/<\/eadid>.*//" | sed "s/[ ]//g"`


			#Insert the AT namesppace if it doesn't exist
			


			#First check if there is a pubished version following the new convention
			if [[ -f $HTML_DIR/$REPOSITORY_ID/$eadid/index.html ]]; then
				echo $eadid
				solrFile="$eadid.solr.xml"
				uriParam=$CONTENT_URI/html/$REPOSITORY_ID/$eadid

				
		    elif [[ -f $HTML_DIR/$REPOSITORY_ID/$eadbn.html ]]; then
				echo $eadbn
				solrFile="$eadbn.solr.xml"
				uriParam=$CONTENT_URI/html/$REPOSITORY_ID/$eadbn.html

		    else 
				echo "There appears to be no published version of $e"
				continue;
		    fi

		   echo Writing solr index file for $uriParam


		   if grep -q "urn:isbn:1-931666-22-9" $e
		   then
			   echo "Has Namespace: "
			   solrXSL=$APP_PATH/xsl/write4solr.xsl
		   else
			   solrXSL=$APP_PATH/xsl/write4solr_deprecated.xsl
		   fi




		   #SOLR 1
		   transform_output_1=$(java -jar $SAXON_PATH -s:$e -o:$CONTENT_STAGING_PATH/solr1/$REPOSITORY_ID/$solrFile -xsl:$solrXSL collectionName=$REPOSITORY_ID sourceFilename=`basename $e` uri=$uriParam eadMode=inter)
		   #SOLR 2
		   transform_output_2=$(java -jar $SAXON_PATH -s:$e -o:$CONTENT_STAGING_PATH/solr2/$REPOSITORY_ID/$solrFile -xsl:$solrXSL collectionName=$REPOSITORY_ID sourceFilename=`basename $e` uri=$uriParam eadMode=intra)
		   if [[ $transform_output_1 =~ "Error reported by XML" ]]; then
			   echo $transform_output_1
		   elif [[ $transform_output_2 =~ "Error reorted by XML" ]]; then
					echo $transform_output_2
		   else
			   echo \<solrFile\>$solrFile\</solrFile\>
		   fi



		done

	fi
done




