#!/bin/bash
#
# dogenall.sh v1.0 - 2013-09-30
#
# This script converts and prints the 'source' document files
#
# Copyright (C) 2013 Milos Sramek <milos.sramek@soit.sk>
# Licensed under the GNU LGPL v3 - http://www.gnu.org/licenses/gpl.html
# - or any later version.
#
#set -o xtrace #be verbose
# generate the corresponding file


print=1
convert=1

function usage
{
	echo "$0 generate all required odt, rtf, docx and pdf files" 1>&2
	echo "Refer to 'config.sh for more settings"
	echo "Usage: $0 [switches] " 1>&2
	echo "Switches:" 1>&2
	echo "    -h --help ......... this usage" 1>&2
	echo "    -p ................ print only" 1>&2
	echo "    -c ................ convert only" 1>&2
	exit 1
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
		-c)
			print=0
			shift
			;;
		-p)
			convert=0
			shift
			;;
		*)
			break
			;;
	esac
done

echo "Cases: $cases" 1>&2
echo "Formats: $formats" 1>&2
echo "Source Applications: $sourceapps" 1>&2
echo "Print Applications: $printapps" 1>&2

# start OO33 server, in case we have it and need it
if [ -e "$OO33PATH/soffice" ]
then
	$OO33PATH/soffice "-accept=socket,host=localhost,port=$OO33PORT;urp;StarOffice.ServiceManager" -norestore -nofirststartwizard -nologo -headless & 
	sleep 5s
	nmap localhost
fi

# start AO34 server, in case we have it and need it
if [ -e "$AO34PATH/soffice" ]
then
	#echo "genall.sh:" $AO34PATH $AO34PORT
	$AO34PATH/soffice "-accept=socket,host=localhost,port=$AO34PORT;urp;StarOffice.ServiceManager" -norestore -nofirststartwizard -nologo -headless & 
	sleep 5s
fi

# start AO40 server, in case we have it and need it
if [ -e "$AO40PATH/soffice" ]
then
	#echo "genall.sh:" $AO40PATH $AO40PORT
	#$AO40PATH/soffice "-accept=socket,host=localhost,port=$AO40PORT;urp;StarOffice.ServiceManager" -norestore -nofirststartwizard -nologo -headless & 
	$AO40PATH/soffice "-accept=socket,host=localhost,port=8140;urp;StarOffice.ServiceManager" -norestore -nofirststartwizard -nologo -headless & 
	sleep 5s
fi

# convert to other document formats first
if [ "$convert" -eq "1" ]
then
	echo "Converting: " 1>&2
	for d in $cases; do
		for s in $sourceapps; do	#for directory
			if [ -d $d/$s ]
			then
				let canconvert=canconvert$s
				if [ $canconvert -eq 1 ] 
				then
					(
					cd $d/$s
					src=`source$s`	#suffix of the default source of the $s program
					tgt=`target$s`  #list of suffixes to generate from target
					#select the appropiate formats
					cvlist=
					for tg in $tgt; do 
						for fm in $formats; do 
							if [ $tg == $fm ]
							then
								cvlist=`echo "$cvlist $tg"`
							fi
						done
					done
					echo "-- Converting $src in $d/$s to '$cvlist' by $s"
					for i in *.$src; do 
						for tg in $cvlist; do 
							echo conv$s $tg $i; 
							conv$s $tg $i; 	# conversion
						done
					done
					)
				fi
			fi
		done
	done
fi

# convert/print to pdf
if [ "$print" -eq "1" ]
then
	echo "Printing: " 1>&2
	for d in $cases; do
		for s in $sourceapps; do	#for directory
			if [ -d $d/$s ]	# if the subdirectory for program $s exist
			then
				(
				cd $d/$s
				for t in $printapps; do	# for files
					let canprint=canprint$t
					if [ $canprint -eq 1 ]  # print in all directories
					then
						echo "-- Printing all formats in $d/$s by $t"
						for j in $formats; do
							for i in *.$j; do
								#echo $i
								if [ -f $i ]
								then
									cp $i $i.$t.$j
									#echo "Creating $i.$t.$j" 1>&2
									print$t $i.$t.$j; 	#printing
									rm $i.$t.$j
								fi
							done
						done

					fi
				done
				)
			fi
		done
	done
fi

#finish AOO
#ps -u milos|grep soffice
#nmap -p 8100-8200 localhost
killall soffice 2>/dev/null
