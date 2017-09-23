#!/bin/sh
# description: Run pulled image

export MINCS_DIR=$SHARED_DIR/marten

./marten li | grep "alpine"

./minc --debug -r alpine ls

