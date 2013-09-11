#!/bin/bash

# deploy-ead.bash
# shell script to deploy ead html files from staging to production; also post solr file to solr service

# Read the conf file
. ../conf/eadpublisher.conf

# Usage:
# ./ead-publish.bash [-r REPOSITORY_CODE] [-e EADID_EXPRESSION]
#
# This script will push HTML files from the staging area
# to the public area, and will post SOLR files in the staging area
# to the index.
#
# Leave off the -r option to publish in all repositories
#
# Leave off the -e option to publish all EADs.
#

#Create files that can be overwritten
umask 002

while getopts "r:e:" opt; do
	case $opt in
		r)
			# One param only; a regexp matching a repository directory path
			if [ -z "${EAD_STAGING_PATH}" ]; then
				EAD_STAGING_PATH=$CONTENT_STAGING_PATH/ead/$OPTARG
			else
				echo "-r flag can only be used once; Exiting"
				exit 127
			fi
			;;
		e)
			# One param only; a pattern to use for searching eadids
			if [ -z "${EADID_EXP}" ]; then
				EADID_EXP=$OPTARG
			else
				echo "-e flag can only be used once; Exiting"
				exit 127
			fi
			;;
	esac		
done

# If the repository is unspecified, do all
if [ -z "${EAD_STAGING_PATH}" ]; then
	EAD_STAGING_PATH=$CONTENT_STAGING_PATH/ead/*
fi

#If the eadid is unspecified, do all
if [ -z "${EADID_EXP}" ]; then
	EADID_EXP=".*"
fi


for r in $EAD_STAGING_PATH; do
	if [ -d $r ]; then
		echo "Processing directory $r"
		REPOSITORY_CODE=`basename "${r}" | sed "s/\/.*\///"`
		echo "Repository $REPOSITORY_CODE"
		EAD_FILES=`grep -l \<eadid.*\>$EADID_EXP\</eadid\> $r/*`
		for e in $EAD_FILES; do

			# Make sure the file is kosher
		      	# Make sure the file was created by the AT.
  			ns_check=`grep urn:isbn:1-931666-22-9 ${e}`
			if [[ ! ${#ns_check} -gt 0 ]]; then
				echo "${e} probably not exported from Archivists Toolkit. Moving on to the next one."
		    		continue
			fi

			# Make sure the file has a valid eadid
	    		EADID=`grep \<eadid.*\>[_[:alnum:][:space:]]*\</eadid\> "${e}" | sed "s/.*<eadid[^>]*>//" | sed "s/<\/eadid>.*//" | sed "s/[ ]//g"`
	   		if [[ ! ${#EADID} -gt 0 ]]; then
				echo "EAD is lacking an <eadid> value. Moving on to the next one."
		    		continue
	   		fi		   

			EAD=$CONTENT_STAGING_PATH/ead/$REPOSITORY_CODE/$EADID.xml #identical to $e
			HTML=$CONTENT_STAGING_PATH/html/$REPOSITORY_CODE/$EADID
			INDEX=$CONTENT_STAGING_PATH/html/$REPOSITORY_CODE/$EADID/index.html
			SOLR1=$CONTENT_STAGING_PATH/solr1/$REPOSITORY_CODE/$EADID.solr.xml
			SOLR2=$CONTENT_STAGING_PATH/solr2/$REPOSITORY_CODE/$EADID.solr.xml


			# Make sure there is an HTML directory with index page in the staging area
			if [[ ! -f $INDEX ]]; then
				echo "Could not find an HTML index page for $REPOSITORY_CODE/$EADID; Continuing."
				continue
			fi

			# Make sure there is a SOLR file for the EAD
			if [[ ! -f $SOLR1 ]]; then
				echo "Could not find a SOLR (1) file for $REPOSITORY_CODE/$EADID; Continuing."
				continue
			fi

			# Make sure there is a SOLR file for the EAD's Container List
			if [[ ! -f $SOLR2 ]]; then
				echo "Could not find a SOLR (2) file for $REPOSITORY_CODE/$EADID; Continuing."
				continue
			fi


			# Start Publishing the EAD:

			# 1. Move the EAD into the published area
			`mv $EAD $CONTENT_PATH/ead/$REPOSITORY_CODE/`

			# 2. Move the HTML site to the published area
			if [ ! -d $CONTENT_PATH/html/$REPOSITORY_CODE/$EADID ]; then
			    `mkdir $CONTENT_PATH/html/$REPOSITORY_CODE/$EADID`
			fi

			`mv -f $HTML/* $CONTENT_PATH/html/$REPOSITORY_CODE/$EADID/`
			`rm -rf $HTML`


			# 3. Post the first SOLR file
			echo $SOLR1
			curl $SOLR1_URI/update --data-binary @${SOLR1} -H 'Content-type:application/xml; charset=utf-8' 
		  	echo
			#send the commit command to make sure all the changes are flushed and visible
			curl $SOLR1_URI/update --data-binary '<commit/>' -H 'Content-type:application/xml'

			continue

			# 4. Post the second SOLR file
			curl $SOLR2_URI/update --data-binary @${SOLR2} -H 'Content-type:application/xml; charset=utf-8' 
		  	echo
			#send the commit command to make sure all the changes are flushed and visible
			curl $SOLR2_URI/update --data-binary '<commit/>' -H 'Content-type:application/xml'

			`rm $SOLR1`
			`rm $SOLR2`

		done
	else
		echo "$r is not a directory; Skipping."
	fi
done
