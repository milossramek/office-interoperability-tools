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

#the LO family
if [ -x "$LO35PROG" ]
then
	canconvertLO35=1	# we can convert from source type to target types
	canprintLO35=1		# we can print to pdf
	#usage: convLO35 docx file.odf #converts the given file to docx
	convLO35() { $LO35PROG --headless --convert-to $1 $2 > /dev/null; }
	sourceLO35() { echo "odt"; }
	targetLO35() { echo "rtf docx doc"; }
	#usage: printLO35 pdf file.rtf #prints the given file to pdf
	printLO35() { $LO35PROG --headless --convert-to pdf $1 > /dev/null; }
fi

if [ -x "$LO36PROG" ]
then
	canconvertLO36=1	# we can convert from source type to target types
	canprintLO36=1		# we can print to pdf
	#usage: convLO36 docx file.odf #converts the given file to docx
	convLO36() { $LO36PROG --headless --convert-to $1 $2 > /dev/null; }
	sourceLO36() { echo "odt"; }
	targetLO36() { echo "rtf docx doc"; }
	#usage: printLO36 pdf file.rtf #prints the given file to pdf
	printLO36() { $LO36PROG --headless --convert-to pdf $1 > /dev/null; }
fi

if [ -x "$LO40PROG" ]
then
	canconvertLO40=1	# we can convert from source type to target types
	canprintLO40=1		# we can print to pdf
	#usage: convLO40 docx file.odf #converts the given file to docx
	convLO40() { $LO40PROG --headless --convert-to $1 $2 > /dev/null; }
	sourceLO40() { echo "odt"; }
	targetLO40() { echo "rtf docx doc"; }
	#usage: printLO40 pdf file.rtf #prints the given file to pdf
	printLO40() { $LO40PROG --headless --convert-to pdf $1 > /dev/null; }
fi

if [ -x "$LO41PROG" ]
then
	canconvertLO41=1	# we can convert from source type to target types
	canprintLO41=1		# we can print to pdf
	#usage: convLO41 docx file.odf #converts the given file to docx
	convLO41() { $LO41PROG --headless --convert-to $1 $2 > /dev/null; }
	sourceLO41() { echo "odt"; }
	targetLO41() { echo "rtf docx doc"; }
	#usage: printLO41 pdf file.rtf #prints the given file to pdf
	printLO41() { $LO41PROG --headless --convert-to pdf $1 > /dev/null; }
fi

if [ -x "$LO42PROG" ]
then
	canconvertLO42=1	# we can convert from source type to target types
	canprintLO42=1		# we can print to pdf
	#usage: convLO42 docx file.odf #converts the given file to docx
	convLO42() { $LO42PROG --headless --convert-to $1 $2 > /dev/null; }
	sourceLO42() { echo "odt"; }
	targetLO42() { echo "rtf docx doc"; }
	#usage: printLO42 pdf file.rtf #prints the given file to pdf
	printLO42() { $LO42PROG --headless --convert-to pdf $1 > /dev/null; }
fi

if [ -x "$LO43PROG" ]
then
	canconvertLO43=1	# we can convert from source type to target types
	canprintLO43=1		# we can print to pdf
	#usage: convLO43 docx file.odf #converts the given file to docx
	convLO43() { $LO43PROG --headless --convert-to $1 $2 > /dev/null; }
	sourceLO43() { echo "odt"; }
	targetLO43() { echo "rtf docx doc"; }
	#usage: printLO43 pdf file.rtf #prints the given file to pdf
	printLO43() { $LO43PROG --headless --convert-to pdf $1 > /dev/null; }
fi

if [ -x "$LO44PROG" ]
then
	canconvertLO44=1	# we can convert from source type to target types
	canprintLO44=1		# we can print to pdf
	#usage: convLO44 docx file.odf #converts the given file to docx
	convLO44() { $LO44PROG --headless --convert-to $1 $2 > /dev/null; }
	sourceLO44() { echo "odt"; }
	targetLO44() { echo "rtf docx doc"; }
	#usage: printLO44 pdf file.rtf #prints the given file to pdf
	printLO44() { $LO44PROG --headless --convert-to pdf $1 > /dev/null; }
fi

# git master
if [ -x "$LO4MPROG" ]
then
	canconvertLO4M=1	# we can convert from source type to target types
	canprintLO4M=1		# we can print to pdf
	#usage: convLO4M docx file.odf #converts the given file to docx
	convLO4M() { $LO4MPROG --headless --convert-to $1 $2 > /dev/null; }
	sourceLO4M() { echo "odt"; }
	targetLO4M() { echo "rtf docx doc"; }
	#usage: printLO4M pdf file.rtf #prints the given file to pdf
	printLO4M() { $LO4MPROG --headless --convert-to pdf $1 > /dev/null; }
fi

#Open Office 3.3
if [ -e "$OO33PROG" ]		# this is not an executable, so only verify existence
then
	convOO33() { $OO33PATH/python $OO33PROG $OO33PORT $1 $2 > /dev/null; }
	sourceOO33() { echo "odt"; }
	targetOO33() { echo "rtf doc"; }	#OO33 cannot write docx
	printOO33() { $OO33PATH/python $OO33PROG $OO33PORT pdf $1 > /dev/null; }
	canconvertOO33=1	# we can convert from source type to target types
	canprintOO33=1		# we can print to pdf
fi

#Apache Open Office 3.4
if [ -e "$AO34PROG" ]		# this is not an executable, so only verify existence
then
	convAO34() { $AO34PATH/python $AO34PROG $AO34PORT $1 $2 > /dev/null; }
	sourceAO34() { echo "odt"; }
	targetAO34() { echo "rtf doc"; }	#AOO cannot write docx
	printAO34() { $AO34PATH/python $AO34PROG $AO34PORT pdf $1 > /dev/null; }
	canconvertAO34=1	# we can convert from source type to target types
	canprintAO34=1		# we can print to pdf
fi

#Apache Open Office 4.0
if [ -e "$AO40PROG" ]		# this is not an executable, so only verify existence
then
	convAO40() { $AO40PATH/python $AO40PROG $AO40PORT $1 $2 > /dev/null; }
	sourceAO40() { echo "odt"; }
	targetAO40() { echo "rtf doc"; }	#AOO cannot write docx
	printAO40() { $AO40PATH/python $AO40PROG $AO40PORT pdf $1 > /dev/null; }
	canconvertAO40=1	# we can convert from source type to target types
	canprintAO40=1		# we can print to pdf
fi

#Apache Open Office 4.1
if [ -e "$AO41PROG" ]		# this is not an executable, so only verify existence
then
	convAO41() { $AO41PATH/python $AO41PROG $AO41PORT $1 $2 > /dev/null; }
	sourceAO41() { echo "odt"; }
	targetAO41() { echo "rtf doc"; }	#AOO cannot write docx
	printAO41() { $AO41PATH/python $AO41PROG $AO41PORT pdf $1 > /dev/null; }
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
if [ -x "$CW27PROG" ]
then
	canprintCW27=1		# we can print to pdf
	canconvertCW27=0	# if we can convert from source type to target types
	convCW27() { 0; }	# 
	sourceCW27() { 0; }	#do not set, we do not use Abiword as source application (
	targetCW27() { 0; }
	printCW27() { $CW27PROG --export-pdf --export-filename=${1%.*}.pdf $1 2> /dev/null; }
fi

#Abiword 2.9
if [ -x "$AW29PROG" ]
then
	canprintAW29=1		# we can print to pdf
	canconvertAW29=0	# if we can convert from source type to target types
	convAW29() { 0; }	# 
	sourceAW29() { 0; }	#do not set, we do not use Abiword as source application (
	targetAW29() { 0; }
	printAW29() { $AW29PROG -t pdf $1; }
fi
