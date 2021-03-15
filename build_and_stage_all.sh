#! /bin/sh
# Builds three versions of busybox and creates a staging area ready for
# installation. The three versions built are, in this order: A standalone
# statically-linked version, a statically-linked version, and a dynamically
# linked version.
#
# Two arguments are required: the path to a normalized configuration file
# representing the configuration for the dynamically-linked version, and the
# path of the directory to the BusyBox source files. Before the build starts,
# local custom patches will be applied automatically. After the build has
# finished, the patches will be removed again, and all (or at least most)
# temporary files created by the build will be deleted.

target=busybox
generic_prefix=all-

set -e
APP=${0##*/}
trap 'test $? = 0 || echo "$APP failed!" >& 2' 0

die() {
	echo "$*" >& 2
	false || exit
}

mkabs() {
	test "$1"
	case $1 in
		*/*) result=$1;;
		*) result=`pwd`/$1
	esac
}

test $# = 2
mkabs "$1"; config=$result
test -f "$config"
case `basename -- "$config"` in
	$generic_prefix*) generic=true;;
	*) generic=false
esac
mkabs "$2"; bdir=$result
test -d "$bdir"

mkabs "$0"; test -f "$result"
cdir=`dirname -- "$result"`
test -d "$cdir"
cd -- "$cdir"

./apply-patches.sh push "$bdir" || :

if make --version 2>& 1 | grep -q GNU
then
	n=`getconf _NPROCESSORS_ONLN`
	n=`expr $n + 1`
	export MAKEFLAGS="-j$n -l$n"
else
	unset MAKEFLAGS
fi

oldIFS=$IFS
for b in \
	./config_standalone_patcher.sh:busybox.standalone \
	./config_static_patcher.sh:busybox.static \
	cat
do
	set -f; IFS=:; set -- $b; IFS=$oldIFS; set +f
	"$1" < "$config" | ./config_normalizer -u > "$bdir"/.config
	(
		cd -- "$bdir"
		make oldconfig
		make || :
		test -f "$target"; test -x "$target"
		case $2 in
			'') ;;
			*) mv -- "$target" "$2"
		esac
	)
done

set ./stage_installation.sh
$generic && set "$@" -g
"$@" "$bdir"

(
	cd -- "$bdir"
	make distclean
	make mrproper
)

./apply-patches.sh pop "$bdir" || :
