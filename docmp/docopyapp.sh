#! /bin/bash
# copy existing examples to a different application
. config.sh
from=LO43
to=LO4M
ext=odt
for i in $cases; do 
	(
	cd $i
	rm -rf $to
	mkdir $to
	cp $from/$i-$from.$ext $to/$i-$to.$ext
	)
done
