# general configuration for test tools
# 

# Sequence of operations
# ../convall.sh (on the target computer (where the tested application runs - in this case LibreOffice)
# ../printall.sh (on the source system (where the reference app runs - MS Office on Windows)
# ../compareall.sh (on Linux, may be the target computer)
# ../gencsv.sh > all.csv (on Linux, may be the target computer)
# ../genods.py -i all.csv -o rslt.ods (on Linux, may be the target computer)

# ../gencsv.sh > all.csv
# ../genods.py -i all.csv -o rslt.ods
# ../genods.py -i all.csv -o rslt.ods -p http://bender.dam.fmph.uniba.sk/~milos/roundtrip/docxAF

# in this test one does not need to run MSO - the required files are included in the orig subdirectory. 
# The evaluation in compareall.sh tests will partially fail - only print tests will succeed. You will see the following messages
# Creating pairs for LO40/part1/bulletsadv
# failed to open LO40/part1/bulletsadv.pdf. (orig/part1/bulletsadv.pdf, LO40/part1/bulletsadv.pdf)
# and grade 7 will apear in the resulting ods report

#set input type here
format="docx"
sourcedir="orig"	#copy test files here (docx in this case, may have subdirectories)

# applications to test. E.g. to enter LO44 here a LO44PROG environment variable should exist - read the readme file above
#rtripapps="GD LO40 MS07 MS10 LO41 LO42 LO43 LO44"
rtripapps="LO40 LO41 LO42 LO43 LO44 LO50"
#rtripapps="LO50"

# reference application
#sourceapp="MSWINE"
sourceapp="MS13"
