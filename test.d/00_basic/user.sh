#!/bin/sh
# description: Test user-id option

UID=$(./minc --user 1000 id -u)
test "$UID" = 1000

GID=$(./minc --user 1000:1234 id -g)
test "$GID" = 1234
