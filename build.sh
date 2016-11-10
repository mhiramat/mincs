#!/bin/sh
if [ -e libexec/ermine/bzImage -a -e libexec/ermine/initrd ]; then
  echo "Ermine kernel and initrd are already built. skip it"
  exit 0
fi

echo "Build ermine kernel and initrd for minc --qemu"

set -e
cd ermine/
sh 0_prepare.sh
sh 1_get_kernel.sh
sh 2_build_kernel.sh
sh 3_get_busybox.sh
sh 4_build_busybox.sh
sh 5_generate_rootfs.sh
sh 6_pack_rootfs.sh
sh 7_make_initrd.sh
cd ../
mkdir -p libexec/ermine
cp ermine/work/bzImage libexec/ermine/
gzip -c ermine/work/initrd > libexec/ermine/initrd
echo "Success!"
