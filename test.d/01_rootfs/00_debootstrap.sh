#!/bin/sh
# description: Prepare rootfs by debootstrap (take a while)

ROOTFS=$SHARED_DIR/rootfs

if [ ! -d $ROOTFS ] ; then
  mkdir -p $ROOTFS
  $TOP_DIR/samples/scripts/build-debian-rootfs.sh $ROOTFS --deb stretch
fi
