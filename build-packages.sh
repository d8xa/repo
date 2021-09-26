#!/bin/bash

# delete hidden macOS files.
find source/. -name '.DS_Store' -type f -delete


for item in source/*; do
  # check if item is folder
  if [[ -d $item ]]; then
    folder=$(basename -- "$item")
    ##stem="${folder%.*}"
    ##extension="${folder##*.}"
    
    # create deb file for package
    echo "source/${folder}"
    dpkg-deb -b "source/${folder}"
    
    # move deb file to ./debs
    cp "source/${folder}.deb" "debs/${folder}.deb"
    rm -rf "source/${folder}.deb"
  fi
done

# Build package index
dpkg-scanpackages -m ./debs > Packages
bzip2 -k -f -9 Packages


# write package index info into Release
keep=$(($(wc -l < Release) - 2)) # N-2 lines
content=$(head -n $keep Release) # use N-2 lines of Release
echo "$content" > Release # overwrite
echo " $(md5 -q Packages) $(stat -f %z Packages) Packages" >> Release # append
echo " $(md5 -q Packages.bz2) $(stat -f %z Packages.bz2) Packages.bz2" >> Release # append


