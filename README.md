# MINCS

MINCS (Minimum Container Shellscripts) is a collection of shell scripts
for light-weight containers. "minc" starts with "chns" but since there
are some programs have that name, I changed the name to minc.

* *minc* is a shell script (frontend) of mini-container script, which
 works as the chroot, but it also changes namespace.

* *polecat* is a shell script to build a self-executable containered
 application.

* *marten* is a shell script to manage uuid-based containers and images.

## Pre-requisites

- Posix shell (dash, bash, etc)
- coreutils
- Util-linux ( version > 2.24 )
- IProute2
- Overlayfs
- Squashfs-tools (for polecat)

- Or, busybox + unshare patch :)

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

* -X or --X11
       Export local X11 unix socket

* -n or --net
       Use network namespace

* -c or --cpu *BITMASK*
       Set runnable CPU bitmask

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
 # debootstrap stable debroot
 # marten import debroot
c45554627579e3f7aed7ae83a976ed37b5f5cc76be1b37088f4870f5b212ae35
 # minc -r c455 /bin/bash
```

```sh
 # docker save centos | gzip - > centos.tar.gz
 # marten import centos.tar.gz
Importing image: centos
511136ea3c5a64f264b78b5433614aec563103b4d4702f3ba7d4d2698e22c158
5b12ef8fd57065237a6833039acc0e7f68e363c15d8abb5cacce7143a1f7de8a
8efe422e6104930bd0975c199faa15da985b6694513d2e873aa2da9ee402174c
 # marten images
ID              SIZE    NAME
511136ea3c5a    4.0K    (noname)
5b12ef8fd570    4.0K    (noname)
8efe422e6104    224M    centos
 # minc -r centos /bin/bash
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
 # debootstrap stable debroot
 # polecat debroot /bin/bash
```

You'll see the `polecat-out.sh` in current directory, that is
a self-executable binary. So, you can just run it.

` ./polecat-out.sh`

## License

This program is released under the MIT License, see LICENSE.
