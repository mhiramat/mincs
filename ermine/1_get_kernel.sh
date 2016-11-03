#!/bin/sh

DOWNLOAD_URL=https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.4.30.tar.xz

# Grab everything after the last '/' character
ARCHIVE_FILE=${DOWNLOAD_URL##*/}

cd source

# Downloading kernel file
# -c option allows the download to resume
if [ ! -f $ARCHIVE_FILE ]; then
  wget -c $DOWNLOAD_URL
fi

# Delete folder with previously extracted kernel
rm -rf ../work/kernel
mkdir ../work/kernel

# Extract kernel to folder 'work/kernel'
# Full path will be something like 'work/kernel/linux-3.16.1'
tar -xf $ARCHIVE_FILE -C ../work/kernel

cd ../../../

