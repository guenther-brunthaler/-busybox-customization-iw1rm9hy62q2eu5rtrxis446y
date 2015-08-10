#! /bin/sh
TAGFILE=miscutils/bbconfig.c
TAGDIR=../patches

set -e
APP=${0##*/}
trap 'test $? = 0 || echo "$APP failed!" >& 2' 0

if test ! -f "$TAGFILE" || test ! -d "$TAGDIR"
then
	echo "Run $APP from the BusyBox top-level source directory!" >& 2
	false || exit
fi
