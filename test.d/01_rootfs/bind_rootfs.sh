#!/bin/sh
# description: Test bind option on another rootfs

ROOTFS=$SHARED_DIR/rootfs

if [ ! -d $ROOTFS ]; then
  echo "No rootfs found"
  test_unresolved
fi

rm -f $ROOTFS/testdir*
KEY=$(mktemp -d $ROOTFS/testdirXXXXX)
KEYDIR=$(basename $KEY)

./minc -r $ROOTFS --bind ./:/$KEYDIR ls /$KEYDIR/minc

rmdir $KEY

