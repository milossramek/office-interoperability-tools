#! /bin/bash
#set -o xtrace #be verbose

function usage
{
	echo "$0: Bibisecting LO-MSO compatibility errors using a bibisect git repository " 1>&2
	echo "	Allowed formats: all text formats supported by both LO and MSO" 1>&2
	echo "Usage: $0 [switches] file.docx" 1>&2
	echo "Switches:" 1>&2
	echo "    -i . .............. document to be tested" 1>&2 
	echo "    -r . .............. roundtrip test {default: print test}" 1>&2 
	echo "    -g int ............ grade regarded to be bad {3}" 1>&2
	echo "    -h --help ......... this usage" 1>&2
	exit 1
}

#definitions
if [ ! -f gitversions.sh ] 
then
	echo "Probably wrong working directory, file 'gitversions.sh' not found"  
	exit 1
fi

source gitversions.sh
roundtrip=""		#print test is default
ifile=""
grade=3


while [ $# -gt 0 ]
do
	case "$1" in
		-h* | --help*)
			usage
			shift
			;;
		-i)
			shift
			ifile=$1
			shift
			;;
		-g)
			shift
			grade=$1
			shift
			;;
		-r)
			roundtrip="-r"
			shift
			;;
		*)
			usage
			break
			;;
	esac
done

if [[ x$ifile = "x" ]]
then
	usage
	exit 1
fi

if [ ! -e $ifile ]
then

	echo "File $ifile does not exist" 1>&2
	exit 1
fi

if [[ x$roundtrip = "x" ]]
then
	testtype="print"
else
	testtype="roundtrip"
fi

#test if bibisecting is possible
dogood.sh -g $grade -i $ifile $roundtrip -a latest/program/soffice
lstatus=$?

if [ $lstatus -gt 1 ]
then
	echo "Command  'dogood.sh -g $grade -i $ifile $roundtrip' has failed."
	exit 1
fi
if [ $lstatus -eq 1 ]
then
	echo "A $testtype test, the latest revision is bad"
else
	echo "A $testtype test, the latest revision is good"
fi


dogood.sh -g $grade -i $ifile $roundtrip -a oldest/program/soffice
ostatus=$?
if [ $ostatus -eq 255 ]
then
	echo "Command  'dogood.sh -g $grade -i $ifile $roundtrip' has failed."
	exit 1
fi
if [ $ostatus -eq 1 ]
then
	echo "A $testtype test, the oldest revision is bad"
else
	echo "A $testtype test, the oldest revision is good"
fi

if [ $lstatus -eq $ostatus ]
then
	if [ $ostatus -eq 1 ]
	then
		rslt="bad"
	else
		rslt="good"
	fi
	echo "Both oldest and latest are $rslt, not bibisecting"
	echo "Both oldest and latest are $rslt, not bibisecting"  > $ifile.$testtype.bisectlog
	exit 1
fi

if [ $ostatus -ne 0 ]
then
	echo "Searching for progression"
	echo "Searching for progression" > $ifile.$testtype.bisectlog
else
	echo "Searching for regression"
	echo "Searching for regression" > $ifile.$testtype.bisectlog
fi

#prepare the environment
git reset --hard
rm -rf opt
git checkout -- opt 2> /dev/null
git checkout -- commitmsg autogen.log ccache.log dev-install.log make.log instdir.log 2> /dev/null
rm -f instdir.log

#git bisect start bad good

rm -f $ifile.*

git bisect start $latest $oldest
# bibisect regressions or progressions, see http://stackoverflow.com/questions/15407075/how-could-i-use-git-bisect-to-find-the-first-good-commit

if [ $ostatus -ne 0 ]
then
	git bisect run bash -c "! dogood.sh -g $grade -i $ifile $roundtrip -a opt/program/soffice"
else
	git bisect run dogood.sh -g $grade -i $ifile $roundtrip -a opt/program/soffice
fi

git log '--format=format:%h -- %ai -- %an%d' --all |grep bisect >> $ifile.$testtype.bisectlog
