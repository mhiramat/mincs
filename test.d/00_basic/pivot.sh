#!/bin/sh
# description: Test pivot option

# This just tests the pivot option doesn't cause any errors
test $(./minc --pivot echo "HELLO") = "HELLO"

