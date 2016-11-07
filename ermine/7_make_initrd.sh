#!/bin/sh

# default ramdisk size is 4MB
dd if=/dev/zero of=work/initrd bs=1024 count=4096

cat > work/run.sh << EOF
#!/bin/sh
set -ex
losetup /dev/loop0 /mnt/initrd
mkfs.ext2 /dev/loop0
mkdir -p /rootfs
mount /dev/loop0 /rootfs
cd /rootfs
gzip -cd /mnt/initramfs | cpio -i -d
cd ../
umount /rootfs
poweroff
EOF

qemu-system-`uname -m` -kernel work/bzImage -initrd work/initramfs -nographic\
	-append "console=ttyS0" \
	-virtfs local,id=minc,path=$PWD/work,security_model=none,mount_tag=minc\
	-enable-kvm
