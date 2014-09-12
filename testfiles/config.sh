# general configuration for test tools
# to be included in all tests

testname="LOConf"	#name of this test
formats="doc odt docx"
#formats="docx"

#cases="bullets bulletsadv numbering numberingadv formating chapter chapternum insimage table tableadv"
cases="bullets bulletsadv numbering numberingadv formating chapter chapternum"
#cases="bullets"

# apps, by which test documents were created, i.e. for which directories exist
sourceapps="LO40 LO41 OO33 AO34 AO40 MS13 GD CW27 AW29"
sourceapps="LO40 LO41 LO42 LO43 OO33 AO34 AO40 MS13"
sourceapps="LO41 LO43 MS13"

# apps to be used for printing
printapps="LO41 OO33 AO34 AO40 MS13 GD CW27"
printapps=$sourceapps
