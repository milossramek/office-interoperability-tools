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
# ../genods.py -i all.csv -o rslt.ods -p http://bender.dam.fmph.uniba.sk/~milos/roundtrip/docxtest


#set input type here
iformat="pptx ppt"

#set output type here
oformat="pptx ppt"

sourcedir="orig"	#copy test files here (docx in this case, may have subdirectories)

# tested applications 
# applications are defined in officeconfig.sh
rtripapps="LOMASTER LO44"

# reference application to be used for printing
sourceapp="MSWINE"	# MS Office running under Wine on Linux  
