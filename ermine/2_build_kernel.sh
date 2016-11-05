#!/bin/sh

cd work/kernel

# Change to the first directory ls finds, e.g. 'linux-3.18.6'
cd $(ls -d *)

# Cleans up the kernel sources, including configuration files
#ZZmake mrproper

# Create a default configuration file for the kernel
make defconfig

yconfig() { # configs
while [ $# -ne 0 ]; do
  sed -i "s/.*CONFIG_$1\ .*/CONFIG_$1=y/" .config
  grep ^"CONFIG_$1=y" .config || echo "CONFIG_$1=y" >> .config
  echo enable $1
  shift 1
done
}

# Changes the name of the system
sed -i "s/.*CONFIG_DEFAULT_HOSTNAME.*/CONFIG_DEFAULT_HOSTNAME=\"ermine\"/" .config

# Config for Virtio environment
yconfig VIRTIO VIRTIO_PCI VIRTIO_MMIO VIRTIO_CONSOLE VIRTIO_BLK VIRTIO_NET

# Config 9pfs
yconfig NET_9P NET_9P_VIRTIO 9P_FS 9P_FS_POSIX_ACL

# Config adding Realtek NIC
yconfig 8139TOO 8139CP

# Config for MINC support
yconfig OVERLAY_FS

yconfig BLK_DEV_RAM BLK_DEV_INITRD

# Config for cgroups
yconfig CGROUPS EVENTFD CGROUP_DEVICE CPUSETS CGROUP_CPUACCT \
        PAGE_COUNTER MEMCG MEMCG_SWAP MEMCG_SWAP_ENABLED MEMCG_KMEM \
        CGROUP_PERF CGROUP_SCHED CGROUP_HUGETLB FAIR_GROUP_SCHED \
        CGROUP_PIDS CGROUP_FREEZER CFS_BANDWIDTH RT_GROUP_SCHED BLK_CGROUP

make kvmconfig
make olddefonfig

# Compile the kernel
# Good explanation of the different kernels
# http://unix.stackexchange.com/questions/5518/what-is-the-difference-between-the-following-kernel-makefile-terms-vmlinux-vmlinux
make bzImage -j `nproc`

cp -f arch/x86/boot/bzImage ../../

cd ../../..

