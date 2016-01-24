#!/bin/sh
# Public-key Signed(and encrypted) Package Maker
#
# Copyright (C) 2016 Masami Hiramatsu <masami.hiramatsu@gmail.com>
# This program is released under the MIT License, see LICENSE.

# Usage: ./package <target-file> [client pubkey]

HOST_PRIKEY=host_private.pem
CLIENT_PUBKEY=$2
TARGET=$1

die() {
  echo "$*"
  exit 1
}

[ -f "$TARGET" ] || die "target file must be given!!"

gen_pass() {
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $1 | head -n 1
}

echo "Make the signature from $HOST_PRIKEY"
openssl dgst -sha256 -sign $HOST_PRIKEY $TARGET > signature
tar cf $TARGET.tar $TARGET signature
echo "$TARGET.tar"

if [ -f "$CLIENT_PUBKEY" ]; then
  echo "Encrypt the $TARGET for $CLIENT_PUBKEY"
  gen_pass 32 > password
  openssl rsautl -encrypt -pubin -inkey $CLIENT_PUBKEY -in password > password.enc
  openssl enc -e -aes-256-cbc -kfile password -in $TARGET.tar -out $TARGET.enc
  tar cf $TARGET.enc.tar $TARGET.enc password.enc
  echo "$TARGET.enc.tar"
fi

