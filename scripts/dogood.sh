#!/bin/bash
#set -o xtrace #be verbose


if [[ x$WINEPROG = "x" ]]
then
	WINEPROG="/usr/bin/wine"
	WINEPREFIX=$HOME/.wineprefixes/msoffice2010/
fi

function usage
{
	echo "$0 check if file can be converted correctly" 1>&2
	echo "Usage: $0 [switches] " 1>&2
	echo "Switches:" 1>&2
	echo "    -h --help ......... this usage" 1>&2
	echo "    -a path ........... application to use (LOxx, AOxx, MSxx,....)" 1>&2
	echo "    -i path ........... input file" 1>&2
	echo "    -o path ........... output file" 1>&2
	echo "    -g int ............ grade regarded to be bad {3}" 1>&2
	echo "    -r ................ roundtrip test (default: print test)" 1>&2
	exit 1
}


# Check if soffice is running
function checkLO ()
{
	SERVICE=soffice.bin
	ps -a | grep -v grep | grep $SERVICE > /dev/null
	result=$?
	if [ "${result}" -eq "0" ] ; then
    		echo "$SERVICE is running. Stop it first"
    		exit 1
	fi
}

# read configuration
#. $FTPATH/officeconf.sh 
libreoffice="/opt/libreoffice4.4/program/soffice"
ifile=xx.docx
ofile=xx.pdf
oformat=docx
grade=3


while [ $# -gt 0 ]
do
	case "$1" in
		-h* | --help*)
			usage
			shift
			;;
		-g)
			shift
			grade=$1
			shift
			;;
		-a)
			shift
			libreoffice=$1
			shift
			;;
		-i)
			shift
			ifile=$1
			shift
			;;
		-o)
			shift
			ofile=$1
			shift
			;;
		-r)
			shift
			roundtrip=1
			;;
		*)
			break
			;;
	esac
done

sourcetype=`echo $ifile|awk -F "." '{print $NF}'`
bname=`dirname $ifile`/`basename $ifile $sourcetype`
dname=`dirname $ifile`
sourcepdf=${bname}source.pdf

# create a source/reference pdf file if it does not exist
if [ ! -e $sourcepdf ]
then
	#msoconvert.sh -f pdf -o $sourcepdf $ifile
	$WINEPROG OfficeConvert --format=pdf --output=$sourcepdf $ifile &>/dev/null
	rslt=$?
	if [ "$rslt" -ne "0" ]
	then
		echo "Conversion by MS Office failed." 1>&2
		exit 255	# break the bisection process
	fi
fi

#checkLO

# check the tested application
if [ -x $libreoffice ]
then
	if [ -n "$roundtrip" ]
	then
		targetfile=${bname}roundtrip.$sourcetype
		targetpdf=${bname}roundtrip.pdf
		cp $ifile $targetfile
		$libreoffice --headless --convert-to $sourcetype --outdir $dname $targetfile >/dev/null 2>&1 
		#msoconvert.sh -f pdf -o $targetpdf $targetfile 2>/dev/null  
		$WINEPROG OfficeConvert --format=pdf --output=$targetpdf $targetfile &>/dev/null
		#rm $targetfile
	else
		targetfile=${bname}print.$sourcetype
		targetpdf=${bname}print.pdf
		cp $ifile $targetfile
		$libreoffice --headless --convert-to pdf --outdir $dname $targetfile>/dev/null 2>&1 
		#rm $targetfile
	fi
	#set id if we are in a git directory
	if [ -d ".git" ] 
	then
		# no paces allowed in IDs
		targetid="--target-id=LO-`cat .git/HEAD`"
		targetid=`echo $targetid|tr "[:space:]" "-"`
		sourceid="--source-id=MS-Office"
		docompare.py $sourceid $targetid -b -g $grade -a $sourcepdf $targetpdf  >/dev/null 2>&1 
		#docompare.py $sourceid $targetid -b -g $grade -a $sourcepdf $targetpdf
		exit $?
	else
		docompare.py -b -g $grade -a $sourcepdf $targetpdf  >/dev/null 2>&1 
		exit $?
	fi
	#docompare.py -b -g $grade -a $sourcepdf $targetpdf 
else
	echo "$libreoffice is not executable" 1>&2
	exit 255	# break the bisection process
fi
echo $libreoffice $ifile $sourcepdf $targetpdf
exit 1
