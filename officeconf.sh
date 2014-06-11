# configuration of tested application

# No configuration necessary below this line, unless a new office suite is added
# The application/conversion tools and paths (see below) shoud be set in environment
# if not specified, the corresponding test will be ignored

#site specific settings to be read from environment

#the LO/AOO/OOO family
if [ -x "$LO40PROG" ]
then
	canconvertLO40=1	# we can convert from source type to target types
	canprintLO40=1		# we can print to pdf
fi

if [ -x "$LO41PROG" ]
then
	canconvertLO41=1	# we can convert from source type to target types
	canprintLO41=1		# we can print to pdf
fi

if [ -x "$LO42PROG" ]
then
	canconvertLO42=1	# we can convert from source type to target types
	canprintLO42=1		# we can print to pdf
fi

if [ -e "$OO33PROG" ]		# this is not an executable, so only verify existence
then
	canconvertOO33=1	# we can convert from source type to target types
	canprintOO33=1		# we can print to pdf
fi

if [ -e "$AO34PROG" ]		# this is not an executable, so only verify existence
then
	canconvertAO34=1	# we can convert from source type to target types
	canprintAO34=1		# we can print to pdf
fi

if [ -e "$AO40PROG" ]		# this is not an executable, so only verify existence
then
	canconvertAO40=1	# we can convert from source type to target types
	canprintAO40=1		# we can print to pdf
fi

#the MSO family
if [ -x "$MS07PROG" ]
then
	canconvertMS07=1	# we can convert from source type to target types
	canprintMS07=1		# we can print to pdf
fi

if [ -x "$MS10PROG" ]
then
	canconvertMS10=1	# we can convert from source type to target types
	canprintMS10=1		# we can print to pdf
fi

if [ -x "$MS13PROG" ]
then
	canconvertMS13=1	# we can convert from source type to target types
	canprintMS13=1		# we can print to pdf
fi

# others
if [ -x "$GDCONVERT" ]
then
	canprintGD=1		# we can print to pdf
fi

if [ -x "$CW27PROG" ]
then
	canprintCW27=1		# we can print to pdf
fi

if [ -x "$AW29PROG" ]
then
	canprintAW29=1		# we can print to pdf
fi

# application specific definitions

#Libreoffice 4.1
#usage: convLO42 docx file.odf #converts the given file to docx
convLO42() { $LO42PROG --headless --convert-to $1 $2 > /dev/null; }
sourceLO42() { echo "odt"; }
targetLO42() { echo "rtf docx doc"; }
#usage: printLO42 pdf file.rtf #prints the given file to pdf
printLO42() { $LO42PROG --headless --convert-to pdf $1 > /dev/null; }

#Libreoffice 4.1
#usage: convLO41 docx file.odf #converts the given file to docx
convLO41() { $LO41PROG --headless --convert-to $1 $2 > /dev/null; }
sourceLO41() { echo "odt"; }
targetLO41() { echo "rtf docx doc"; }
#usage: printLO41 pdf file.rtf #prints the given file to pdf
printLO41() { $LO41PROG --headless --convert-to pdf $1 > /dev/null; }

#Libreoffice 4.0
#usage: convLO40 docx file.odf #converts the given file to docx
convLO40() { $LO40PROG --headless --convert-to $1 $2 > /dev/null; }
sourceLO40() { echo "odt"; }
targetLO40() { echo "rtf docx doc"; }
#usage: printLO40 pdf file.rtf #prints the given file to pdf
printLO40() { $LO40PROG --headless --convert-to pdf $1 > /dev/null; }

#Apache Open Office 4.0
convAO40() { $AO40PATH/python $AO40PROG $AO40PORT $1 $2 > /dev/null; }
sourceAO40() { echo "odt"; }
targetAO40() { echo "rtf doc"; }	#AOO cannot write docx
printAO40() { $AO40PATH/python $AO40PROG $AO40PORT pdf $1 > /dev/null; }

#Apache Open Office 3.4
convAO34() { $AO34PATH/python $AO34PROG $AO34PORT $1 $2 > /dev/null; }
sourceAO34() { echo "odt"; }
targetAO34() { echo "rtf doc"; }	#AOO cannot write docx
printAO34() { $AO34PATH/python $AO34PROG $AO34PORT pdf $1 > /dev/null; }

#Open Office 3.3
convOO33() { $OO33PATH/python $OO33PROG $OO33PORT $1 $2 > /dev/null; }
sourceOO33() { echo "odt"; }
targetOO33() { echo "rtf doc"; }	#OO33 cannot write docx
printOO33() { $OO33PATH/python $OO33PROG $OO33PORT pdf $1 > /dev/null; }

#Google docs
canconvertGD=0	# if we can convert from source type to target types
convGD() { 0; }	# 
sourceGD() { 0; }	#do not set, we do not use GD as source application (
targetGD() { 0; }
printGD() { $GDCONVERT pdf $1; }

#Calligra Words 2.7
canconvertCW27=0	# if we can convert from source type to target types
convCW27() { 0; }	# 
sourceCW27() { 0; }	#do not set, we do not use Abiword as source application (
targetCW27() { 0; }
printCW27() { $CW27PROG --export-pdf --export-filename=${1%.*}.pdf $1 2> /dev/null; }

#Abiword 2.9
canconvertAW29=0	# if we can convert from source type to target types
convAW29() { 0; }	# 
sourceAW29() { 0; }	#do not set, we do not use Abiword as source application (
targetAW29() { 0; }
printAW29() { $AW29PROG -t pdf $1; }

#Microsoft Office 2007
convMS07() { $MS07PROG --format=$1 $2; }
sourceMS07() { echo "docx"; }
targetMS07() { echo "rtf odt doc"; }
printMS07() { $MS07PROG --format=pdf $1; }

#Microsoft Office 2010
convMS10() { $MS10PROG --format=$1 $2; }
sourceMS10() { echo "docx"; }
targetMS10() { echo "rtf odt doc"; }
printMS10() { $MS10PROG --format=pdf $1; }

#Microsoft Office 2013
convMS13() { $MS13PROG --format=$1 $2; }
sourceMS13() { echo "docx"; }
targetMS13() { echo "rtf odt doc"; }
printMS13() { $MS13PROG --format=pdf $1; }

