# create a report for all tested formats, cases and applications
# the insimage table and tableadv cases were excluded owing to too poor results (see config.sh)

#Comment: files rslt-l*odt, rslt-g*.odt and rslt-a*.odt have the same contents, they just link to different pair views

url="-p http://bender.dam.fmph.uniba.sk/~milos/"
url=

#
# reports and pairs with page overviews (the -l switch)
#
#doviews.sh -l -p -u -o all-l
#Reports with links to the pairs with page overlays (the -l switch)

# report for all cases format and applications
doeval.py -c -o rslt-all-l all-l*.csv

# create a report for all tested formats, cases and OO33, AO34 AO40 LO40 LO41 and MS13 withe worst line views
doeval.py -c -l -o rslt-l-OO33-AO34-AO40-LO40-LO41-MS13 -a "OO33 AO34 AO40 LO40 LO41 MS13" all-l*.csv

# create a report for all tested formats, cases and the newest applications
doeval.py -c -l -o rslt-l-AO40-LO41-MS13 -a "AO40 LO41 MS13" all-l*.csv

# create a report for all tested formats, cases and LO41 an MS13
doeval.py -c -l -o rslt-l-LO41-MS13 -a "LO41 MS13" all-l*.csv
rm -f /tmp/*tif

#
# reports and pairs with page overviews (the -l switch)
#
#doviews.sh -g -p -u -o all-g
#Reports with links to the pairs with page overlays (the -g switch)

# report for all cases format and applications
doeval.py -c -o rslt-all-g all-g*.csv

# create a report for all tested formats, cases and OO33, AO34 AO40 LO40 LO41 and MS13 withe worst line views
doeval.py -c -l -o rslt-g-OO33-AO34-AO40-LO40-LO41-MS13 -a "OO33 AO34 AO40 LO40 LO41 MS13" all-g*.csv

# create a report for all tested formats, cases and the newest applications
doeval.py -c -l -o rslt-g-AO40-LO41-MS13 -a "AO40 LO41 MS13" all-g*.csv

# create a report for all tested formats, cases and LO41 an MS13
doeval.py -c -l -o rslt-g-LO41-MS13 -a "LO41 MS13" all-g*.csv

rm -f /tmp/*tif

#
# reports and pairs with annotated side-by-side (the -a switch)
#
#doviews.sh -a -p -u -o all-a
#Reports with links to the pairs with page overlays (the -a switch)

# report for all cases format and applications
doeval.py -c -o rslt-all-a all-a*.csv

# create a report for all tested formats, cases and OO33, AO34 AO40 LO40 LO41 and MS13 withe worst line views
doeval.py -c -l -o rslt-a-OO33-AO34-AO40-LO40-LO41-MS13 -a "OO33 AO34 AO40 LO40 LO41 MS13" all-a*.csv

# create a report for all tested formats, cases and the newest applications
doeval.py -c -l -o rslt-a-AO40-LO41-MS13 -a "AO40 LO41 MS13" all-a*.csv

# create a report for all tested formats, cases and LO41 an MS13
doeval.py -c -l -o rslt-a-LO41-MS13 -a "LO41 MS13" all-a*.csv
rm /tmp/*tif
