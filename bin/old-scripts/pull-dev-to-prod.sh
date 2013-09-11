#!/bin/bash

# rsync-to-prod
# shell script to deploy all non data driven files to dlibprod

# Read the conf file
. /usr/local/dlib/eadpublisher/conf/eadpublisher.conf

############################################################################################
# EAD Publisher consists of three parts that go in three areas of the filesystem:
# 1. 'app' is the home of the application, at /usr/local/dlib/eadpublisher
# 2. 'content' is the home of the the data that the app manages, and some ancillary dtd, css and js directories
# 3. 'cgi' is the home for cgi files needed by the app, at /usr/local/apache/cgi-bin/eadpublisher
#
# This script should be run on dlibprod. It will copy the three parts from their development locations
#
############################################################################################


umask 002
# 1. move the 'app' to production
rsync -vrtpPz --stats --exclude="*svn" dlibdev:$APP_PATH/* $APP_PATH/	
echo

# 2. move the peripheral 'content' to production (but not the content itself) 
# This section no longer copies solr directories - they should be done separately (bh, 9.12)
rsync -vrtpPz --stats --include="dtd" --include="dtd/*" --include="dtd/*/*" --include="css" --include="css/*" --include="js" --include="js/*" --include="images" --include="images/*" --exclude="*" /content/dev/web/finding_aids/* /content/prod/store/web/finding_aids/

# 3. move the 'cgi' to production 
rsync -vrtpPz --stats --exclude="*svn" dlibdev:/usr/local/apache/cgi-bin/eadpublisher/* /usr/local/apache/cgi-bin/eadpublisher/




