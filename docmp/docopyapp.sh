#! /bin/bash
# copy exiting examples to a different application
. config.sh
from=LO42
to=LO43
ext=odt
for i in $cases; do 
	(
	cd $i
	rm -rf $to
	mkdir $to
	cp $from/$i-$from.$ext $to/$i-$to.$ext
	)
done
