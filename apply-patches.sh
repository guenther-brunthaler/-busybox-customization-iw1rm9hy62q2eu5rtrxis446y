#! /bin/sh
TAGFILE1=miscutils/bbconfig.c
TAGFILE2=xworld_patches_applied
PATCHTAG=
SERIES=patches/series

set -e
APP=${0##*/}
trap 'test $? = 0 || echo "$APP failed!" >& 2' 0

die() {
	echo "$*" >& 2
	false || exit
}

test 2 = $#
src=$2
test -d "$2"
if test ! -f "$src/$TAGFILE1" || test ! -f "$SERIES"
then
	die "Run $APP from the same directory as the script and specify" \
		"'push'/'pop' and the top-level source directory" \
		"to be patched as arguments!"
fi
b=`dirname -- "$SERIES"`
b=`readlink -f -- "$b"`
sed "s!^!$b/!" "$SERIES" | {
	cd "$2"
	case $1 in
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
			echo "Usage: $APP ( push | pop ) <srcdir>" >& 2
			false || exit
	esac
}
