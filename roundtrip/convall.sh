#!/bin/bash
#set -o xtrace #be verbose

. config.sh
. $FTPATH/officeconf.sh 

for a in `echo $rtripapps`; do
	startOOoServer $a
	let canconvert=canconvert$a
	if [ $canconvert -eq 1 ] 
	then
		echo Processing $a
		#create directory structure
		rm -rf $a
		cp -R $sourcedir $a
		rm -f `find $a -name \*.$format`
		rm -f `find $a -name \*.pdf`
	
		files=`find $sourcedir -name \*.$format`
		#echo xx $files
		for i in $files; do
			ofile=${i/$sourcedir/$a}
			../doconv.sh -f $format -a $a -i $i -o $ofile
			ofile2=`dirname $ofile`/`basename $ofile .$format`.$a.pdf
			../doconv.sh -f pdf -a $a -i $i -o $ofile2
		done
	else
		echo "$0 warning: $a conversion executable not defined. Is this the right system?" 2>&1
	fi
	killOOoServer $a
done
