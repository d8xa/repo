#!/bin/bash

timestamp() { date "+%Y-%m-%dT%H:%M:%S"; }
msg() { printf "%s \e[1mbuild-packages\e[m: \e[32minfo\e[m:  %s\n" "$(timestamp)" "$1"; }

# delete hidden macOS files.
find source/. -name '.DS_Store' -type f -delete


N=$(($(find source/. -maxdepth 1 -type d | wc -l) - 1))
msg "Found ${N} packages."

# build packages
for item in source/*; do
  if [[ -d $item ]]; then # check if item is directory
    folder=$(basename -- "$item")
    
    # create deb file for package
    dpkg-deb -b "source/${folder}" #> /dev/null

    # move deb file to ./debs
    cp "source/${folder}.deb" "debs/${folder}.deb"
    rm -rf "source/${folder}.deb"

    msg "Built ${folder}.deb."
  fi
done

# Build package index
dpkg-scanpackages -m ./debs > Packages
bzip2 -k -f -9 Packages
msg "Updated package index."

# write package index info into Release
keep=$(($(wc -l < Release) - 2)) # N-2 lines
content=$(head -n $keep Release) # use N-2 lines of Release
echo "$content" > Release # overwrite
echo " $(md5 -q Packages) $(stat -f %z Packages) Packages" >> Release # append
echo " $(md5 -q Packages.bz2) $(stat -f %z Packages.bz2) Packages.bz2" >> Release # append

msg "Updated release file."
