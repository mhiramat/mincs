#!/bin/sh

cd work

rm -rf rootfs

# Install busybox as a rootfs
(cd busybox; cd $(ls -d *)
cp -R _install ../../rootfs)

# Install mincs
(cd ../../; PREFIX=./ermine/work/rootfs/usr/ LIBEXEC=/usr/libexec ./install.sh)
# Remove minc-kernel and minc-initramfs
rm rootfs/usr/libexec/minc-kernel
rm rootfs/usr/libexec/minc-initramfs

# Prepare rootfs
cd rootfs

rm -f linuxrc

mkdir dev
mkdir etc
mkdir proc
mkdir root
mkdir src
mkdir sys
mkdir mnt
mkdir tmp
chmod 1777 tmp

cd etc

cat > bootscript.sh << EOF
#!/bin/sh

dmesg -n 1
mount -t devtmpfs none /dev 2> /dev/null
mount -t proc none /proc
mount -t sysfs none /sys
mount -t tmpfs tmpfs /tmp
mount -t tmpfs tmpfs /sys/fs/cgroup/

mkdir /sys/fs/cgroup/cpu
mount -t cgroup -o cpu cgroup /sys/fs/cgroup/cpu
mkdir /sys/fs/cgroup/memory
mount -t cgroup -o memory cgroup /sys/fs/cgroup/memory

if mount -t 9p -o trans=virtio minc /mnt -oversion=9p2000.L,posixacl,cache=loose ; then
  [ /mnt/run.sh ] && exec /bin/cttyhack sh /mnt/run.sh
fi

EOF

chmod +x bootscript.sh

cat > welcome.txt << EOF
==== Ermine qemu runtime ====
EOF

cat > inittab << EOF
::sysinit:/etc/bootscript.sh
::restart:/sbin/init
::ctrlaltdel:/sbin/reboot
::once:cat /etc/welcome.txt
::respawn:/bin/cttyhack /bin/sh

EOF

cd ..

cat > init << EOF
#!/bin/sh

exec /sbin/init

EOF

chmod +x init

cp ../../*.sh src
chmod +r src/*.sh

cd ../..

