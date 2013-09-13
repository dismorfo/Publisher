#!/bin/bash

. ../conf/eadpublisher.conf

# Die if there is more than one argument
if [ $# -gt 1 ]; then
	echo 1>&2 Usage: $0 EADID or $0
	exit 127
fi

COLL=`expr "$*"`

echo $COLL

oldstylelinks=""
newstylelinks=""


NEWHTMLS=$CONTENT_PATH/html/$COLL/*/index.html
for hn in $NEWHTMLS; do
    eadid=`dirname "${hn}" | sed "s/\/.*\///"`
    url=$CONTENT_URI/html/$COLL/$eadid
    newstylelinks="$newstylelinks \n <p><a href=\"$url\">$url</a></p>"

done


OLDHTMLS=$CONTENT_PATH/html/$COLL/*.html
for h in $OLDHTMLS; do
	if [[ "${h}" =~ "_toc.html" ]]; then
	    continue
	fi
	if [[ "${h}" =~ "_content.html" ]]; then
	    continue
	fi
	hh=`basename "${h}"`
	url=$CONTENT_URI/html/$COLL/$hh
	oldstylelinks="$oldstylelinks \n <p><a href=\"$url\">$url</a></p>"
done

echo "<html><head></head><body>"
echo "<h1>Published using new stylesheet</h1>"
echo -e $newstylelinks
echo "<h1>Published using old stylesheet</h1>"
echo -e $oldstylelinks
echo "</body></html>"