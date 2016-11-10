#!/bin/sh

set -e
echo "Cleanup ermine build"
[ -d libexec/ermine ] && rm -rf libexec/ermine
[ -d ermine/work ] && rm -rf ermine/work

