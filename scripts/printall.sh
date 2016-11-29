#!/bin/bash
#set -o xtrace #be verbose

. config.sh
. $FTPATH/officeconf.sh 
checkLO


# trap ctrl-c and call ctrl_c()
trap killWINEOFFICE INT

function killWINEOFFICE() {
	if pgrep WINWORD.EXE > /dev/null; then
		echo "Killing WORD (WINWORD.EXE)"
		ps -ef | grep WINWORD.EXE | grep -v grep | awk '{print $2}' | xargs kill
	fi
	if pgrep POWERPNT.EXE > /dev/null; then
		sleep 5s
		#powerpoint might take some seconds to export to pdf. wait 5 seconds
		#before killing it
		if pgrep POWERPNT.EXE > /dev/null; then
			echo "Killing POWERPOINT (POWERPNT.EXE)"
			ps -ef | grep POWERPNT.EXE | grep -v grep | awk '{print $2}' | xargs kill
		fi
	fi
exit 1
}

let canprint=canprint$sourceapp
if [ $canprint -eq 1 ] 
then
	for a in $sourcedir $rtripapps; do
		echo Printing in $a
		for ofmt in $oformat; do
			if [ $a == $sourcedir ]; then
				for ifmt in $iformat; do
						if [ $ofmt != $ifmt ]; then
							for i in `find $a -name \*.$ifmt`; do
								(
								ifile=`basename $i`
								ofile=`basename $ifile`.$ofmt
								auxpdf=`basename $ofile .$ofmt`.pdf
								pdffile=`basename $ofile`.pdf
								dir=`dirname $i`
								cd $dir
								if [ ! -e "$pdffile" ] || [ "$pdffile" -ot "$ofile" ];
								then
									# keep type to enable processing of multiple formats
									auxoutput=`basename $ifile .$ifmt`.$ofmt
									echo Printing $ifile in $dir to $ofile
									print$sourceapp $ofmt $ifile &>/dev/null
									if [ ! -e $auxoutput ];
									then
										killWINEOFFICE
										# delete in the case it is there from the previous test
										# missing file will be in report indicated by grade 7
										echo Failed to create $dir/$auxoutput
									else
										mv $auxoutput $ofile
										ifile=`basename $ofile`
										# keep type to enable processing of multiple formats
										dir=`dirname $ofile`
										cd $dir
										echo Printing $ofile in $dir to $pdffile
										# apps in general cannot create specific file but just $auxpdf
										print$sourceapp pdf $ofile &>/dev/null
										# convert to pdf
										# input: orig/bullets.doc
										# output: orig/bullets.doc.pdf
										# output: LO52/bullets.doc.pdf
										#rename to contain $ifmt in file name
										if [ ! -e $auxpdf ];
										then
											killWINEOFFICE
											# delete in the case it is there from the previous test
											# missing file will be in report indicated by grade 7
											echo Failed to create $dir/$pdffile
										else
											mv $auxpdf $pdffile
										fi
										echo Removing $ofile
										rm -f $ofile
									fi
								fi
								)
							done
						fi
				done
			fi

			for i in `find $a -name \*.$ofmt`; do
				(
				ifile=`basename $i`
				auxpdf=`basename $ifile .$ofmt`.pdf
				# keep type to enable processing of multiple formats
				ofile=`basename $ifile`.pdf
				dir=`dirname $i`
				cd $dir
				if [ ! -e "$ofile" ] || [ "$ofile" -ot "$ifile" ];
				# files already have LO51 in their name, no renaming necessary
				#if [ ! -e "$ofile" ];
				then
					echo Printing $ifile in $dir to $ofile
					# apps in general cannot create specific file but just $auxpdf
					print$sourceapp pdf $ifile &>/dev/null
					# convert to pdf
					# input: orig/bullets.doc
					# output: orig/bullets.doc.pdf
					# output: LO52/bullets.doc.pdf
					#rename to contain $ifmt in file name
					if [ ! -e $auxpdf ];
					then
						killWINEOFFICE
						# delete in the case it is there from the previous test
						# missing file will be in report indicated by grade 7
						echo Failed to create $dir/$ofile
						rm -f $ofile
					else
						mv $auxpdf $ofile
					fi
				#else
					#echo "$ofile is up to date"
				fi
				)
			done


		done
	done

else
	echo "$0 error: $sourceapp print command not defined. Is this the right system?" 2>&1
	exit 1
fi
