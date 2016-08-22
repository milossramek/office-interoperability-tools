#!/bin/bash
#set -o xtrace #be verbose

. config.sh
. $FTPATH/officeconf.sh 

let canprint=canprint$sourceapp
if [ $canprint -eq 1 ] 
then
	for a in $sourcedir `echo $rtripapps`; do
		echo Printing in $a
		for i in `find $a -name \*.$format`; do
			(
			echo Printing `basename $i` in `dirname $i`
			cd `dirname $i`
			print$sourceapp `basename $i` &>/dev/null
			)
		done
	done
else
	echo "$0 error: $sourceapp print command not defined. Is this the right system?" 2>&1
	exit 1
fi
