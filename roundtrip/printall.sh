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
			ifile=`basename $i`
			ofile=`basename $ifile .$format`.pdf
			dir=`dirname $i`
			cd $dir
			#if [ ! -e "$ofile" ] || [ "$ofile" -ot "$ifile" ];
			if [ ! -e "$ofile" ];
			then
				echo Printing $ifile in $dir to $ofile 
				print$sourceapp $ifile &>/dev/null
			else
				echo "$ofile is up to date" 
			fi
			)
		done
	done
else
	echo "$0 error: $sourceapp print command not defined. Is this the right system?" 2>&1
	exit 1
fi
