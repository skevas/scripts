#!/bin/bash
#
# Generates an animated GIF from the given input files
#
# Version: 0.2 2017-07-14
#
# Raphael Ernst
#

# This program is distributed in the hope that it will be useful, but WITHOUT 
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE

# Known Issues/Bugs 
#
# - Image filenames must not start with "resized_"
# - Deletes files starting with "resized_" in the current folder
# - Images and script must be in the same folder
# - Overwrites "animation.gif"

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
	echo "Usage: `basename $0` files"
	exit 0
fi

PREFIX="resized_"
ANIMATION="animation.gif"

MAX_WIDTH=0
MAX_HEIGHT=0

echo "Image size"
for i in "$@" 
do
	IMAGE_SIZE=`identify -format '%w %h' $i`
	HEIGHT=`echo $IMAGE_SIZE | cut -f1 -d' '`
	WIDTH=`echo $IMAGE_SIZE | cut -f1 -d' '`

	if [ "$HEIGHT" -gt "$MAX_HEIGHT" ]
	then
		MAX_HEIGHT=$HEIGHT
	fi

	if [ "$WIDTH" -gt "$MAX_WIDTH" ]
	then
		MAX_WIDTH=$WIDTH
	fi
done

echo "Resizing"
for i in "$@"
do
	convert $i -gravity center -extent $[MAX_WIDTH]x$[MAX_HEIGHT] $[PREFIX]$i
done

echo "Animation"
convert -delay 100 $[PREFIX]* $ANIMATION

echo "Removing resized files"
rm $[PREFIX]*

exit 0
