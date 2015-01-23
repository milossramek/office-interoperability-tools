#!/bin/bash

. config.sh

function cmp ()
{
	#echo 1 $1
	refpdf=`basename $1` 	#source document with suffix
	refpdfn=`basename $refpdf .pdf`	#source document without suffix
	#echo refpdf $refpdf
	ddd=`dirname $1`
	subdir=${ddd/\.\//}	# nice subdir path
	#echo subdir $subdir
	spdf=$sourcedir/$subdir/$refpdf	#source document with nice path
	#echo spdf $spdf
	tpdf=$2/$subdir/$refpdfn	#target document with nice path without suffix
	#echo tpdf $tpdf
	
	echo Creating pairs for  $tpdf
	docompare.py -t 250 -a -o $tpdf-pair $spdf $tpdf.pdf 2>/dev/null &
	docompare.py -t 250 -a -o $tpdf.$2-pair $spdf $tpdf.$2.pdf 2>/dev/null
}

#get list of source pdfs. We assume the same structure and files in the targer directories
cd $sourcedir
pdfs=`find . -name \*.pdf|grep -v pair|sort -n -k 1.7,1.9`
cd ..
echo $pdfs

#echo $pdfs
for app in `echo $rtripapps`; do
	for pdfdoc in $pdfs; do cmp $pdfdoc $app; done
done
