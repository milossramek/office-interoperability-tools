#! /bin/bash
# configuration of tested application

# No configuration necessary below this line, unless a new office suite is added
# The application/conversion tools and paths (see below) shoud be set in environment
# if not specified, the corresponding test will be ignored

#site specific settings to be read from environment

# start OOo or AOO server, in case we have it
function startOOoServer()
{
	local apptype=`echo $1|cut -b -2`
	local appversion=`echo $1|cut -b 3-4`
	local pa=PATH
	local po=PORT
	#if [ $apptype == "OO" ]
	if [ $apptype == "OO" -o $apptype == "AO" ]
	then
		local app=$apptype$appversion$pa/soffice
		eval app=\$$app
		local port=$apptype$appversion$po
		eval port=\$$port
		if [ -e "$app" ]
		then
			#echo $app "-accept=socket,host=localhost,port=$port;urp;StarOffice.ServiceManager" -norestore -nofirststartwizard -nologo -headless & 
			$app "-accept=socket,host=localhost,port=$port;urp;StarOffice.ServiceManager" -norestore -nofirststartwizard -nologo -headless & 
			sleep 3s
			#nmap -p 8100-8200 localhost
		fi
	fi
}

# kill OOo or AOO server, in case we have it
function killOOoServer()
{
	local apptype=`echo $1|cut -b -2`
	local appversion=`echo $1|cut -b 3-4`
	if [ $apptype == "OO" -o $apptype == "AO" ]
	then
		killall soffice 2>/dev/null
	fi
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

#the LO family
if [ -x "$LO35PROG" ]
then
	canconvertLO35=1	# we can convert from source type to target types
	canprintLO35=1		# we can print to pdf
	#usage: convLO35 docx file.odf #converts the given file to docx
	convLO35() { $LO35PROG --headless --convert-to $1 $2 &> /dev/null; }
	sourceLO35() { echo "odt"; }
	targetLO35() { echo "rtf docx doc"; }
	#usage: printLO35 pdf file.rtf #prints the given file to pdf
	printLO35() { $LO35PROG --headless --convert-to pdf $1 &> /dev/null; }
fi

if [ -x "$LO36PROG" ]
then
	canconvertLO36=1	# we can convert from source type to target types
	canprintLO36=1		# we can print to pdf
	#usage: convLO36 docx file.odf #converts the given file to docx
	convLO36() { $LO36PROG --headless --convert-to $1 $2 &> /dev/null; }
	sourceLO36() { echo "odt"; }
	targetLO36() { echo "rtf docx doc"; }
	#usage: printLO36 pdf file.rtf #prints the given file to pdf
	printLO36() { $LO36PROG --headless --convert-to pdf $1 &> /dev/null; }
fi

if [ -x "$LO40PROG" ]
then
	canconvertLO40=1	# we can convert from source type to target types
	canprintLO40=1		# we can print to pdf
	#usage: convLO40 docx file.odf #converts the given file to docx
	convLO40() { $LO40PROG --headless --convert-to $1 $2 &> /dev/null; }
	sourceLO40() { echo "odt"; }
	targetLO40() { echo "rtf docx doc"; }
	#usage: printLO40 pdf file.rtf #prints the given file to pdf
	printLO40() { $LO40PROG --headless --convert-to pdf $1 &> /dev/null; }
fi

if [ -x "$LO41PROG" ]
then
	canconvertLO41=1	# we can convert from source type to target types
	canprintLO41=1		# we can print to pdf
	#usage: convLO41 docx file.odf #converts the given file to docx
	convLO41() { $LO41PROG --headless --convert-to $1 $2 &> /dev/null; }
	sourceLO41() { echo "odt"; }
	targetLO41() { echo "rtf docx doc"; }
	#usage: printLO41 pdf file.rtf #prints the given file to pdf
	printLO41() { $LO41PROG --headless --convert-to pdf $1 &> /dev/null; }
fi

if [ -x "$LO42PROG" ]
then
	canconvertLO42=1	# we can convert from source type to target types
	canprintLO42=1		# we can print to pdf
	#usage: convLO42 docx file.odf #converts the given file to docx
	convLO42() { $LO42PROG --headless --convert-to $1 $2 &> /dev/null; }
	sourceLO42() { echo "odt"; }
	targetLO42() { echo "rtf docx doc"; }
	#usage: printLO42 pdf file.rtf #prints the given file to pdf
	printLO42() { $LO42PROG --headless --convert-to pdf $1 &> /dev/null; }
fi

if [ -x "$LO43PROG" ]
then
	canconvertLO43=1	# we can convert from source type to target types
	canprintLO43=1		# we can print to pdf
	#usage: convLO43 docx file.odf #converts the given file to docx
	convLO43() { $LO43PROG --headless --convert-to $1 $2 &> /dev/null; }
	sourceLO43() { echo "odt"; }
	targetLO43() { echo "rtf docx doc"; }
	#usage: printLO43 pdf file.rtf #prints the given file to pdf
	printLO43() { $LO43PROG --headless --convert-to pdf $1 &> /dev/null; }
fi

if [ -x "$LO44PROG" ]
then
	canconvertLO44=1	# we can convert from source type to target types
	canprintLO44=1		# we can print to pdf
	#usage: convLO44 docx file.odf #converts the given file to docx
	convLO44() { $LO44PROG --headless --convert-to $1 $2 &> /dev/null; }
	sourceLO44() { echo "odt"; }
	targetLO44() { echo "rtf docx doc"; }
	#usage: printLO44 pdf file.rtf #prints the given file to pdf
	printLO44() { $LO44PROG --headless --convert-to pdf $1 &> /dev/null; }
fi

if [ -x "$LO50PROG" ]
then
	canconvertLO50=1	# we can convert from source type to target types
	canprintLO50=1		# we can print to pdf
	#usage: convLO50 docx file.odf #converts the given file to docx
	convLO50() { $LO50PROG --headless --convert-to $1 $2 &> /dev/null; }
	sourceLO50() { echo "odt"; }
	targetLO50() { echo "rtf docx doc"; }
	#usage: printLO50 pdf file.rtf #prints the given file to pdf
	printLO50() { $LO50PROG --headless --convert-to pdf $1 &> /dev/null; }
fi

# git master
if [ -x "$LO4MPROG" ]
then
	canconvertLO4M=1	# we can convert from source type to target types
	canprintLO4M=1		# we can print to pdf
	#usage: convLO4M docx file.odf #converts the given file to docx
	convLO4M() { $LO4MPROG --headless --convert-to $1 $2 &> /dev/null; }
	sourceLO4M() { echo "odt"; }
	targetLO4M() { echo "rtf docx doc"; }
	#usage: printLO4M pdf file.rtf #prints the given file to pdf
	printLO4M() { $LO4MPROG --headless --convert-to pdf $1 &> /dev/null; }
fi

#Open Office 3.3
if [ -e "$OO33PROG" ]		# this is not an executable, so only verify existence
then
	convOO33() { $OO33PATH/python $OO33PROG $OO33PORT $1 $2 &> /dev/null; }
	sourceOO33() { echo "odt"; }
	targetOO33() { echo "rtf doc"; }	#OO33 cannot write docx
	printOO33() { $OO33PATH/python $OO33PROG $OO33PORT pdf $1 &> /dev/null; }
	canconvertOO33=1	# we can convert from source type to target types
	canprintOO33=1		# we can print to pdf
fi

#Apache Open Office 3.4
if [ -e "$AO34PROG" ]		# this is not an executable, so only verify existence
then
	convAO34() { $AO34PATH/python $AO34PROG $AO34PORT $1 $2 &> /dev/null; }
	sourceAO34() { echo "odt"; }
	targetAO34() { echo "rtf doc"; }	#AOO cannot write docx
	printAO34() { $AO34PATH/python $AO34PROG $AO34PORT pdf $1 &> /dev/null; }
	canconvertAO34=1	# we can convert from source type to target types
	canprintAO34=1		# we can print to pdf
fi

#Apache Open Office 4.0
if [ -e "$AO40PROG" ]		# this is not an executable, so only verify existence
then
	convAO40() { $AO40PATH/python $AO40PROG $AO40PORT $1 $2 &> /dev/null; }
	sourceAO40() { echo "odt"; }
	targetAO40() { echo "rtf doc"; }	#AOO cannot write docx
	printAO40() { $AO40PATH/python $AO40PROG $AO40PORT pdf $1 &> /dev/null; }
	canconvertAO40=1	# we can convert from source type to target types
	canprintAO40=1		# we can print to pdf
fi

#Apache Open Office 4.1
if [ -e "$AO41PROG" ]		# this is not an executable, so only verify existence
then
	convAO41() { $AO41PATH/python $AO41PROG $AO41PORT $1 $2 &> /dev/null; }
	sourceAO41() { echo "odt"; }
	targetAO41() { echo "rtf doc"; }	#AOO cannot write docx
	printAO41() { $AO41PATH/python $AO41PROG $AO41PORT pdf $1 &> /dev/null; }
	canconvertAO41=1	# we can convert from source type to target types
	canprintAO41=1		# we can print to pdf
fi

#the MSO family
#Microsoft Office 2007
if [ -x "$MS07PROG" ]
then
	canconvertMS07=1	# we can convert from source type to target types
	canprintMS07=1		# we can print to pdf
	convMS07() { $MS07PROG --format=$1 $2; }
	sourceMS07() { echo "docx"; }
	targetMS07() { echo "rtf odt doc"; }
	printMS07() { $MS07PROG --format=pdf $1; }
fi

#Microsoft Office 2010
if [ -x "$MS10PROG" ]
then
	canconvertMS10=1	# we can convert from source type to target types
	canprintMS10=1		# we can print to pdf
	convMS10() { $MS10PROG --format=$1 $2; }
	sourceMS10() { echo "docx"; }
	targetMS10() { echo "rtf odt doc"; }
	printMS10() { $MS10PROG --format=pdf $1; }
fi

#Microsoft Office on Linux using Wine
#defined in .bashrc as
#export MSWINEPROG="/usr/bin/wine"
#requires the OfficeConvert.exe and its dlls in ./msoffice2010/drive_c/windows/
if [ -x "$MSWINEPROG" ]
then
	canconvertMSWINE=1	# we can convert from source type to target types
	canprintMSWINE=1		# we can print to pdf
	convMSWINE() { $MSWINEPROG OfficeConvert --format=$1 $2; }
	sourceMSWINE() { echo "docx"; }
	targetMSWINE() { echo "rtf odt doc"; }
	printMSWINE() { $MSWINEPROG OfficeConvert --format=pdf $1; }
fi

#Microsoft Office 2013
if [ -x "$MS13PROG" ]
then
	canconvertMS13=1	# we can convert from source type to target types
	canprintMS13=1		# we can print to pdf
	convMS13() { $MS13PROG --format=$1 $2; }
	sourceMS13() { echo "docx"; }
	targetMS13() { echo "rtf odt doc"; }
	printMS13() { $MS13PROG --format=pdf $1; }
fi

# others
#Google docs
if [ -x "$GDCONVERT" ]
then
	canprintGD=1		# we can print to pdf
	canconvertGD=1	# if we can convert from source type to target types
	convGD() { 0; }	# 
	sourceGD() { 0; }	#do not set, we do not use GD as source application (
	targetGD() { 0; }
	printGD() { $GDCONVERT pdf $1; }
fi

#Calligra Words 2.7
#export CW27PROG="/usr/bin/calligrawords"
if [ -x "$CW27PROG" ]
then
	canprintCW27=1		# we can print to pdf
	canconvertCW27=0	# if we can convert from source type to target types
	convCW27() { 0; }	# 
	sourceCW27() { 0; }	#do not set, we do not use Calligra Words as source application (
	targetCW27() { 0; }
	printCW27() { $CW27PROG --export-pdf --export-filename=${1%.*}.pdf $1 2> /dev/null; }
fi

#Abiword 2.9
#defined in .bashrc as
#export AW29PROG="/usr/bin/abiword"
if [ -x "$AW29PROG" ]
then
	canprintAW29=1		# we can print to pdf
	canconvertAW29=0	# if we can convert from source type to target types
	convAW29() { 0; }	# 
	sourceAW29() { 0; }	#do not set, we do not use Abiword as source application (
	targetAW29() { 0; }
	printAW29() { $AW29PROG -t pdf $1; }
fi

# libreoffice bisection git repositories
#path to bibisection repositories defined in .bashrc as
#export LO_BISECT_PATH="/mnt/data/milos/LO"
function bibilo () {
	if [ -x "$2" ] 
	then
		${1}PROG=$2
		canconvert${1}=1	# we can convert from source type to target types
		canprint${1}=1		# we can print to pdf
		conv${1}() { ${1}PROG --headless --convert-to $1 $2 &> /dev/null; }
		source${1}() { echo "odt"; }
		target${1}() { echo "rtf docx doc"; }
		print${1}() { ${1}PROG --headless --convert-to pdf $1 &> /dev/null; }
	fi
}

# oldest/... and latest/... are oldest an latest version stored in the given repository
if [ -d "$xLO_BISECT_PATH" ]
then
	bibilo BB43AO $LO_BISECT_PATH/bibisect-43all/oldest/program/soffice
	bibilo BB42DO $LO_BISECT_PATH/lo-linux-dbgutil-daily-till42/oldest/program/soffice
	bibilo BB43DO $LO_BISECT_PATH/lo-linux-dbgutil-daily-till43/oldest/program/soffice
	bibilo BB44DO $LO_BISECT_PATH/lo-linux-dbgutil-daily-till44/oldest/program/soffice
	bibilo BB50DO $LO_BISECT_PATH/lo-linux-dbgutil-daily-till50/oldest/program/soffice
	bibilo BB51DO $LO_BISECT_PATH/lo-linux-dbgutil-daily-till51/oldest/program/soffice
	bibilo BB52DO $LO_BISECT_PATH/lo-linux-dbgutil-daily-till52/oldest/program/soffice
	bibilo BB53DO $LO_BISECT_PATH/lo-linux-dbgutil-daily/oldest/program/soffice

	bibilo BB43AL $LO_BISECT_PATH/bibisect-43all/latest/program/soffice
	bibilo BB42DL $LO_BISECT_PATH/lo-linux-dbgutil-daily-till42/latest/program/soffice
	bibilo BB43DL $LO_BISECT_PATH/lo-linux-dbgutil-daily-till43/latest/program/soffice
	bibilo BB44DL $LO_BISECT_PATH/lo-linux-dbgutil-daily-till44/latest/program/soffice
	bibilo BB50DL $LO_BISECT_PATH/lo-linux-dbgutil-daily-till50/latest/program/soffice
	bibilo BB51DL $LO_BISECT_PATH/lo-linux-dbgutil-daily-till51/latest/program/soffice
	bibilo BB52DL $LO_BISECT_PATH/lo-linux-dbgutil-daily-till52/latest/program/soffice
	bibilo BB53DL $LO_BISECT_PATH/lo-linux-dbgutil-daily/latest/program/soffice
fi

if [ -d "$LO_BISECT_PATH" ]
then

	if [ -x "$LO_BISECT_PATH/bibisect-43all/oldest/program/soffice" ] 
	then
		BB43AOPROG=$LO_BISECT_PATH/bibisect-43all/oldest/program/soffice
		canconvertBB43AO=1	# we can convert from source type to target types
		canprintBB43AO=1		# we can print to pdf
		#usage: convLO4M docx file.odf #converts the given file to docx
		convBB43AO() { $BB43AOPROG --headless --convert-to $1 $2 &> /dev/null; }
		sourceBB43AO() { echo "odt"; }
		targetBB43AO() { echo "rtf docx doc"; }
		#usage: printLO4M pdf file.rtf #prints the given file to pdf
		printBB43AO() { $BB43AOPROG --headless --convert-to pdf $1 &> /dev/null; }
	fi
	if [ -x "$LO_BISECT_PATH/bibisect-43all/latest/program/soffice" ] 
	then
		BB43ALPROG=$LO_BISECT_PATH/bibisect-43all/latest/program/soffice
		canconvertBB43AL=1	# we can convert from source type to target types
		canprintBB43AL=1		# we can print to pdf
		#usage: convLO4M docx file.odf #converts the given file to docx
		convBB43AL() { $BB43ALPROG --headless --convert-to $1 $2 &> /dev/null; }
		sourceBB43AL() { echo "odt"; }
		targetBB43AL() { echo "rtf docx doc"; }
		#usage: printLO4M pdf file.rtf #prints the given file to pdf
		printBB43AL() { $BB43ALPROG --headless --convert-to pdf $1 &> /dev/null; }
	fi

	if [ -x "$LO_BISECT_PATH/lo-linux-dbgutil-daily-till42/oldest/program/soffice" ] 
	then
		BB42DOPROG=$LO_BISECT_PATH/lo-linux-dbgutil-daily-till42/oldest/program/soffice
		canconvertBB42DO=1	# we can convert from source type to target types
		canprintBB42DO=1		# we can print to pdf
		#usage: convLO4M docx file.odf #converts the given file to docx
		convBB42DO() { $BB42DOPROG --headless --convert-to $1 $2 &> /dev/null; }
		sourceBB42DO() { echo "odt"; }
		targetBB42DO() { echo "rtf docx doc"; }
		#usage: printLO4M pdf file.rtf #prints the given file to pdf
		printBB42DO() { $BB42DOPROG --headless --convert-to pdf $1 &> /dev/null; }
	fi
	if [ -x "$LO_BISECT_PATH/lo-linux-dbgutil-daily-till42/latest/program/soffice" ] 
	then
		BB42DLPROG=$LO_BISECT_PATH/lo-linux-dbgutil-daily-till42/latest/program/soffice
		canconvertBB42DL=1	# we can convert from source type to target types
		canprintBB42DL=1		# we can print to pdf
		#usage: convLO4M docx file.odf #converts the given file to docx
		convBB42DL() { $BB42DLPROG --headless --convert-to $1 $2 &> /dev/null; }
		sourceBB42DL() { echo "odt"; }
		targetBB42DL() { echo "rtf docx doc"; }
		#usage: printLO4M pdf file.rtf #prints the given file to pdf
		printBB42DL() { $BB42DLPROG --headless --convert-to pdf $1 &> /dev/null; }
	fi

	if [ -x "$LO_BISECT_PATH/lo-linux-dbgutil-daily-till43/oldest/program/soffice" ] 
	then
		BB43DOPROG=$LO_BISECT_PATH/lo-linux-dbgutil-daily-till43/oldest/program/soffice
		canconvertBB43DO=1	# we can convert from source type to target types
		canprintBB43DO=1		# we can print to pdf
		#usage: convLO4M docx file.odf #converts the given file to docx
		convBB43DO() { $BB43DOPROG --headless --convert-to $1 $2 &> /dev/null; }
		sourceBB43DO() { echo "odt"; }
		targetBB43DO() { echo "rtf docx doc"; }
		#usage: printLO4M pdf file.rtf #prints the given file to pdf
		printBB43DO() { $BB43DOPROG --headless --convert-to pdf $1 &> /dev/null; }
	fi
	if [ -x "$LO_BISECT_PATH/lo-linux-dbgutil-daily-till43/latest/program/soffice" ] 
	then
		BB43DLPROG=$LO_BISECT_PATH/lo-linux-dbgutil-daily-till43/latest/program/soffice
		canconvertBB43DL=1	# we can convert from source type to target types
		canprintBB43DL=1		# we can print to pdf
		#usage: convLO4M docx file.odf #converts the given file to docx
		convBB43DL() { $BB43DLPROG --headless --convert-to $1 $2 &> /dev/null; }
		sourceBB43DL() { echo "odt"; }
		targetBB43DL() { echo "rtf docx doc"; }
		#usage: printLO4M pdf file.rtf #prints the given file to pdf
		printBB43DL() { $BB43DLPROG --headless --convert-to pdf $1 &> /dev/null; }
	fi

	if [ -x "$LO_BISECT_PATH/lo-linux-dbgutil-daily-till44/oldest/program/soffice" ] 
	then
		BB44DOPROG=$LO_BISECT_PATH/lo-linux-dbgutil-daily-till44/oldest/program/soffice
		canconvertBB44DO=1	# we can convert from source type to target types
		canprintBB44DO=1		# we can print to pdf
		#usage: convLO4M docx file.odf #converts the given file to docx
		convBB44DO() { $BB44DOPROG --headless --convert-to $1 $2 &> /dev/null; }
		sourceBB44DO() { echo "odt"; }
		targetBB44DO() { echo "rtf docx doc"; }
		#usage: printLO4M pdf file.rtf #prints the given file to pdf
		printBB44DO() { $BB44DOPROG --headless --convert-to pdf $1 &> /dev/null; }
	fi
	if [ -x "$LO_BISECT_PATH/lo-linux-dbgutil-daily-till44/latest/program/soffice" ] 
	then
		BB44DLPROG=$LO_BISECT_PATH/lo-linux-dbgutil-daily-till44/latest/program/soffice
		canconvertBB44DL=1	# we can convert from source type to target types
		canprintBB44DL=1		# we can print to pdf
		#usage: convLO4M docx file.odf #converts the given file to docx
		convBB44DL() { $BB44DLPROG --headless --convert-to $1 $2 &> /dev/null; }
		sourceBB44DL() { echo "odt"; }
		targetBB44DL() { echo "rtf docx doc"; }
		#usage: printLO4M pdf file.rtf #prints the given file to pdf
		printBB44DL() { $BB44DLPROG --headless --convert-to pdf $1 &> /dev/null; }
	fi

	if [ -x "$LO_BISECT_PATH/lo-linux-dbgutil-daily-till50/oldest/program/soffice" ] 
	then
		BB50DOPROG=$LO_BISECT_PATH/lo-linux-dbgutil-daily-till50/oldest/program/soffice
		canconvertBB50DO=1	# we can convert from source type to target types
		canprintBB50DO=1		# we can print to pdf
		#usage: convLO4M docx file.odf #converts the given file to docx
		convBB50DO() { $BB50DOPROG --headless --convert-to $1 $2 &> /dev/null; }
		sourceBB50DO() { echo "odt"; }
		targetBB50DO() { echo "rtf docx doc"; }
		#usage: printLO4M pdf file.rtf #prints the given file to pdf
		printBB50DO() { $BB50DOPROG --headless --convert-to pdf $1 &> /dev/null; }
	fi
	if [ -x "$LO_BISECT_PATH/lo-linux-dbgutil-daily-till50/latest/program/soffice" ] 
	then
		BB50DLPROG=$LO_BISECT_PATH/lo-linux-dbgutil-daily-till50/latest/program/soffice
		canconvertBB50DL=1	# we can convert from source type to target types
		canprintBB50DL=1		# we can print to pdf
		#usage: convLO4M docx file.odf #converts the given file to docx
		convBB50DL() { $BB50DLPROG --headless --convert-to $1 $2 &> /dev/null; }
		sourceBB50DL() { echo "odt"; }
		targetBB50DL() { echo "rtf docx doc"; }
		#usage: printLO4M pdf file.rtf #prints the given file to pdf
		printBB50DL() { $BB50DLPROG --headless --convert-to pdf $1 &> /dev/null; }
	fi

	if [ -x "$LO_BISECT_PATH/lo-linux-dbgutil-daily-till51/oldest/program/soffice" ] 
	then
		BB51DOPROG=$LO_BISECT_PATH/lo-linux-dbgutil-daily-till51/oldest/program/soffice
		canconvertBB51DO=1	# we can convert from source type to target types
		canprintBB51DO=1		# we can print to pdf
		#usage: convLO4M docx file.odf #converts the given file to docx
		convBB51DO() { $BB51DOPROG --headless --convert-to $1 $2 &> /dev/null; }
		sourceBB51DO() { echo "odt"; }
		targetBB51DO() { echo "rtf docx doc"; }
		#usage: printLO4M pdf file.rtf #prints the given file to pdf
		printBB51DO() { $BB51DOPROG --headless --convert-to pdf $1 &> /dev/null; }
	fi
	if [ -x "$LO_BISECT_PATH/lo-linux-dbgutil-daily-till51/latest/program/soffice" ] 
	then
		BB51DLPROG=$LO_BISECT_PATH/lo-linux-dbgutil-daily-till51/latest/program/soffice
		canconvertBB51DL=1	# we can convert from source type to target types
		canprintBB51DL=1		# we can print to pdf
		#usage: convLO4M docx file.odf #converts the given file to docx
		convBB51DL() { $BB51DLPROG --headless --convert-to $1 $2 &> /dev/null; }
		sourceBB51DL() { echo "odt"; }
		targetBB51DL() { echo "rtf docx doc"; }
		#usage: printLO4M pdf file.rtf #prints the given file to pdf
		printBB51DL() { $BB51DLPROG --headless --convert-to pdf $1 &> /dev/null; }
	fi

	if [ -x "$LO_BISECT_PATH/lo-linux-dbgutil-daily-till52/oldest/program/soffice" ] 
	then
		BB52DOPROG=$LO_BISECT_PATH/lo-linux-dbgutil-daily-till52/oldest/program/soffice
		canconvertBB52DO=1	# we can convert from source type to target types
		canprintBB52DO=1		# we can print to pdf
		#usage: convLO4M docx file.odf #converts the given file to docx
		convBB52DO() { $BB52DOPROG --headless --convert-to $1 $2 &> /dev/null; }
		sourceBB52DO() { echo "odt"; }
		targetBB52DO() { echo "rtf docx doc"; }
		#usage: printLO4M pdf file.rtf #prints the given file to pdf
		printBB52DO() { $BB52DOPROG --headless --convert-to pdf $1 &> /dev/null; }
	fi
	if [ -x "$LO_BISECT_PATH/lo-linux-dbgutil-daily-till52/latest/program/soffice" ] 
	then
		BB52DLPROG=$LO_BISECT_PATH/lo-linux-dbgutil-daily-till52/latest/program/soffice
		canconvertBB52DL=1	# we can convert from source type to target types
		canprintBB52DL=1		# we can print to pdf
		#usage: convLO4M docx file.odf #converts the given file to docx
		convBB52DL() { $BB52DLPROG --headless --convert-to $1 $2 &> /dev/null; }
		sourceBB52DL() { echo "odt"; }
		targetBB52DL() { echo "rtf docx doc"; }
		#usage: printLO4M pdf file.rtf #prints the given file to pdf
		printBB52DL() { $BB52DLPROG --headless --convert-to pdf $1 &> /dev/null; }
	fi

	if [ -x "$LO_BISECT_PATH/lo-linux-dbgutil-daily/oldest/program/soffice" ] 
	then
		BB53DOPROG=$LO_BISECT_PATH/lo-linux-dbgutil-daily/oldest/program/soffice
		canconvertBB53DO=1	# we can convert from source type to target types
		canprintBB53DO=1		# we can print to pdf
		#usage: convLO4M docx file.odf #converts the given file to docx
		convBB53DO() { $BB53DOPROG --headless --convert-to $1 $2 &> /dev/null; }
		sourceBB53DO() { echo "odt"; }
		targetBB53DO() { echo "rtf docx doc"; }
		#usage: printLO4M pdf file.rtf #prints the given file to pdf
		printBB53DO() { $BB53DOPROG --headless --convert-to pdf $1 &> /dev/null; }
	fi
	if [ -x "$LO_BISECT_PATH/lo-linux-dbgutil-daily/latest/program/soffice" ] 
	then
		BB53DLPROG=$LO_BISECT_PATH/lo-linux-dbgutil-daily/latest/program/soffice
		canconvertBB53DL=1	# we can convert from source type to target types
		canprintBB53DL=1		# we can print to pdf
		#usage: convLO4M docx file.odf #converts the given file to docx
		convBB53DL() { $BB53DLPROG --headless --convert-to $1 $2 &> /dev/null; }
		sourceBB53DL() { echo "odt"; }
		targetBB53DL() { echo "rtf docx doc"; }
		#usage: printLO4M pdf file.rtf #prints the given file to pdf
		printBB53DL() { $BB53DLPROG --headless --convert-to pdf $1 &> /dev/null; }
	fi

fi
