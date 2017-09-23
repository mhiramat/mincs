#!/bin/sh
# description: Test root option to change root

ROOTFS=$SHARED_DIR/rootfs

if [ ! -d $ROOTFS ]; then
  echo "No rootfs found"
  test_unresolved
fi

rm -f $ROOTFS/testfile.*
KEY=$(mktemp $ROOTFS/testfile.XXXXX)
KEYFILE=$(basename $KEY)
echo $KEYFILE > $KEY

test "$(./minc -r $ROOTFS cat /$KEYFILE)" = $KEYFILE

rm $KEY


