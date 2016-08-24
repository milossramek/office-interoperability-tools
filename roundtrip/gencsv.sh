#! /bin/bash
#set -o xtrace #be verbose


function usage
{
	echo "$0: Extract test results from the pair view files " 1>&2
	echo "	Configuration of to-be-tested cases specified in 'config.sh'" 1>&2
	echo "Usage: $0 [switches] " 1>&2
	echo "Switches:" 1>&2
	echo "    -o ................ file to saved output (views and information) {default: $outname}" 1>&2 
	echo "    -h --help ......... this usage" 1>&2
	exit 1
}

function sel2
{
	echo "$1" | cut --delimiter=: --fields=$2
}

function getheader ()
{
	if [ -f $1 ]; then
		t=`exiftool -Custom1 $1`
		retval="`sel2 "$t" 2`,`sel2 "$t" 4`,`sel2 "$t" 6`,`sel2 "$t" 8`,`sel2 "$t" 10`"
	fi
}

function getvalues
{
	if [ -f $1 ]; then
		t=`exiftool -Custom1 $1`
		retval="`sel2 "$t" 3`,`sel2 "$t" 5`,`sel2 "$t" 7`,`sel2 "$t" 9`,`sel2 "$t" 11`"
	fi
}

########################################
. config.sh
while [ $# -gt 0 ]
do
	case "$1" in
		-h* | --help*)
			usage
			shift
			;;
		-o)
			shift
			outname=$1
			shift
			;;
		*)
			usage
			shift
			;;
	esac
done

# get names of pdf files from 
cd $sourcedir
filenames=`find . -name \*.pdf|grep -v pair`
cd ..

#get one file with results go get the header
aux=`echo $filenames|cut -d " " -f 1`
rsltfile=`basename $aux .pdf`
rsltdir=`dirname $aux`
rsltapp=`echo $rtripapps|cut -d " " -f 1`	
getheader $rsltapp/$rsltdir/$rsltfile-pair-l.pdf
header=$retval

#The first header line
line="File name,"
for a in $rtripapps; do line="$line$a roundtrip,,,,,$a print,,,,," ; done
echo $line
#The second header line
line=","
for a in $rtripapps; do line="$line $header, $header," ; done
echo $line

echo $filenames 1>&2
for f in $filenames;
do
	refpdfn=`basename $f .pdf`	#source document without suffix
	ddd=`dirname $f`
	subdir=${ddd/\.\//}	# get nice subdir path
	line="$subdir/$refpdfn"	# first line item - file name without suffix
	for app in $rtripapps;
	do
		echo "Processing $app/$subdir/$refpdfn" 1>&2
		#the roundtrip file
		rsltpdf=$app/$subdir/$refpdfn-pair-l.pdf
		#echo $rsltpdf
		getvalues $rsltpdf
		line="$line, $retval"
		#the printed file
		rsltpdf=$app/$subdir/$refpdfn.$app-pair-l.pdf
		#echo $rsltpdf
		getvalues $rsltpdf
		line="$line, $retval"
	done
	echo $line
done