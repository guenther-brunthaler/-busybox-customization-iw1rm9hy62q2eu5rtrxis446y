#! /bin/sh
TAGFILE1=miscutils/bbconfig.c
TAGFILE2=xworld_patches_applied
BB_TARGET=busybox-pbyqxzl1ktqlk3fjm3arlrclg
BB_LINK=busybox-localsite
STAGES_SUBDIR=stages

set -e
APP=${0##*/}
trap 'test $? = 0 || echo "$APP failed!" >& 2' 0

test 1 = $#; src=$1; test -n "$src"; test -d "$src"
if
	test ! -d "$src"/.git || test ! -f "$src/$TAGFILE1" \
	|| test ! -f "$src/$TAGFILE2" || test ! -s "$src/$TAGFILE2"
then
	echo "Usage: $APP <BusyBox_top-level_source_directory>" >& 2
	false || exit
fi
c1=`basename -- "$src"`
test -n "$c1"
cd "$src"
if test -d .git && expr x"$c1" : x'.*[0-9]' = 0 > /dev/null
then
	c1=$c1-`
		git describe --tags HEAD \
		| sed 'y:/:-:; s/_BASE-/-p/; s/-g.*//; s/_/./g'
	`
fi
c2=`hostname`
test -n "$c2"
c3=`stat -c %Y busybox`
test -n "$c3"
c3=`date -d "@$c3" +%Y%m%d`
test -n "$c3"
stage=$c1-$c2-$c3
sdir=$STAGES_SUBDIR
test -d "$sdir" || mkdir -- "$sdir"
sdir=$sdir/$stage
sdir0=$sdir
c=0
while test -d "$sdir"
do
	c=`expr $c + 1`
	sdir=$sdir0.$c
done
echo "Installing into staging directory" >& 2
printf '%s\n' "$sdir"
mkdir "$sdir"
mkdir "$sdir/usr"
mkdir "$sdir/usr/local"
mkdir "$sdir/usr/local/bin"
cp busybox "$sdir/usr/local/bin/$BB_TARGET"
ln -s "$BB_TARGET" "$sdir/usr/local/bin/$BB_LINK"
mkdir "$sdir/usr/local/share"
mkdir "$sdir/usr/local/share/doc"
mkdir "$sdir/usr/local/share/doc/$stage"
cp docs/BusyBox.txt "$sdir/usr/local/share/doc/$stage/$BB_LINK.txt"
# Create symlinks for commands which are not otherwise available. This is
# intelligent enough to recognize symlinks installed by a previous instance of
# this script.
./busybox --list | {
	# Seed the list of search paths from $PATH.
	ofs=$IFS; IFS=':'; set -- $PATH; IFS=$ofs
	n=$#
	while :
	do
		test -d "$1" && test -x "$1" && set -- "$@" "$1"
		shift
		n=`expr $n - 1` || break
	done
	# Add missing paths from a predefined hard-coded list.
	for p0 in / /usr /usr/local "$HOME"
	do
		for p in bin sbin
		do
			p=${p0%%/}/$p
			if test -d "$p" && test -x "$p"
			then
				# Make sure it is not a duplicate.
				n=$#; found=false
				while :
				do
					if test x"$1" = x"$p"
					then
						found=true; break
					fi
					set -- "$@" "$1"; shift
					n=`expr $n - 1` || break
				done
				$found || set -- "$@" "$p"
			fi
		done
	done
	while read applet
	do
		# Search for a command with the same name in the search paths.
		found=false
		for p
		do
			a=$p/$applet
			if test -f "$a" && test -x "$a"
			then
				# Found a matching command.
				if test -L "$a"
				then
					# But it's a symlink. Resolve it.
					a=`readlink -f -- "$a"`
					a=`basename -- "$a"`
					# Is symlink actually a reference to
					# an older installed $BB_TARGET?
					if test x"$a" != x"$BB_TARGET"
					then
						# No, then it's a real command.
						# Skip symlink creation.
						found=true; break
					fi
				else
					found=true; break
				fi
			fi
		done
		$found && continue # Already present in search paths.
		# Create an applet symlink for the missing command.
		ln -s "$BB_TARGET" "$sdir/usr/local/bin/$applet"
	done
}
