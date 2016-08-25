#!/bin/bash
#set -o xtrace #be verbose

if [ ! -f gitversions.sh ] 
then
	echo "Probably wrong working directory, file 'gitversions.sh' not found"  
	exit 1
fi

source gitversions.sh

function checkout () {
	git reset --hard
	# -fL igrore untracked files
	git checkout -f $1 &>/dev/null
	#there seems to be mess in the opt directory after repeated checkouts, so let's clean it up
	###rm -rf opt
	###git checkout -- opt
}

###rm -rf opt
###git checkout -- opt
###git checkout -- commitmsg

echo "Checking out revision '$oldest' to directory 'oldest'"
rm -rf oldest
checkout $oldest
mv opt oldest
git checkout -- opt

echo "Checking out revision '$latest' to directory 'latest'"
rm -rf latest
checkout $latest
mv opt latest
git checkout -- opt
