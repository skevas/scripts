#!/bin/bash

wget -O 1.tiff "http://sipi.usc.edu/database/download.php?vol=misc&img=4.1.01"
wget -O 2.tiff "http://sipi.usc.edu/database/download.php?vol=misc&img=elaine.512"

./spamanimator.sh 1.tiff 2.tiff

rm 1.tiff 2.tiff
