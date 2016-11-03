#!/bin/sh
if [ -e libexec/minc-kernel -a -e libexec/minc-initramfs ]; then
  echo "minc-kernel and minc-initramfs are already built. skip it"
  exit 0
fi

echo "Build kernel and initramfs for minc --qemu"

set -e
cd ermine/
sh 0_prepare.sh
sh 1_get_kernel.sh
sh 2_build_kernel.sh
sh 3_get_busybox.sh
sh 4_build_busybox.sh
sh 5_generate_rootfs.sh
sh 6_pack_rootfs.sh
cp work/bzImage ../libexec/minc-kernel
cp work/initramfs ../libexec/minc-initramfs
echo "Success!"
