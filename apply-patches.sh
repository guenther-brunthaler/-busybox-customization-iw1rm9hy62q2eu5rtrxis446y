#! /bin/sh
TAGFILE=miscutils/bbconfig.c
SERIES=../patches/series.guards

set -e
APP=${0##*/}
trap 'test $? = 0 || echo "$APP failed!" >& 2' 0

if test ! -f "$TAGFILE" || test ! -f "$SERIES"
then
	echo "Run $APP from the BusyBox top-level source directory!" >& 2
	false || exit
fi
b=`dirname "$SERIES"`
guards < "$SERIES" | sed "s!^!$b/!" \
| case $1 in
	push)
		echo "Applying patches..." >& 2
		xargs cat | patch -p1
		;;
	pop)
		echo "Unapplying patches..." >& 2
		tac | xargs cat | patch -Rp1
		;;
	*)
		echo "Usage: $APP ( push | pop )" >& 2
		false || exit
esac
