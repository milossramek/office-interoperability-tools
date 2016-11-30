export LOMASTERPROG="/home/xisco/libreoffice/instdir/program/soffice"
export LO44PROG="/home/xisco/bibisect/bibisect-44max/opt/program/soffice"
export FTPATH="/home/xisco/office-interoperability-tools"
export GDCONVERT="$FTPATH/gdconvert/gdconvert"
export WINEPROG="/usr/bin/wine"
export WINEPREFIX="/home/xisco/.wineprefixes/msoffice2010/"

../../scripts/convall.sh
../../scripts/printall.sh
../../scripts/compareall.sh
../../scripts/gencsv.sh > all.csv
../../scripts/genods.py -i all.csv -o rslt.ods
