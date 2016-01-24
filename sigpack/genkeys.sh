#!/bin/sh
# RSA keypair generator
#
# Copyright (C) 2016 Masami Hiramatsu <masami.hiramatsu@gmail.com>
# This program is released under the MIT License, see LICENSE.

openssl genrsa 4096 > $1_private.pem
openssl rsa -in $1_private.pem -pubout -out $1_public.pem
