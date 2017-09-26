#!/bin/sh
# description: Check --net option parser

export SHELL=ps
./minc --net

./minc --net raw

./minc --net dens

! ./minc --net nonexist
