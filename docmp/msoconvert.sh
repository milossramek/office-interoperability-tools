#!/bin/bash
#set -o xtrace #be verbose
#


WINEPROG="/usr/bin/wine"
WINEPREFIX=$HOME/.wineprefixes/msoffice2010/

format="pdf"
outname=

function usage
{
	echo "$0: convert to other format using MS Office running on Wine" 1>&2
	echo "Usage: $0 switches file_to_convert" 1>&2
	echo "Switches:" 1>&2
	echo "    -f ................ format to convert to (pdf, doc, docx, odt, rtf,...) {default: $format}" 1>&2 
	echo "    -o ................ file to save output to {default: derived from input, overrules the -f switch}" 1>&2 
	echo "    -h --help ......... this usage" 1>&2
	exit 1
}

aformat="xxx"

# read the options
TEMP=`getopt -o f:o:hsr: --long skip-ping,format:,remote-host:,output:,help -n 'test.sh' -- "$@"`
eval set -- "$TEMP"

# extract options and their arguments into variables.
while true ; do
    case "$1" in
        -f|--format)
                aformat=$2 ; shift 2 ;;
        -h|--help) 
		echo "help" ; shift ;;
        -o|--output)
                outname=$2 ; shift 2 ;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

#get format from file name, ignore the -f switch
if [ "$outname" != "" ]; then
	filename=$(basename "$outname")
	aformat="${filename##*.}"
	outspec="--output=$outname"
fi

#test the format
case $aformat in
	pdf | doc | docx | rtf | odt)
		format=$aformat
		;;
	xxx)
		format=$format
		;;
	*)
		echo "$0 --- unsupported format '$aformat'" 1>&2
		usage
		;;
esac

#The rest from the command line: file name
case $# in
    0) 
	usage
    ;;
    1) inpath=$1
    if [ ! -f $infile ]; then
		echo "$0 --- file '$infile' does not exist" 1>&2
		exit 1
    fi
    ;;
    *)
	echo "$0 --- incorrect number of parameters" 1>&2
	usage
    ;;
esac

infile=`basename $inpath`

if [ ! -e $inpath ]
then
	echo "File $inpath does not exist." 1>&2
  	exit 1
fi
#convert
#wincmd="$WINEXE  -U $USER%$PW //$HOST \"OfficeConvert --format=$format $WINPATH$infile\" > /dev/null"
#wincmd="$WINEXE  -U $USER%$PW //$HOST \"OfficeConvert --format=$format $WINPATH$infile\""
#echo $wincmd

#export WINEPREFIX=$WINEPREFIX
$WINEPROG OfficeConvert --format=$format $outspec $infile &>/dev/null

exit 0
