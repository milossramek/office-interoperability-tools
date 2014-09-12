#! /bin/bash
#
# doeval.py v1.0 - 2013-09-30
#
# doviews.sh This script generates views and numeric evaluations of printed test documents
#
# Copyright (C) 2013 Milos Sramek <milos.sramek@soit.sk>
# Licensed under the GNU LGPL v3 - http://www.gnu.org/licenses/gpl.html
# - or any later version.
#
#set -o xtrace #be verbose

fp=""
outname=all
split=0
exsame=0
fdir="pdfpairs"
dpi=200
firstdone=
reuse=0

function usage
{
	echo "$0: create views for interoperability testing of text documents " 1>&2
	echo "	Views are by default saved in '$outname-x.pdf'" 1>&2
	echo "	Description of types and ordering is by default saved in '$outname.csv'" 1>&2
	echo "	Configuration of to-be-tested cases specified in 'config.sh'" 1>&2
	echo "Usage: $0 [switches] " 1>&2
	echo "Switches:" 1>&2
	echo "    -u . .............. reuse previous temporary files {default: create new files}" 1>&2 
	#echo "    -fp ............... use only the first page {default: all pages}" 1>&2 
	echo "    -x ................ exclude files of the same family (LO, MS),...) {default: all}" 1>&2 
	echo "    -s APP ............ print only for the APP application(s) {default: as specified in config.sh}" 1>&2 
	echo "    -c CASE ........... process only the CASE case(s) {default: as specified in config.sh}" 1>&2 
	echo "    -f FMT ............ process only the FMT format(s) {default: as specified in config.sh}" 1>&2 
	echo "    -p ................ split in individual files according to FMT and CASE {default: single file}" 1>&2 
	echo "    -d ................ resolution of the converted pdf document {default: $dpi dpi}" 1>&2 
	echo "    -o ................ file to saved output (views and information) {default: $outname}" 1>&2 
	echo "    -h --help ......... this usage" 1>&2
	exit 1
}

function createpair
{
	if [ "$reuse" -eq 1 ]
	then
		if [ ! -e $1 ]
		then
			echo Creating $1
			docompare.py -a $2 -d $dpi $fp -o $1 $srcfile $l
		else
			echo Using cached $1
		fi
	else
		echo Creating $1
		docompare.py -a $2 -d $dpi $fp -o $1 $srcfile $l
	fi
}

function genpairs 
{
	pairlists=
	pairlistp=
	pairlistl=
	for d in $1; do 
		#first create a list of files to compare
		for s in $printapps; do #source app
			if [ -d $d/$s ]; then
				src=`source$s`	#suffix of the default source of the $s program
				srcfile="$d/$s/$d-$s.$src.$s.pdf"
				targetlist=
				for t in $printapps; do	#target apps
					for f in $2; do
						fname="$d/$s/$d-$s.$f.$t.pdf"
						#if [ $exsame ] && [ "${s:0:1}" == "${t:0:1}" ] 
						#then 
							#continue
						#fi
						if [ -f $fname ]; then
							targetlist=`echo $targetlist $fname`
						fi
					done
				done
				#generate the test pairs
				for l in $targetlist; do
					# get format and target application from the name
					f1=`basename $l` 
					f2="${f1%.*}"
					tgt="${f2##*.}"
					f3="${f2%.*}"
					fmt="${f3##*.}"

					pairname=$d-$s-$fmt-$tgt.pdf
					#side-by-side
					createpair "$fview-s-$pairname" "-s"
					pairlists="$pairlists $fview-s-$pairname"
					#page overlays
					createpair "$fview-p-$pairname" "-p"
					pairlistp="$pairlistp $fview-p-$pairname"
					#line aligned overlays
					createpair "$fview-l-$pairname" "-l"
					pairlistl="$pairlistl $fview-l-$pairname"
				done
			fi
		done
	done
}


function sel1
{
	echo $1 | cut --delimiter=- --fields=$2
}

function sel2
{
	echo "$1" | cut --delimiter=: --fields=$2
}

function gensummary
{

	#get index description from one pair view file
	ef=`echo ${pairlists}|cut -d " " -f 1`
	t=`exiftool -Custom1 $ef`
	echo "Extracting statisctics from pdf files" 1>&2
	echo "View number,View pair file,Test case,Format, Source app,Target app,$idesc">$1.csv
	i=1
	for f  in $pairlists;
	do
		b=`basename $f .pdf`
		info="$i,$f,`sel1 $b 2`,`sel1 $b 4`,`sel1 $b 3`,`sel1 $b 5`"
		if [ -f $f ]; then
			t=`exiftool -Custom1 $f`
			if [ ! $firstdone ]
			then
				idesc="`sel2 "$t" 2`,`sel2 "$t" 4`,`sel2 "$t" 6`,`sel2 "$t" 8`,`sel2 "$t" 10`,`sel2 "$t" 12`,`sel2 "$t" 14`,`sel2 "$t" 16`,`sel2 "$t" 18`"
				echo "View number,View pair file,Test case,Format, Source app,Target app,$idesc">$1.csv
				firstdone=1
			fi
			idesc="`sel2 "$t" 3`,`sel2 "$t" 5`,`sel2 "$t" 7`,`sel2 "$t" 9`,`sel2 "$t" 11`,`sel2 "$t" 13`,`sel2 "$t" 15`,`sel2 "$t" 17`,`sel2 "$t" 19`"
			#echo $tags

			echo $info 1>&2
			echo $info "," $idesc >>$1.csv
			zz=
			if [ "$i" -lt "10" ]
			then
				zz=0
			fi
			if [ "$i" -lt "100" ]
			then
				zz=0$zz
			fi
		else
			echo $info "," "File Missing" 1>&2
		fi
		let i=i+1
	done
	echo "Views writen to '$1.pdf'" 1>&2
	echo "Description of types and ordering written to '$1.csv'" 1>&2
}


if [ ! -e "config.sh" ]
then
	echo "$0: The current directory does not contain the 'config.sh' file." 1>&2
	echo "	You can run the program only in a directory with the 'config.sh' file and existing structure of the directories with tests." 1>&2
fi

# read configuration
. config.sh
. $FTPATH/officeconf.sh 

while [ $# -gt 0 ]
do
	case "$1" in
		-h* | --help*)
			usage
			shift
			;;
		-u*)
			reuse=1
			shift
			;;
		-r*)
			shift
			;;
		-p*)
			split=1
			shift
			;;
		-x*)
			exsame=1
			shift
			;;
		-a*)
			shift
			;;
		-d)
			shift
			dpi=$1
			shift
			;;
		-c)
			shift
			cases=$1
			shift
			;;
		-s)
			shift
			printapps=$1
			shift
			;;
		#-fp*)
			#fp="-fp"
			#shift
			#;;
		-f)
			shift
			formats=$1
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

echo "Generating report for: " 1>&2
echo "Cases: $cases" 1>&2
echo "Formats: $formats" 1>&2
echo "Source Applications: $sourceapps" 1>&2
echo "Print Applications: $printapps" 1>&2

fview=$fdir/pair
fview=$fview:$dpi

if [ ! -d $fdir ] 
then
	mkdir $fdir
fi

if [ "$split" -eq "1" ]
then
	for d in $cases; do 
		for f in $formats; do
			genpairs "$d" "$f"
			firstdone=
			gensummary $outname-$d-$f
		done
	done
else
	genpairs "$cases" "$formats"
	pdftk $pairlists output $outname-s.pdf
	pdftk $pairlistp output $outname-p.pdf
	pdftk $pairlistl output $outname-l.pdf
	gensummary $outname
fi


