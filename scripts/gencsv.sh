#! /bin/bash
#set -o xtrace #be verbose

. $FTPATH/officeconf.sh

function usage
{
	echo "$0: Extract test results from the pair view files " 1>&2
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

#The first header line
for a in $rtripapps; do
    echo "Processing $a" 1>&2
    line="File name,"
    folder=$a'-'$(ver$a)
    line="$line$folder roundtrip,,,,,$folder print,,,,,"
    echo $line > $folder/all.csv

    # get names of pdf files from
    for dir in $sourcedir $sourceapp; do
        filenames=""
        cd $dir
        for fmt in $oformat; do
            aux=`find . -name \*.$fmt -printf '%P\n'`
            filenames="$aux $filenames"
        done
        cd ..

        #get one file with results go get the header
        aux=`echo $filenames|cut -d " " -f 1`
        rsltfile=`basename $aux .$fmt`
        rsltdir=`dirname $aux`
        rsltapp=`echo $rtripapps|cut -d " " -f 1`
        getheader $rsltapp/$rsltdir/$rsltfile.$fmt-pair-l.pdf
        header=$retval

        for f in $filenames;
        do
            #refpdfn=`basename $f .$format`	#source document without suffix
            refpdfn=`basename $f`	#source document without suffix
            ddd=`dirname $f`
            subdir=${ddd/\.\//}	# get nice subdir path
            #line="$subdir/$refpdfn"	# first line item - file name without suffix
            if [ $ddd == "." ]; then
	            line="$dir/$refpdfn"	# first line item - file name without suffix
            else
	            line="$dir/$subdir/$refpdfn"	# first line item - file name without suffix
            fi

            #the roundtrip file
            rsltpdf=$folder/$subdir/$refpdfn-pair-l.pdf
            #echo $rsltpdf
            getvalues $rsltpdf
            line="$line, $retval"
            #the printed file
            rsltpdf=$folder/$subdir/$refpdfn.$folder-pair-l.pdf
            #echo $rsltpdf
            getvalues $rsltpdf
            line="$line, $retval"

            echo $line >> $folder/all.csv
        done
    done
done
