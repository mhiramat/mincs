#!/bin/sh
# description: Check help option

./minc --help | grep -qw help
./minc -h | grep -qw help


