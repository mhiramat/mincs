# MINCS

MINCS (Minimum Container Shellscript) is a shell script for light-weight
containers. "mincs" starts with "chns" but since there are some programs
have that name, I changed the name to mincs.

## Pre-requisites

- Posix shell (dash, bash, etc)
- Util-linux ( version > 2.24 )
- IProute2

## Usage

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

