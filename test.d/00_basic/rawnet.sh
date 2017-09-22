#!/bin/sh
# description: Test raw netns

LN=$(./minc --net raw ip link | grep '^[0-9]*:' | wc -l)

test $LN -eq 1
