#!/bin/bash

. ../conf/eadpublisher.conf

# Usage:
# ./ead-manager.bash [-a ACTION] [-r REPOSITORY_CODE] [-e EADID]
#
# Actions:
#	transform		- Transform staged EAD into HTML and SOLR
#	transform-html		- Transform staged EAD to HTML
#	transform-solr		- Transform staged EAD to SOLR
#	publish			- Move staged files to production; post to solr
#	unpublish		- Move production files to stage; delete from solr
#	unstage			- Wipe staged files
#
# Example:
# 
# ./ead-manager.bash -a transform -r tamwag -e a.*
# This will transform all EADs in the tamwag directory with <eadid>s that match a.*
#
# Leave off the -r option to run all repositories
#
# Leave off the -e option to match all eadids
#


umask 002

while getopts "a:r:e:" opt; do
	case $opt in
		a)
			case $OPTARG in
				transform)
					ACTION=transform
					OUTPUTHTML=true
					OUTPUTSOLR=true
					;;
				transform-html)
					ACTION=transform
					OUTPUTHTML=true
					;;
				transform-solr)
					ACTION=transform
					OUTPUTSOLR=true
					;;
				publish)
					ACTION=publish
					;;
				unpublish)
					ACTION=unpublish
					;;
				unstage)
					ACTION=unstage
					;;					
				*)
					echo "Bad format selected; Use 'transform', 'transform-html', transform-solr', 'publish', 'unpublish', or 'unstage'; Exiting"
					exit 127
					;;
			esac
			;;
		r)
			# One param only; a repository code
			if [ -z "${REPOSITORY_CODE}" ]; then
				REPOSITORY_CODE=$OPTARG
			else
				echo "-r flag can only be used once; Exiting"
				exit 127
			fi
			;;
	
		e)
			# One param only; a string to identify and EAD
			if [ -z "${EADID}" ]; then
				EADID=$OPTARG
			else
				echo "-e flag can only be used once; Exiting"
				exit 127
			fi
			;;
		\?)
			echo "invalid option: -$opt" >&2
			exit 1
			;;
	esac
done

# Die if there isn't an $ACTION
if [[ -z $ACTION ]]; then
	echo "No action was called for (-a transform|transform-html|transform-solr|publish|unpublish|unstage). Exiting."
	exit 127
fi


# Default EAD source directory is the staging area
SOURCE_PATH=$CONTENT_STAGING_PATH

# For unpublishing, start with the public area
if [[ $ACTION == 'unpublish' ]]; then
	SOURCE_PATH=$CONTENT_PATH
fi


# If the repository code is unspecified, exit
if [ -z "${REPOSITORY_CODE}" ]; then
	echo "No Repository Code specified. Exiting."
	exit 127
fi

#If the eadid is unspecified, exit
if [ -z "${EADID}" ]; then
	echo "No EAD id specified. Exiting."
	exit 127
fi


REPOSITORY_PATH=$SOURCE_PATH/ead/$REPOSITORY_CODE


if [[ $ACTION == 'transform' ]]; then

	EAD_FILES=(`grep -l \<eadid.*\>$EADID\</eadid\> ${REPOSITORY_PATH}/*`)
	if [[ -z $EAD_FILES ]]; then
		echo "Found nothing in this directory to match ${EADID}."
	fi
	echo ${#EAD_FILES[@]}
	if [[ ${#EAD_FILES[@]} -gt 1 ]]; then
		echo "More than one EAD matches ${EADID}. Exiting."
		exit 127
	fi
	if [[ ${#EAD_FILES[@]} -lt 1 ]]; then
		echo "Couldn't find a file to transform. Used ${EADID} to search ${REPOSITORY_PATH}. Exiting."
		exit 127
	fi	
	EAD_FILE=$EAD_FILES


	# Make sure the file is kosher
      	# Make sure the file was created by the AT.
	ns_check=`grep urn:isbn:1-931666-22-9 ${EAD_FILE}`
	if [[ ! ${#ns_check} -gt 0 ]]; then
		echo "${EAD_FILE} probably not exported from Archivists Toolkit. Exiting."
		exit 127
	fi

	# Solr Transforms
	if ${OUTPUTSOLR:=false}; then
		#Make sure the target directories are there and are writeable:
		if [[ ! -w $CONTENT_STAGING_PATH/solr1/$REPOSITORY_CODE ]]; then
			echo "Cannot write to: $CONTENT_STAGING_PATH/solr1/$REPOSITORY_CODE. Stopping transform for $EADID."
			exit 127
		fi
		if [[ ! -w $CONTENT_STAGING_PATH/solr2/$REPOSITORY_CODE ]]; then
			echo "Cannot write to: $CONTENT_STAGING_PATH/solr2/$REPOSITORY_CODE. Stopping transform for $EADID."
		fi
		echo "Running SOLR transform for $EAD_FILE"
		SOLR_XSL=$APP_PATH/xsl/write4solr.xsl
		SOLR_FILENAME="$EADID.solr.xml"
		#SOLR 1
		transform_output_1=$(java -jar $SAXON_PATH -s:${EAD_FILE} -o:$CONTENT_STAGING_PATH/solr1/$REPOSITORY_CODE/$SOLR_FILENAME -xsl:$SOLR_XSL collectionName=$REPOSITORY_CODE sourceFilename=`basename ${EAD_FILE}` uri=$uriParam eadMode=inter)
		#SOLR 2
		transform_output_2=$(java -jar $SAXON_PATH -s:${EAD_FILE} -o:$CONTENT_STAGING_PATH/solr2/$REPOSITORY_CODE/$SOLR_FILENAME -xsl:$SOLR_XSL collectionName=$REPOSITORY_CODE sourceFilename=`basename ${EAD_FILE}` uri=$uriParam eadMode=intra)
		if [[ $transform_output_1 =~ "Error reported by XML" ]]; then
			echo $transform_output_1
		elif [[ $transform_output_2 =~ "Error reported by XML" ]]; then
			echo $transform_output_2
   		elif [[ -e $CONTENT_STAGING_PATH/solr1/$REPOSITORY_CODE/$SOLR_FILENAME && -e $CONTENT_STAGING_PATH/solr2/$REPOSITORY_CODE/$SOLR_FILENAME ]]; then
	   		echo "Success: Created SOLR files for $EADID"
		else
			echo "Failure: Problem creating SOLR files for $EADID"
   		fi			
	fi
	# HTML transforms
	if ${OUTPUTHTML:=false}; then
		# Make sure the directory exists for the target
		if [ ! -d $CONTENT_STAGING_PATH/html/$REPOSITORY_CODE/$EADID ]; then
			umask 002
			`mkdir $CONTENT_STAGING_PATH/html/$REPOSITORY_CODE/$EADID`
		fi
		# Make sure the target directory is writeable
		if [ ! -w $CONTENT_STAGING_PATH/html/$REPOSITORY_CODE/$EADID ]; then
			echo "Cannot write to $CONTENT_STAGING_PATH/html/$REPOSITORY_CODE/$EADID. Exiting transform for $EADID."
			exit 127
		fi
		echo "Starting HTML transform for $EAD_FILE"
		transform_output=$(java -jar $SAXON_PATH -s:${EAD_FILE} -xsl:$APP_PATH/xsl/ead2html.xsl targetDir=$CONTENT_STAGING_PATH/html/$REPOSITORY_CODE collectionName=$REPOSITORY_CODE searchURI=$SEARCH_URI contentURI=$CONTENT_URI 2>&1)
		if [[ $transform_output =~ "Error reported by XML" ]]; then
			echo $transform_output
		elif [[ $transform_output =~ "java.io.FileNotFoundException:" ]]; then
			echo $transform_output
		elif [[ -e $CONTENT_STAGING_PATH/html/$REPOSITORY_CODE/$EADID ]]; then
			# A check of the mtime would be better
			echo "Success: $CONTENT_STAGING_URI/html/$REPOSITORY_CODE/$EADID"
		else 
			echo "Failure: Unknown problem creating $CONTENT_STAGING_PATH/html/$REPOSITORY_CODE/$EADID"
		fi
	fi
fi

#Publish
# Publishing is an all or nothing proposition, so all checks must pass or the action fails.
if [[ $ACTION == 'publish' ]]; then
	EAD_FILES=(`grep -l \<eadid.*\>$EADID\</eadid\> ${CONTENT_STAGING_PATH}/ead/${REPOSITORY_CODE}/*`)
	HTML=${CONTENT_STAGING_PATH}/html/${REPOSITORY_CODE}/${EADID}
	INDEX=${CONTENT_STAGING_PATH}/html/${REPOSITORY_CODE}/${EADID}/index.html
	SOLR1=${CONTENT_STAGING_PATH}/solr1/${REPOSITORY_CODE}/${EADID}.solr.xml
	SOLR2=${CONTENT_STAGING_PATH}/solr2/${REPOSITORY_CODE}/${EADID}.solr.xml

	#Make sure there is exactly one EAD in the staging area
	if [[ ${#EAD_FILES[@]} -ne 1 ]]; then
		echo "Couldn't find a unique match for ${EADID} in ${CONTENT_STAGING_PATH}/ead/${REPOSITORY_CODE}. Exiting"
		exit 127
	fi

	# Make sure there is an HTML directory with index page in the staging area
	if [[ ! -f $INDEX ]]; then
		echo "Could not find an HTML index page for $REPOSITORY_CODE/$EADID; Exiting."
		exit 127
	fi

	# Make sure there is a SOLR file for the EAD
	if [[ ! -f $SOLR1 ]]; then
		echo "Could not find a SOLR (1) file for $REPOSITORY_CODE/$EADID; Exiting."
		exit 127
	fi

	# Make sure there is a SOLR file for the EAD's Container List
	if [[ ! -f $SOLR2 ]]; then
		echo "Could not find a SOLR (2) file for $REPOSITORY_CODE/$EADID; Exiting."
		exit 127
	fi

	# Start Publishing the EAD:

	if [[ ! -f $EAD_FILES ]];then
		echo "Cannot locate ${EAD_FILES}. Exiting"
		exit 127
	fi

	# 1. Move the EAD into the published area
	echo "Moving ${EAD_FILES} to ${CONTENT_PATH}/ead/${REPOSITORY_CODE}"
	`mv $EAD_FILES $CONTENT_PATH/ead/$REPOSITORY_CODE/`

	# 2. Move the HTML site to the published area
	echo "Moving ${HTML} to ${CONTENT_PATH}/html/${REPOSITORY_CODE}/${EADID}"
	if [[ ! -d $CONTENT_PATH/html/$REPOSITORY_CODE/$EADID ]]; then
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

	# 4. Post the second SOLR file
	curl $SOLR2_URI/update --data-binary @${SOLR2} -H 'Content-type:application/xml; charset=utf-8' 
  	echo
	#send the commit command to make sure all the changes are flushed and visible
	curl $SOLR2_URI/update --data-binary '<commit/>' -H 'Content-type:application/xml'

	`rm $SOLR1`
	`rm $SOLR2`
fi

#Unpublish
# Any unpublish actions that can be done should be done
if [[ $ACTION == 'unpublish' ]]; then
	EAD_FILES=(`grep -l \<eadid.*\>$EADID\</eadid\> ${CONTENT_PATH}/ead/${REPOSITORY_CODE}/*`)
	HTML=$CONTENT_PATH/html/$REPOSITORY_CODE/$EADID

	#1. Delete in SOLR
	SOLRID="${REPOSITORY_CODE}_${EADID}"
	SOLR1COM="<delete><id>${SOLRID}</id></delete>"
	SOLR2COM="<delete><query>collectionId:${SOLRID}</query></delete>"

	curl $SOLR1_URI/update --data-binary ${SOLR1COM} -H 'Content-type:application/xml; charset=utf-8'
	echo
	curl $SOLR1_URI/update --data-binary '<commit/>' -H 'Content-type:application/xml; charset=utf-8'

	curl $SOLR2_URI/update --data-binary ${SOLR2COM} -H 'Content-type:application/xml; charset=utf-8'
	echo
	curl $SOLR2_URI/update --data-binary '<commit/>' -H 'Content-type:application/xml; charset=utf-8'

	# Move everything back to staging (overwrite anything else in the staging slots - this isn't a CMS).
	# 2. Move the production EAD back to staging.
	# There should not be more than 1 match, but if there are, move them all
	for e in $EAD_FILES; do
		`mv $e $CONTENT_STAGING_PATH/ead/$REPOSITORY_CODE/`
	done

	# 3. Move the production HTML back to staging.
	if [[ ! -d $CONTENT_STAGING_PATH/html/$REPOSITORY_CODE/$EADID ]]; then
		`mkdir $CONTENT_STAGING_PATH/html/$REPOSITORY_CODE/$EADID`
	fi

	if [[ -d ${HTML} ]];then
		`mv -f $HTML/* $CONTENT_STAGING_PATH/html/$REPOSITORY_CODE/$EADID/`
		`rm -rf $HTML`
	fi
				
fi

#Unstage (Delete from Staging)
if [[ $ACTION == 'unstage' ]]; then
	EAD_FILES=(`grep -l \<eadid.*\>$EADID\</eadid\> ${REPOSITORY_PATH}/*`)
	HTML=$CONTENT_STAGING_PATH/html/$REPOSITORY_CODE/$EADID
	SOLR1=$CONTENT_STAGING_PATH/solr1/$REPOSITORY_CODE/$EADID.solr.xml
	SOLR2=$CONTENT_STAGING_PATH/solr2/$REPOSITORY_CODE/$EADID.solr.xml


	#1. Remove the EAD from the staging area
	for e in ${EAD_FILES}; do
		if [[ -f ${e} ]]; then
			echo "Removing ${e}"
			`rm -rf ${e}`
		fi
	done
	#2. Remove the HTML directory
	if [[ -d ${HTML} ]];then
		echo "Removing ${HTML}"
		`rm -rf $HTML`
	fi
	#3. Remove the SOLR files in staging.
	if [[ -f ${SOLR1} ]]; then
		echo "Removing ${SOLR1}"
		`rm -rf $SOLR1`
	fi
	if [[ -f ${SOLR2} ]]; then
		echo "Removing ${SOLR2}"
		`rm -rf $SOLR2`
	fi

fi




