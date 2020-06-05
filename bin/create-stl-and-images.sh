#!/bin/bash

# This script takes all *.scad Files and creates png and stl files for them
# if a parts=.. line is found it iterates over these and generates one set of files for each


scadBin="/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"
if ! [ -s "$scadBin" ]; then
	scadBin="/Applications/MacPorts/OpenSCAD.app/Contents/MacOS/OpenSCAD"
fi
if ! [ -s "$scadBin" ]; then
    scadBin="/usr/bin/openscad"
fi
if ! [ -s "$scadBin" ]; then
	echo "!!!!!!!! ERROR: missing Scad Binary"
	exit;
fi

###################################################################

function generateStl {
	echo "--------------------------------------------------------------------------------"
	echo
	# echo "$@"
	partNumber="$1"
	shift 1
	name="$1"
	shift 1

	partDefinition=""
	baseName="stl/$fileName"
	if [ -n "$patNumber" ]; then
	    partDefinition=" -D 'part=$partNumber' "
	    baseName="stl/$fileName-part-$partNumber-$name"
	fi
	stlName="$baseName.stl"
	echo "Generate '$stlName'"
	$scadBin "$scadFile" -o "$stlName" $partDefinition -D 'debug=0' "$@"

	pngName="$baseName.png"
	echo "Generate '$pngName'"
	$scadBin "$scadFile" -o "$pngName" $partDefinition -D 'debug=0' "$@"
}  

function generateAllFiles {
    if grep -q  -e 'part=.*\[' "$scadFile" ; then
	grep -e 'part=.*\[' "$scadFile" | \
    	    perl -pe 's/.*\[//;s/\].*//; s/:/ /gs; s/,/\n/gs' | \
	    while read number name; do
		generateStl $number "$name" "$@"
	    done
    else
	generateStl "" "" "$@"
    fi
    
}


find . -name "*.scad" | while read a ; do echo `dirname "$a"`; done | sort -u >/tmp/scadDirts.txt

cat /tmp/scadDirts.txt | while read dir; do
    (
	cd $dir
	echo "Create Files in $dir"
	
	# ==================================================================
	mkdir -p stl
	rm -f stl/*.stl
	rm -f stl/*.png
	
	
	# ==================================================================
	for scadFile in *.scad; do
	    
	    fileName="${scadFile%.scad}"
	    
	    if ! [ -s "$scadFile" ]; then
		echo "!!!!!!!! ERROR: missing FIle $scadFile"
		exit;
	    fi
	    
	    generateAllFiles
	    
	done
    )
done

exit