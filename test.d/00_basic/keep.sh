#!/bin/sh
# description: Keep and tempdir option works

DIR=dummy

DIR=$(./minc --keep ps | grep reuse | xargs -n 1 | tail -n 1)

test -d $DIR/storage

echo "HELLO" > $DIR/storage/hello

MSG=$(./minc -t $DIR cat /hello)

test "$MSG" = "HELLO"

rm -rf $DIR
