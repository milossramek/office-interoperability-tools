# general configuration for test tools
# to be included in all tests

testname="LOConf"	#name of this test
formats="doc odt docx"

#cases="bullets bulletsadv numbering numberingadv formating chapter chapternum insimage table tableadv"
cases="bullets bulletsadv numbering numberingadv formating chapter chapternum"

# apps, by which test documents were created, i.e. for which directories exist
sourceapps="LO40 LO41 OO33 AO34 AO40 MS13 GD CW27 AW29"
sourceapps="LO40 LO41 OO33 AO34 AO40 MS13"

# apps to be used for printing
printapps="LO40 LO41 OO33 AO34 AO40 MS13 GD CW27"
printapps=$sourceapps
