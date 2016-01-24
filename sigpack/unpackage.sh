#!/bin/sh
# Unpackage(and decrypt) for signed packages
#
# Copyright (C) 2016 Masami Hiramatsu <masami.hiramatsu@gmail.com>
# This program is released under the MIT License, see LICENSE.

# Usage: ./unpackage <target file> <host pubkey>

HOST_PUBKEY=$2
CLIENT_PRIKEY=client_private.pem

die() {
  echo $*
  exit 1
}

[ -f "$1" ] || die "No package is given"
[ -f "$2" ] || die "No host public file" 

DECFILE=$1

decrypt() {
  FILE=`tar tf $1 | grep -v ^password.enc`
  DECFILE=`echo $FILE | sed 's/\.enc$//'`
  tar xf $1
  openssl rsautl -decrypt -inkey $CLIENT_PRIKEY -in password.enc -out password
  openssl enc -d -aes-256-cbc -kfile password -in $FILE -out $DECFILE
  return $?
}

sigauth() {
  FILE=`tar tf $1 | grep -v ^signature`
  tar xf $1
  [ -f signature ] || die "FAILED: No signature"
  openssl dgst -sha256 -verify $HOST_PUBKEY -signature signature $FILE || die "Failed to verify $FILE"
}

case $1 in
 *.enc.tar)
  echo "Encrypted package found: $1"
  decrypt $1 || die "Failed to decrypt $1"
  sigauth $DECFILE
  ;;
 *.tar)
  echo "General package found: $1"
  sigauth $1
  ;;
esac
echo "Succeed to verify $FILE"
