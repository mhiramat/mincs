#!/bin/sh
# description: Pull image from Dockerhub

export MINCS_DIR=$SHARED_DIR/marten
rm -rf $MINCS_DIR
mkdir -p $MINCS_DIR

./marten pull alpine

./marten li | grep 'alpine$'
