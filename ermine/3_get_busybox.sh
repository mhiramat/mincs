#!/bin/sh

# Grab everything after the '=' character
DOWNLOAD_URL=http://busybox.net/downloads/busybox-1.23.1.tar.bz2

# Grab everything after the last '/' character
ARCHIVE_FILE=${DOWNLOAD_URL##*/}

cd source

# Downloading busybox source
# -c option allows the download to resume
if [ ! -f $ARCHIVE_FILE ]; then
  wget -c $DOWNLOAD_URL
fi

# Delete folder with previously extracted busybox
rm -rf ../work/busybox
mkdir ../work/busybox

# Extract busybox to folder 'busybox'
# Full path will be something like 'work/busybox/busybox-1.23.1'
tar -xf $ARCHIVE_FILE -C ../work/busybox

# Apply extra patches for namespace
cd ../work/busybox/
cd $(ls -d *)

for i in ../../../busybox/*.patch; do
  patch -p1 < $i
done

cd ../../../

