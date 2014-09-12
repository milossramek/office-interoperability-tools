# create a report for all tested formats, cases and applications
# the insimage table and tableadv cases were excluded owing to too poor results (see config.sh)

#Comment: files rslt-l*odt, rslt-g*.odt and rslt-a*.odt have the same contents, they just link to different pair views
#set -o xtrace #be verbose

url="-p http://bender.dam.fmph.uniba.sk/~milos/"
url=

# report for all cases format and applications
ostrall="all"
astralla=
astrallb=

# create a report for the OO family and MS
ostrOOMS="OO33-AO34-AO40-LO40-LO41-LO42-LO43-MS13"
astrOOMSa="-a"
astrOOMSb="OO33 AO34 AO40 LO40 LO41 LO42 LO43 MS13"

# create a report for newest applications
ostrAOLO="AO40-LO41-LO43-MS13" 
astrAOLOa="-a"
astrAOLOb="AO40 LO41 LO43 MS13"

# create a report for LO41 LO42 an MS13
ostrLOMS="LO41-LO42-LO43-MS13"
astrLOMSa="-a"
astrLOMSb="LO41 LO42 LO43 MS13"

function testbatch () {
	ls all$1*.csv
	doviews.sh $1 -p -u -o all$1
	#Reports with links to the pairs with page overlays (the -l switch)

	# all cases format and applications
	doeval.py $url -c -o rslt$1-$ostrall all$1*.csv
	# all tested formats, cases and OO33, AO34 AO40 LO40 LO41 and MS13 withe worst line views
	doeval.py $url -c -o rslt$1-$ostrOOMS $astrOOMSa "$astrOOMSb" all$1*.csv
	# all tested formats, cases and the newest applications
	doeval.py $url -c -o rslt$1-$ostrAOLO $astrAOLOa "$astrAOLOb" all$1*.csv
	# all tested formats, cases and LO41 LO42 an MS13
	doeval.py $url -c -o rslt$1-$ostrLOMS $astrLOMSa "$astrLOMSb" all$1*.csv
	rm -f /tmp/*tif
}

# reports and pairs with page overlays (the -l switch)
testbatch "-l" 
# reports and pairs with page overlays and aligned rows (the -l switch)
#testbatch "-g" 
# reports and pairs with annotated side-by-side views (the -a switch)
#testbatch "-a" 
