#!/bin/sh
[ -z "$PREFIX" ] && PREFIX=/usr/local
[ -z "$LIBEXEC" ] && LIBEXEC=$PREFIX/libexec
BIN=$PREFIX/bin

BINS="minc marten polecat"
LIBS="libexec/*"

UNINSTALL=
case "$1" in
  -u|--uninstall)
    UNINSTALL=yes
    ;;
  -h|--help)
    echo "Install script for MINCS"
    echo "Usage: $0 [-u|--uninstall]"
    exit 0
    ;;
esac

uninstall() {
  echo "Uninstall $1 from $2"
  rm -f $2
}

modify_install() { # bin target
  echo "Install $1 into $2"
  if [ -d $1 ];then
    cp -r $1 $2/
    return
  fi
  mkdir -p `dirname $2`
  cat $1 | sed -e 's%^LIBEXEC=.*$%LIBEXEC='$LIBEXEC%g > $2
  chmod 755 $2
}

for i in $BINS; do
  if [ "$UNINSTALL" ]; then
    uninstall $i $BIN/$i
  else
    modify_install $i $BIN/$i
  fi
done

for i in $LIBS; do
  if [ "$UNINSTALL" ]; then
    uninstall $i $PREFIX/$i
  else
    modify_install $i $PREFIX/$i
  fi
done

