#!/bin/bash
#set -o xtrace #be verbose
. config.sh
. $FTPATH/officeconf.sh 

checkLO

for rtapp in `echo $rtripapps`; do
	startOOoServer $rtapp
	let canconvert=canconvert$rtapp
	if [ $canconvert -eq 1 ] 
	then
		echo Processing $rtapp
		#create directory if it does not exit
		if [ ! -d "$rtapp" ]; then
			mkdir $rtapp
			rm -f `find $rtapp -name \*.pdf`
			for fmt in $format; do
				rm -f `find $rtapp -name \*.$fmt`
			done
		fi
	
		for fmt in $format; do
			files=`find $sourcedir -name \*.$fmt`
			#echo xx $files
			for ifile in $files; do
				ofile=${ifile/$sourcedir/$rtapp}
				# convert to the same file type
				# input: orig/bullets.doc
				# output: LO52/bullets.doc
				if [ ! -e "$ofile" ] || [ "$ofile" -ot "$ifile" ];
				then
					if ! timeout 30s $FTPATH/scripts/doconv.sh -f $fmt -a $rtapp -i $ifile -o $ofile; then
						echo Timeout Reached
					fi
				#else
					#echo "$ofile is up to date" 
				fi
				#ofile2=`dirname $ofile`/`basename $ofile .$fmt`.$rtapp.pdf
				# keep type to enable processing of multiple formats
				ofile2=`dirname $ofile`/`basename $ofile`.$rtapp.pdf
				#ls -l $ofile2 $ifile
				# convert to pdf
				# input: orig/bullets.doc
				# output: LO52/bullets.doc.LO52.pdf
				if [ ! -e "$ofile2" ] || [ "$ofile2" -ot "$ifile" ]; then
					if ! timeout 30s $FTPATH/scripts/doconv.sh -f pdf -a $rtapp -i $ifile -o $ofile2; then
						echo Timeout Reached
					fi
				#else
					#echo "$ofile is up to date" 
				fi
			done
		done
	else
		echo "$0 warning: $rtapp conversion executable not defined. Is this the right system?" 2>&1
	fi
	killOOoServer $rtapp
done
