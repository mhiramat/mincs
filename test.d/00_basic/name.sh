#!/bin/sh
# description: Set container name

rando(){
  awk 'BEGIN{srand(); print int(rand()*1000)}'
}

NAME=hoge-$(rando)
NAME2=$(./minc --name $NAME hostname)

test $NAME = $NAME2
