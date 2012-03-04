#!/usr/bin/env bash

# script to update zip files on flybrain

cd /lmb/home/jefferis/projects/frucc/FruCloneClustering/Reformated_points/
dirs=`find . -type d ! -name "."`
echo $dirs
for x in $dirs; do
  #statements
  echo $x
  zip -u -x "*.lock" -0 "$x.zip" "$x"/*
  rsync -avP "$x.zip" lmbfly:/var/www/html/Masse2011/FruCloneClustering/Reformated_points/
done
# rsync -avnP --include="*.zip" --exclude="*.*" Reformated_points lmbfly:/var/www/html/Masse2011
