#! /bin/sh
TAGFILE1=miscutils/bbconfig.c
TAGFILE2=xworld_patches_applied
PATCHTAG=
SERIES=../patches/series

set -e
APP=${0##*/}
trap 'test $? = 0 || echo "$APP failed!" >& 2' 0

die() {
	echo "$*" >& 2
	false || exit
}

if test ! -f "$TAGFILE1" || test ! -f "$SERIES"
then
	die "Run $APP from the BusyBox top-level source directory!"
fi
b=`dirname "$SERIES"`
sed "s!^!$b/!" "$SERIES" \
| case $1 in
	push)
		if test -e "$TAGFILE2" && test -s "$TAGFILE2"
		then
			die "Patches have already been applied!"
		fi
		echo "Applying patches..." >& 2
		xargs cat | patch -p1
		;;
	pop)
		if test ! -e "$TAGFILE2" || test ! -s "$TAGFILE2"
		then
			die "Patches have not yet been applied!"
		fi
		echo "Unapplying patches..." >& 2
		tac | xargs cat | patch -Rp1
		;;
	*)
		echo "Usage: $APP ( push | pop )" >& 2
		false || exit
esac
