#!/bin/bash

. ../conf/eadpublisher.conf

# Die if there is more than one argument
if [ $# -gt 1 ]; then
	echo 1>&2 Usage: $0 EADID or $0
	exit 127
fi

COLL=`expr "$*" : '\(.*/\)' | sed "s/\///"`
FILEID=`expr "$*" : '.*\(/.*\)' | sed "s/\///"`

redirects=''
no_change=''
change=''

EADFILES=$CONTENT_PATH/ead/$COLL/$FILEID.xml
for f in $EADFILES; do
	echo $f
	#santize white space
  		ARCHIVETYPE=`dirname "${f}" | sed "s/\/.*\///"`
		tmpIFS=$IFS
		IFS=""
	    eadid=`grep \<eadid.*\>[_[:alnum:][:space:]]*\</eadid\> "${f}" | sed "s/.*<eadid[^>]*>//" | sed "s/<\/eadid>.*//" | sed "s/[ ]//g"`
      echo "${eadid}:"
      
  		# the name of the old HTML file
		  oldhtml=`basename "${f}" | sed "s/\.xml/\.html/"`

	   #Does the old HTML file exist?
	   if [ ! -f $CONTENT_PATH/html/$COLL/$oldhtml ]; then
		   #If it doesn't appear, see if there's a candidate using the EADID
		   if [ -f $CONTENT_PATH/html/$COLL/$eadid.html ];then
			   oldhtml="${eadid}.html (?)"
		   fi
	   fi
      #make sure the file was created by the AT.
  		ns_check=`grep urn:isbn:1-931666-22-9 ${f}`
		if [ ! ${#ns_check} -gt 0 ]; then
			echo "EAD probably not exported from Archivists Toolkit. Moving on to the next one."
			echo "--------"
			no_change="${no_change}EADID: $eadid \n $CONTENT_URI/html/$COLL/$oldhtml \n"
			no_change="${no_change}  REASON: Missing correct namespace (not an AT export) \n"
		    continue
	   fi

		#make sure the file has an eadid
	   if [ ! ${#eadid} -gt 0 ]; then
			echo "EAD is lacking an <eadid> value. Moving on to the next one."
			echo "--------"
			no_change="${no_change}EADID: $eadid \n $CONTENT_URI/html/$COLL/$oldhtml \n"
			no_change="${no_change}  REASON: Missing <eadid> \n"
		    continue
	   fi		   
   
 # 		echo Writing html version for file $f with eadid $eadid 
 # 		echo archive: $ARCHIVETYPE

		# make sure the directory exists for the target
		if [ ! -d $CONTENT_PATH/html/$COLL/$eadid ]; then
			umask 002
			`mkdir $CONTENT_PATH/html/$COLL/$eadid`
			#exit 1;
	    fi


		transform_output=$(java -jar $SAXON_PATH -s:${f} -xsl:$APP_PATH/xsl/ead2html.xsl targetDir=$CONTENT_PATH/html/$COLL collectionName=$ARCHIVETYPE searchURI=$SEARCH_URI contentURI=$CONTENT_URI collPage=$collPage 2>&1)


		if [[ $transform_output =~ "Error reported by XML" ]]; then
			echo $transform_output
		elif [[ $transform_output =~ "java.io.FileNotFoundException:" ]]; then
			echo $transform_output
		else
			echo $transform_output
			redirects="$redirects \n Redirect permanent /findingaids/html/$COLL/$oldhtml $CONTENT_URI/html/$COLL/$eadid"
			change="${change}EADID: $eadid \n old: $CONTENT_URI/html/$COLL/$oldhtml \n new: $CONTENT_URI/html/$COLL/$eadid \n"
		fi
		echo "--------"
		IFS=$tmpIFS

done

# Report
echo "PASTE THIS INTO THE HTTPD CONF FILE------"
echo -e $redirects
echo "----------"
echo "THESE URLS ARE UNCHANGED"
echo -e $no_change
echo "-----------"
echo "THESE URLS ARE CHANGED"
echo -e $change
echo "-----------"
echo "ALL DONE"
