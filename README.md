# MINCS

MINCS (Minimum Container Shellscript) is a shell script for light-weight
containers. "mincs" starts with "chns" but since there are some programs
have that name, I changed the name to mincs.

* *mincs* is a shell script (frontend) of mini-container script, which
 works as the chroot, but it also changes namespace.

* *polecat* is a shell script to build a self-executable containered
 application.

## Pre-requisites

- Posix shell (dash, bash, etc)
- Util-linux ( version > 2.24 )
- IProute2
- Overlayfs
- Squashfs-tools (for polecat)

## mincs usage

` mincs [options] [command [arguments]] `

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

## polecat usage

` polecat <rootdir> <command> `

### Examples

To build an executable debian stable container, run a debootstrap on
a directory and run polecat.

```sh
 mkdir debroot
 debootstrap stable debroot
 polecat debroot /bin/bash
```

You'll see the `polecat-image.sh` in current directory, that is
a self-executable binary.

## License

This program is released under the MIT License, see LICENSE.
