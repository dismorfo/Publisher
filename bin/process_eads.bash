#!/bin/bash

. ../conf/eadpublisher.conf




PATH=$1
EADS=`/bin/ls $PATH/*.xml`
#EADS=`/bin/ls $PATH/taylor.xml`

for f in $EADS 
do
    echo $f
    EADID=`/usr/bin/perl -wlne 'print $1 if /<eadid.*?>(.*?)<\/eadid.*/' $f`
    echo $EADID
    /www/sites/findingaids/prod/publisher/bin/apply-changes.bash nyhs/$EADID prod
done
 
