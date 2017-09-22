#!/bin/sh
# description: Test bind option

rando(){
  awk 'BEGIN{srand(); print int(rand()*1000)}'
}

DIR=$(mktemp -d /tmp/bindtest.XXXXXX)

KEY=$(rando)
echo $KEY > $DIR/hello

KEY2=$(./minc --bind $DIR:/bindtest cat /bindtest/hello)

test $KEY -eq $KEY2

rm -rf $DIR
