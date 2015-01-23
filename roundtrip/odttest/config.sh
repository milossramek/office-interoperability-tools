# generalconfiguration for test tools
# to be included in all tests

# Sequence of operations
# ../convall.sh on the target computer
# ../printall.sh on the source system
# ../compareall.sh
# ../gencsv.sh > all.csv
# ../genods.py -i all.csv -o rslt.ods

format="odt"
sourcedir="orig"

# apps, by which test documents were created, i.e. for which directories exist
rtripapps="GD MS13"
rtripapps="MS13"

# apps to be used for printing
sourceapp="LO43"
