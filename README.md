# MINCS

MINCS (Minimum Container Shellscripts) is a collection of shell scripts
for light-weight containers. Since MINCS just requires posix shell and
some tools, it is easy to run it even on busybox ( see [Ermine](#ermine) for busybox combination).

* [*minc*](#minc-usage) is a shell script (frontend) of mini-container script, which works as the chroot, but it also changes namespace.

* [*polecat*](#polecat-usage) is a shell script to build a self-executable containered application.

* [*marten*](#marten-usage) is a shell script to manage uuid-based containers and images.

* [*ermine*](#ermine) is a micro linux bootimage for qemu. MINCS has *ermine-breeder* to build ermine (vmlinuz and initramfs.)

## Pre-requisites

- Posix shell (dash, bash, etc)
- coreutils
- Util-linux ( version >= 2.24 for basic usage, and >= 2.28 for --nopriv )
- IProute2
- Overlayfs
- Squashfs-tools (for polecat)
- libcap (for --nocaps option)
- [jq](https://github.com/stedolan/jq/) (for marten)
- docker or debootstrap (for marten)
- qemu-user-static (for --cross)
- qemu-system (for --qemu)

- Or, busybox ( version >= 1.25 ) and libcap (for minc/ermine)

## minc usage

` minc [options] [command [arguments]] `

### Options

* -h or --help  
       Show help message

* -k or --keep  
       Keep the temporary directory

* -t or --tempdir *DIR*  
       Set DIR for temporary directory (imply -k)

* -r or --rootdir *DIR*|*UUID*|*NAME*  
       Set DIR for original root directory

* -b or --bind *HOSTPATH*:*PATH*  
       Bind HOSTPATH to PATH inside container.
       The PATH must be an absolute path.

* -X or --X11  
       Export local X11 unix socket

* -n or --net  
       Use network namespace

* -c or --cpu *BITMASK*  
       Set runnable CPU bitmask

* --name *UTSNAME*  
       Set container's utsname

* --user *USERSPEC*  
       Run command as given uid:gid

* --cross *arch*  
       Run command with given arch (require setting up qemu-user-mode)

* --arch *arch*
       Same as --cross.

* --nopriv *rootdir*  
       Run command in given rootfs without root privilege

* --qemu  
       Run command in Qemu (like Clear Container, see [Ermine](#ermine))

* --nocaps *CAPLIST*  
       Drop capabilities (e.g. cap_sys_admin)

## marten usage

` marten <command> [arguments...]`

### Command

* lc or list  
	List containers

* li or images  
	List images

* rm *UUID*  
	Remove specified container

* import *DIR*|*DOCKERIMAGE*  
	Import DIR or DOCKERIMAGE as an image

* commit *UUID*  
	Commit specified container to image

### Opitons

* -h or --help  
       Show help message

### Mixed example of minc and marten

```sh
 $ sudo debootstrap stable debroot
 $ sudo marten import debroot
c45554627579e3f7aed7ae83a976ed37b5f5cc76be1b37088f4870f5b212ae35
 $ sudo minc -r c455 /bin/bash
```

### Mixed example of minc and Docker :)

```sh
 $ sudo docker save centos | gzip - > centos.tar.gz
 $ sudo marten import centos.tar.gz
Importing image: centos
511136ea3c5a64f264b78b5433614aec563103b4d4702f3ba7d4d2698e22c158
5b12ef8fd57065237a6833039acc0e7f68e363c15d8abb5cacce7143a1f7de8a
8efe422e6104930bd0975c199faa15da985b6694513d2e873aa2da9ee402174c
 $ sudo marten images
ID              SIZE    NAME
511136ea3c5a    4.0K    (noname)
5b12ef8fd570    4.0K    (noname)
8efe422e6104    224M    centos
 $ sudo minc -r centos /bin/bash
```

## polecat usage

` polecat [options] <rootdir> <command> `

### Options

* -h or --help  
       Show help message

* -o or --output *FILE*  
       Output to FILE instead of *polecat-out.sh*

### Examples

To build an executable debian stable container, run a debootstrap on
a directory and run polecat.

```sh
 $ sudo debootstrap stable debroot
 $ sudo polecat debroot /bin/bash
```

You'll see the `polecat-out.sh` in current directory, that is
a self-executable binary. So, you can just run it.

` ./polecat-out.sh`

## Ermine

Ermine is not a shell script, but it is a micro linux boot image which is
used for qemu container (minc --qemu). MINCS has a build script for ermine
called "ermine-breeder". You can build your own ermine on your machine.

### ermine-breeder usage

` ermine-breeder [command] [option(s)]`

### Commands

* build  
	Build ermine by using host toolchain (default)

* clean  
	Cleanup workdir

* selfbuild *[DIR]* *[OPT]*  
	Setup new rootfs and build (will need sudo)
	If *DIR* is given for rootfs, use the directory as new rootfs.

* testrun *[--arch <ARCH>]* *[DIR]*  
	Run qemu with ermine image

### Options

* --repack  
	Rebuild ermine image without cleanup workdir
	(only the kernel will be rebuilt)

* --rebuild  
	Rebuild ermine image with cleanup workdir

* --config *CONF_FILE*  
	Use *CONF_FILE* as config

* --arch *ARCH*  
	Build ermine for ARCH (x86_64, arm, arm64)

### Example

To build the ermine by ermine-breeder, you can choose either one of below.

- Install build tools for kernel and busybox (also static-linked glibc) on
  your environment by using apt/yum/dnf etc.
- Install debootstrap and setup sudo (since debootstrap requires root
  privilege)

If you choose the former, you'll just need to run `ermine-breeder`.
For latter, run `ermine-breeder selfbuild` to build it.

Under samples/ermine/, there are some example configs. E.g.

```
 $ ./ermine-breeder --config samples/ermine/smallconfig
```

This will build ermine with small-size configuration, result in less than 5MB.

Multi config files are also supported, so that you can combine different configs by giving multi --config CONF options. Note that settings in configs are overwritten by latter config.

## Building Cross-arch Rootfs

When you run minc with --arch/--cross option, you'll need a rootfs directory for the target architecture. One recommended way to get it is using cross-debootstrap which allow you to build debian-based cross-arch rootfs.
To setup it easily, there is a sample script. For example, if you would like to build a rootfs for arm, run below command.

```
$ sudo ./samples/scripts/build-debian-rootfs.sh ./rootfs/arm arm
```

This build debian jessie (debian 8) rootfs arm port under ./rootfs/arm directory. So after it finished, you can run minc as below;

```
$ sudo minc -r ./rootfs/arm --arch arm
```

### Known issues on major distros

- On Fedora 24/x86\_64, qemu-static's aarch64 setup has an [issue](https://bugzilla.redhat.com/show_bug.cgi?id=1394859). You must setup a binfmt config file for qemu-aarch64 to run with --cross aarch64.

- On Ubuntu 16.04/x86\_64, qemu-system's aarch64 will not work without installing qemu's UEFI image. (It seems that qemu-efi package doesn't help, you need to install it from pcbios directory in qemu's source code to /usr/share/qemu/)

- If you can't make it work, you can also build your own qemu-system-arm/aarch64 from source as below:

```
$ cd qemu
$ ./configure --target-list=arm-softmmu,aarch64-softmmu --enable-virtfs
$ make
```


## License

This program is released under the MIT License, see LICENSE.
