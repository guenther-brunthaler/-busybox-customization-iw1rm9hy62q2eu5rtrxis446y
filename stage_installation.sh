#! /bin/sh
TAGFILE=miscutils/bbconfig.c
TAGDIR=../patches
BB_TARGET=busybox-pbyqxzl1ktqlk3fjm3arlrclg
BB_LINK=busybox-localsite
STAGES_SUBDIR=stages

set -e
APP=${0##*/}
trap 'test $? = 0 || echo "$APP failed!" >& 2' 0

if test ! -f "$TAGFILE" || test ! -d "$TAGDIR"
then
	echo "Run $APP from the BusyBox top-level source directory!" >& 2
	false || exit
fi
c1=`basename -- "\`pwd\`"`
test -n "$c1"
c2=`hostname`
test -n "$c2"
c3=`stat -c %W busybox`
case $c3 in
	[1-9]*) ;;
	*) c3=`stat -c %Y busybox`; test -n "$c3"
esac
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
