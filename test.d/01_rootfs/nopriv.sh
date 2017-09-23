#!/bin/sh
# description: Test nopriv option

ROOTFS=$SHARED_DIR/rootfs

if [ ! -d $ROOTFS ]; then
  echo "No rootfs found"
  test_unresolved
fi

rm -f $ROOTFS/testfile.*
KEY=$(mktemp $ROOTFS/testfile.XXXXX)
KEYFILE=$(basename $KEY)
echo $KEYFILE > $KEY
chmod a+r $KEY

test "$(sudo -u $SUDO_USER ./minc --nopriv $ROOTFS cat /$KEYFILE)" = $KEYFILE

rm $KEY


