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

## minc usage

` minc [options] [command [arguments]] `

### Options

* -h or --help
       Show help message

* -k or --keep
       Keep the temporary directory

* -t or --tempdir *DIR*
       Set DIR for temporary directory (imply -k)

* -r or --rootdir *DIR*
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

* import *DIR*
	Import DIR as an image

* commit *UUID*
	Commit specified container to image

### Opitons

* -h or --help
       Show help message

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
 mkdir debroot
 debootstrap stable debroot
 polecat debroot /bin/bash
```

You'll see the `polecat-out.sh` in current directory, that is
a self-executable binary. So, you can just run it.

` ./polecat-out.sh`

## License

This program is released under the MIT License, see LICENSE.
