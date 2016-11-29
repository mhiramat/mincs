#!/bin/sh
set -e

usage(){
 echo "Usage: build-debian-rootfs.sh <DIR> [ARCH]"
 exit 0
}

test -z "$1" -o ! -d "$1" && usage
ROOTDIR=$1
ARCH=$2
HOSTARCH=`uname -m`
DEBIAN=jessie

# What you must know about "arch"...
# arch(1): x86_64 armv7l aarch64  # same as "uname -m"
# Linux:   x86_64 arm    arm64
# Debian:  amd64  armel  arm64
# Qemu:    x86_64 arm    aarch64

# normalize to linux arch
linuxarch() { # arch
  case "$1" in
  amd64|x86_64) echo x86_64 ;;
  armv7l|armel) echo arm ;;
  aarch64|arm64) echo arm64 ;;
  esac
}
ARCH=`linuxarch $ARCH`
HOSTARCH=`linuxarch $HOSTARCH`

if [ -z "$ARCH" -o "$ARCH" = "$HOSTARCH" ]; then
  debootstrap $DEBIAN $ROOTDIR
else
  DEBARCH=$ARCH
  QEMUARCH=$ARCH
  [ $ARCH = x86_64 ] && DEBARCH=amd64
  [ $ARCH = arm ] && DEBARCH=armel
  [ $ARCH = arm64 ] && QEMUARCH=aarch64
  BINFMT=/proc/sys/fs/binfmt_misc/qemu-$QEMUARCH
  if [ ! -f $BINFMT ]; then
    echo "Error: $BINFMT is not found."
    echo "Please try to install/setup qemu-user-static"
    exit 0
  fi
  QEMU_BIN=`grep interpreter $BINFMT | cut -f 2 -d " "`
  debootstrap --foreign --arch $DEBARCH $DEBIAN $ROOTDIR
  cp $QEMU_BIN $ROOTDIR/`dirname $QEMU_BIN`
  export DEBIAN_FRONTEND=noninteractive
  export DEBCONF_NONINTERACTIVE_SEEN=true
  export LC_ALL=C
  export LANGUAGE=C
  export LANG=C
  chroot $ROOTDIR /debootstrap/debootstrap --second-stage
  chroot $ROOTDIR dpkg --configure -a
fi
