#!/bin/bash

. ../conf/eadpublisher.conf


COLL=`/usr/bin/expr "$*" : '\(.*/\)' | /bin/sed "s/\///"`
FAID=`/usr/bin/expr "$*" : '.*\(/.*\)\s' | /bin/sed "s/\///"`

MODE=$2

PATH=""
if [[ $MODE == 'preview' ]]; then
  PATH=$CONTENT_STAGING_PATH
elif [[ $MODE == 'prod' ]]; then
   PATH=$CONTENT_PATH
fi

EADS=$PATH/ead/$COLL/$FAID.xml
if [[ $COLL == 'nyhs' || $COLL == 'NYHS' ]]; then
   collPage='http://dlib.nyu.edu/affiliates/NYHS/findingaids/'
fi
for e in $EADS; do
  		ARCHIVETYPE=`/usr/bin/dirname $e | /bin/sed "s/\/.*\///"`
  		echo Writing html version for file $e 
  		echo archive: $ARCHIVETYPE

			#This would be the old document HTML name - this will be used as a symlink
			#oldHtmlFile=`basename $e | sed "s/xml/html/"`

			newDir=`/bin/basename $e | /bin/sed "s/\.xml//"`
			# make the html file

			#eadid=`/bin/grep \<eadid.*\>[_[:alnum:][:space:]]*\</eadid\> $e | /bin/sed "s/.*<eadid[^>]*>//" | /bin/sed "s/<\/eadid>.*//" | /bin/sed "s/[ ]//g"`
                        eadid=`/usr/bin/perl -wlne 'print $1 if /<eadid.*?>(.*?)<\/eadid.*/' $e`

      #make sure the file was created by the AT.
  		ns_check=`/bin/grep urn:isbn:1-931666-22-9 $e`
			if [ ! ${#ns_check} -gt 0 ]; then
			  echo "EAD probably not exported from Archivists Toolkit. Exiting"
			  exit
			fi    
      
      

			echo Input EAD: $e
			echo Saxon Path: $SAXON_PATH
			

			if [ ${#eadid} -gt 0 ]; then

  			transform_output=$(/usr/bin/java -jar $SAXON_PATH -s:$e -xsl:$APP_PATH/xsl/ead2html.xsl targetDir=$PATH/html/nyhs_backup/nyhs_new_output collectionName=$ARCHIVETYPE searchURI=$SEARCH_URI contentURI=$CONTENT_URI collPage=$collPage 2>&1)
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
done

