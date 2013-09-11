#!/bin/bash

. ../conf/eadpublisher.conf

# Usage:
# ./ead-transform.bash [-p] [-t TARGET_FORMAT] [-r REPOSITORY_CODE] [-e EADID_EXPRESSION]
#
# You can run SOLR or HTML transformations. You can run both by repeating the -t flag.
#
# Example:
# 
# ./ead-transform.bash -t solr -t html -r tamwag -e a.*
# This will transform all EADs in the tamwag directory with <eadid>s that match a.*
#
# Leave off the -r option to run all repositories
#
# Leave off the -e option to match all eadids
#
# Use the -p flag to source EADs from the production directories (rather than staging)

umask 002

# Default EAD source directory is the staging area
SOURCE_PATH=$CONTENT_STAGING_PATH


while getopts "pt:r:e:" opt; do
	case $opt in
		p)
			echo "-p was triggered" >&2
			SOURCE_PATH=$CONTENT_PATH
			;;
		t)
			echo "-t was triggered, with: $OPTARG" >&2
			case $OPTARG in
				html)
					OUTPUTHTML=true
					;;
				solr)
					OUTPUTSOLR=true
					;;
				*)
					echo "Bad format selected; Use 'solr' or 'html'; Exiting"
					exit 127
					;;
			esac
			;;
		r)
			# One param only; a regexp matching a repository directory path
			if [ -z "${REPOSITORY_PATH}" ]; then
				REPOSITORY_PATH=$SOURCE_PATH/ead/$OPTARG
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
		\?)
			echo "invalid option: -$opt" >&2
			exit 1
			;;
	esac
done


#shift $((OPTIND-1))
#echo "$#"

# If the repository is unspecified, do all
if [ -z "${REPOSITORY_PATH}" ]; then
	REPOSITORY_PATH=$SOURCE_PATH/ead/*
fi

#If the eadid is unspecified, do all
if [ -z "${EADID_EXP}" ]; then
	EADID_EXP=".*"
fi

for r in $REPOSITORY_PATH; do
	if [[ -d $r ]]; then
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

			# Do Transforms


			if ${OUTPUTSOLR:=false}; then
				echo "Running SOLR transform for $e"
				SOLR_XSL=$APP_PATH/xsl/write4solr.xsl
				SOLR_FILENAME="$EADID.solr.xml"
				#SOLR 1
				transform_output_1=$(java -jar $SAXON_PATH -s:${e} -o:$CONTENT_STAGING_PATH/solr1/$REPOSITORY_CODE/$SOLR_FILENAME -xsl:$SOLR_XSL collectionName=$REPOSITORY_CODE sourceFilename=`basename ${e}` uri=$uriParam eadMode=inter)
				#SOLR 2
				transform_output_2=$(java -jar $SAXON_PATH -s:${e} -o:$CONTENT_STAGING_PATH/solr2/$REPOSITORY_CODE/$SOLR_FILENAME -xsl:$SOLR_XSL collectionName=$REPOSITORY_CODE sourceFilename=`basename ${e}` uri=$uriParam eadMode=intra)
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
			if ${OUTPUTHTML:=false}; then
				# Make sure the directory exists for the target
				if [ ! -d $CONTENT_STAGING_PATH/html/$REPOSITORY_CODE/$EADID ]; then
					umask 002
					`mkdir $CONTENT_STAGING_PATH/html/$REPOSITORY_CODE/$EADID`
	    			fi

				echo "Starting HTML transform for $e"
				transform_output=$(java -jar $SAXON_PATH -s:${e} -xsl:$APP_PATH/xsl/ead2html.xsl targetDir=$CONTENT_STAGING_PATH/html/$REPOSITORY_CODE collectionName=$REPOSITORY_CODE searchURI=$SEARCH_URI contentURI=$CONTENT_URI collPage=$collPage 2>&1)


				if [[ $transform_output =~ "Error reported by XML" ]]; then
					echo $transform_output
				elif [[ $transform_output =~ "java.io.FileNotFoundException:" ]]; then
					echo $transform_output
				elif [[ -e $CONTENT_STAGING_PATH/html/$REPOSITORY_CODE/$EADID ]]; then
					# A check of the mtime would be better
					echo "Success: $CONTENT_STAGING_URI/html/$REPOSITORY_CODE/$EADID"
					# 
				else 
					echo "Failure: Unknown problem creating $CONTENT_STAGING_PATH/html/$REPOSITORY_CODE/$EADID"
				fi

			fi
		done
	else
		echo "$r is not a directory; Skipping."
	fi
done
