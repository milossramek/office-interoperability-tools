# general configuration for test tools
# to be included in all tests

# Basic sequence of operations
# 1. On all systems convert source files to target files by running
#	dogenall.sh -c
#	Ensure that all created files are avialable on all systems
# 2. On all systems print source and target files to pdf by running
#	dogenall.sh -p
#	Ensure that all created files are avialable on all systems
# 3. On one system create pair views (stored in the 'pdfpairs' directory)  
#    and compute statistics (stored in the 'pairs' files by running 
#	doviews.sh -u -o all
#    files all.csv and all-X.pdf will be created
# 4. on the same system generate odt report by running
#	doeval.py -c all.csv
#    file rslt.odt will be created
# The doviews.sh and doeval.py tools have some more options. 

testname="LOConf"	#name of this test
formats="doc odt docx"
#formats="docx"

cases="bullets bulletsadv numbering numberingadv formating chapter chapternum insimage table tableadv"
cases="bullets bulletsadv numbering numberingadv formating chapter chapternum insimage table"
#cases="bullets bulletsadv numbering numberingadv formating chapter chapternum"
#cases="table"

# apps, by which test documents were created, i.e. for which directories exist
sourceapps="LO40 LO41 OO33 AO34 AO40 MS13 GD CW27 AW29"
sourceapps="LO40 LO41 LO42 LO43 OO33 AO34 AO40 AO41 MS13"
#sourceapps="AO40 AO41 MS13"
sourceapps="LO4M"

# apps to be used for printing
printapps="LO40 LO41 LO42 LO43 LO4M OO33 AO34 AO40 AO41 MS13 "
#printapps=$sourceapps
#printapps="AO41"
