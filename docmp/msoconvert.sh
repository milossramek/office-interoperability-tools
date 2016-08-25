#!/bin/bash
#set -o xtrace #be verbose
#


WINEPROG="/usr/bin/wine"
WINEPREFIX=$HOME/.wineprefixes/msoffice2010/

format="pdf"
outname=
force=

function usage
{
	echo "$0: convert to other format using MS Office running on Wine" 1>&2
	echo "Usage: $0 switches file_to_convert" 1>&2
	echo "Switches:" 1>&2
	echo "    -f | --format ..... format to convert to (pdf, doc, docx, odt, rtf,...) {default: $format}" 1>&2 
	echo "    -o | ´output ...... file to save output to {default: derived from input, overrules the -f switch}" 1>&2 
	echo "    --force ........... force overwriting of the input file by the output {default: do not overwrite}" 1>&2 
	echo "    -h --help ......... this usage" 1>&2
	exit 1
}

aformat="xxx"

# read the options
TEMP=`getopt -o f:o:h --long format:,output:,help,force -n 'test.sh' -- "$@"`
eval set -- "$TEMP"

# extract options and their arguments into variables.
while true ; do
    case "$1" in
        --force)
                force=1 ; shift ;;
        -f|--format)
                aformat=$2 ; shift 2 ;;
        -h|--help) 
		usage; exit 1
		shift ;;
        -o|--output)
                outname=$2 ; shift 2 ;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

#get format from file name, ignore the -f switch
if [ "$outname" != "" ]; then
	aux=$(basename "$outname")
	aformat="${aux##*.}"
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
    if [ ! -f $inpath ]; then
		echo "$0 --- file '$inpath' does not exist" 1>&2
		exit 1
    fi
    ;;
    *)
	echo "$0 --- incorrect number of parameters" 1>&2
	usage
    ;;
esac

infile=`basename $inpath`
#get input file format
aux=$(basename "$infile")
iformat="${aux##*.}"


if [ ! -e $inpath ]
then
	echo "File $inpath does not exist." 1>&2
  	exit 1
fi

if [ "$iformat" != "$format" -o "x$force" != "x" ]; then
	$WINEPROG OfficeConvert --format=$format $outspec $inpath &>/dev/null
	exit 0
else
	echo "$0 --- Output equals to input, not overwriting." 1>&2
	echo "$0 --- Use the --force switch to overwrite." 1>&2
	exit 1
fi

