#!/bin/sh

cd work

rm -f initramfs

cd rootfs

find . | cpio -H newc -o | gzip > ../initramfs

cd ../..

