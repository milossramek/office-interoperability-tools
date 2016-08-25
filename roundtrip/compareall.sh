#!/bin/bash
#set -o xtrace #be verbose

. config.sh

function usage
{
	echo "$0: Compare pdf files and generate pair pdfs" 1>&2
	echo "Usage: $0 applist" 1>&2
	echo "If applist is not specified, all applications specified in config.sh will be processed." 1>&2
}

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
	
	if [ ! -e "${tpdf}-pair-l.pdf" ];
	then
		echo Creating pairs for  $tpdf
		docompare.py -t 250 -a -o $tpdf-pair $spdf $tpdf.pdf 2>/dev/null &
	else
		echo Pairs up-to-date for $tpdf
	fi
	if [ ! -e "${tpdf}.$2-pair-l.pdf" ];
	then
		echo Creating pairs for  $tpdf.$2
		docompare.py -t 250 -a -o $tpdf.$2-pair $spdf $tpdf.$2.pdf 2>/dev/null
	else
		echo Pairs up-to-date for $tpdf.$2
	fi
}

# read the options
TEMP=`getopt -o h --long help -n 'test.sh' -- "$@"`
eval set -- "$TEMP"

# extract options and their arguments into variables.
while true ; do
    case "$1" in
        -h|--help) 
		usage; exit 1;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done
shift $(expr $OPTIND - 1 )

#get list of source pdfs. We assume the same structure and files in the targer directories
cd $sourcedir
pdfs=`find . -name \*.pdf|grep -v pair|sort -n -k 1.7,1.9`
cd ..
echo $pdfs

if [[ $# -gt 0 ]] 
then
	while test $# -gt 0; 
	do
		if [ -d "$1" ]; then
  			echo Processing $1
			for pdfdoc in $pdfs; do cmp `basename $pdfdoc` $1; done
		else
  			echo Directory $1 does not exist
		fi
  		shift
	done
else
	for app in `echo $rtripapps`; do
  		echo Processing $app
		for pdfdoc in $pdfs; do cmp `basename $pdfdoc` $app; done
	done
fi
