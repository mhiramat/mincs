#!/bin/sh
# RSA keypair generator
#
# Copyright (C) 2016 Masami Hiramatsu <masami.hiramatsu@gmail.com>
# This program is released under the MIT License, see LICENSE.

usage(){
  echo "%0 - create RSA keypair"
  echo "Usage: %0 key-pair-name"
  exit 1
}

[ $# -ne 1 ] && usage

openssl genrsa 4096 > ${1}_private.pem
openssl rsa -in ${1}_private.pem -pubout -out ${1}_public.pem
