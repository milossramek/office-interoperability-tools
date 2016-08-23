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
		#create directory structure
		if [ ! -d "$rtapp" ]; then
			cp -R $sourcedir $rtapp
			rm -f `find $rtapp -name \*.$format`
			rm -f `find $rtapp -name \*.pdf`
		fi
	
		files=`find $sourcedir -name \*.$format`
		#echo xx $files
		for ifile in $files; do
			ofile=${ifile/$sourcedir/$rtapp}
			if [ ! -e "$ofile" ] || [ "$ofile" -ot "$ifile" ];
			then
				timeout 30s ../doconv.sh -f $format -a $rtapp -i $ifile -o $ofile
			#else
				#echo "$ofile is up to date" 
			fi
			ofile2=`dirname $ofile`/`basename $ofile .$format`.$rtapp.pdf
			#ls -l $ofile2 $ifile
			if [ ! -e "$ofile2" ] || [ "$ofile2" -ot "$ifile" ]; then
				timeout 30s ../doconv.sh -f pdf -a $rtapp -i $ifile -o $ofile2
			else
				echo "$ofile is up to date" 
			fi
		done
	else
		echo "$0 warning: $rtapp conversion executable not defined. Is this the right system?" 2>&1
	fi
	killOOoServer $rtapp
done
