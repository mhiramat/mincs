#!/bin/sh
set -e

usage(){
 echo "Usage: build-debian-rootfs.sh <DIR> [OPTIONS]"
 echo "OPTIONS"
 echo " --arch <ARCH>  Target arch: x86_64|amd64, arm|armv7l|armel, arm64|aarch64"
 echo " --deb <DEBVER> Target debian version: sid, jessie, stretch ..."
 echo " --include <PKGS> Install packages (comma separated)"
 exit 0
}

test -z "$1" -o ! -d "$1" && usage
ROOTDIR=$1
HOSTARCH=`uname -m`
ARCH=
DEBIAN=stretch
INCLUDE_PKG=

shift 1
while [ $# -ne 0 ]; do
case $1 in
  --arch) ARCH=$2; shift 2;;
  --deb) DEBIAN=$2; shift 2;;
  --include) INCLUDE_PKG=$2; shift 2;;
  *) usage;;
esac
done

# What you must know about "arch"...
# arch(1): x86_64 armv7l aarch64 ? # same as "uname -m"
# Linux:   x86_64 arm    arm64   powerpc
# Debian:  amd64  armel  arm64   ppc64el
# Qemu:    x86_64 arm    aarch64 ppc64le

# normalize to linux arch
linuxarch() { # arch
  case "$1" in
  i[3456]86) echo i386 ;;
  amd64|x86_64) echo x86_64 ;;
  armv7l|armel|arm) echo arm ;;
  aarch64|arm64) echo arm64 ;;
  ppc64|power[34]|ppc64el|ppc64le) echo powerpc ;;
  esac
}
debarch() {
  case "$1" in
  i[3456]86) echo i386 ;;
  amd64|x86_64) echo amd64 ;;
  armv7l|armel|arm) echo armel ;;
  aarch64|arm64) echo arm64 ;;
  ppc64|power[34]|ppc64el|ppc64le) echo ppc64el ;;
  esac
}
qemuarch() {
  case "$1" in
  i[3456]86) echo i386 ;;
  amd64|x86_64) echo x86_64 ;;
  armv7l|armel|arm) echo arm ;;
  aarch64|arm64) echo aarch64 ;;
  ppc64|power[34]|ppc64el|ppc64le) echo ppc64le ;;
  esac
}

_ARCH=`linuxarch $ARCH`
HOSTARCH=`linuxarch $HOSTARCH`

OPTS=
if [ "$INCLUDE_PKG" ]; then
  OPTS="--include=$INCLUDE_PKG"
fi

if [ -z "$_ARCH" -o "$_ARCH" = "$HOSTARCH" ]; then
  debootstrap $OPTS $DEBIAN $ROOTDIR
else
  DEBARCH=`debarch $ARCH`
  QEMUARCH=`qemuarch $ARCH`
  BINFMT=/proc/sys/fs/binfmt_misc/qemu-$QEMUARCH
  if [ ! -f $BINFMT ]; then
    echo "Error: $BINFMT is not found."
    echo "Please try to install/setup qemu-user-static"
    exit 0
  fi
  QEMU_BIN=`grep interpreter $BINFMT | cut -f 2 -d " "`
  if ldd $QEMU_BIN > /dev/null 2>&1 ; then
    echo "Error: $QEMU_BIN is not a static-linked binary."
    echo "Please try to install/setup qemu-user-static"
    exit 0
  fi
  debootstrap --foreign --arch=$DEBARCH $OPTS $DEBIAN $ROOTDIR ||:
  cp $QEMU_BIN $ROOTDIR/`dirname $QEMU_BIN`
  export DEBIAN_FRONTEND=noninteractive
  export DEBCONF_NONINTERACTIVE_SEEN=true
  export LC_ALL=C
  export LANGUAGE=C
  export LANG=C
  chroot $ROOTDIR /debootstrap/debootstrap --second-stage
  chroot $ROOTDIR dpkg --configure -a
fi
