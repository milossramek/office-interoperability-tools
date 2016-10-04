#!/bin/bash
#set -o xtrace #be verbose

. config.sh
. $FTPATH/officeconf.sh 

let canprint=canprint$sourceapp
if [ $canprint -eq 1 ] 
then
	for a in $sourcedir $rtripapps; do
		echo Printing in $a
		for fmt in $format; do
			for i in `find $a -name \*.$fmt`; do
				(
				ifile=`basename $i`
				auxpdf=`basename $ifile .$fmt`.pdf
				# keep type to enable processing of multiple formats
				ofile=`basename $ifile`.pdf
				dir=`dirname $i`
				cd $dir
				if [ ! -e "$ofile" ] || [ "$ofile" -ot "$ifile" ];
				# files already have LO51 in their name, no renaming necessary
				#if [ ! -e "$ofile" ];
				then
					echo Printing $ifile in $dir to $ofile 
					# apps in general cannot create specific file but just $auxpdf
					print$sourceapp $ifile &>/dev/null
					# convert to pdf
					# input: orig/bullets.doc
					# output: orig/bullets.doc.pdf
					# output: LO52/bullets.doc.pdf
					#rename to contain $fmt in file name
					if [ ! -e $auxpdf ];
					then
						# delete in the case it is there from the previous test
						# missing file will be in report indicated by grade 7
						echo Failed to create $ofile
						rm -f $ofile	
					else
						mv $auxpdf $ofile
					fi
				#else
					#echo "$ofile is up to date" 
				fi
				)
			done
		done
	done

else
	echo "$0 error: $sourceapp print command not defined. Is this the right system?" 2>&1
	exit 1
fi
