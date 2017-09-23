
#!/bin/sh
# description: Testing polecat script

ROOTFS=$SHARED_DIR/rootfs

if [ ! -d $ROOTFS ]; then
  echo "No rootfs found"
  test_unresolved
fi

OUTSH=$(mktemp /tmp/polecat-XXXXX.sh)

./polecat -o $OUTSH $ROOTFS ps

$OUTSH | grep '^[ \t]*1.*ps$'

rm $OUTSH
