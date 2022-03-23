#! /bin/sh
#
# Takes the path to the BusyBox source repository as the only non-option
# argument.
#
# The source repository needs to be a (bare or non-bare) git repository and
# will be cloned into a temporary build directory created in /tmp (use $TMPDIR
# to override). Then a symlink to that directory will be created in the
# current directory as '$tmp_symlink'.
#
# It is YOUR reponsibility to remove the symlink
# as well as the temporary build directory after you are done with it!
#
# Options:
#
# -b <branch>: Use this if a different branch than the currently checked-out
# one contains the BusyBox source files to be used.
#
# -d: This will remove a previously created temporary build directory as well
# as the symlink pointing to it. Use this for cleaning up after you are done.
# This expects the symlink to exist in the current directory.
#
# Version 2022.82.1
#
# Copyright (c) 2022 Guenther Brunthaler. All rights reserved.
#
# This source file is free software.
# Distribution is permitted under the terms of the GPLv3.

tmp_symlink='./build'

set -e
APP=${0##*/}
trap 'test $? = 0 || echo "\"$APP\" failed!" >& 2' 0

specific_branch=
delete_builddir=false
while getopts db: opt
do
	case $opt in
		d) delete_builddir=true;;
		b) specific_branch=$OPTARG;;
		*) false || exit
	esac
done
shift `expr $OPTIND - 1 || :`

if $delete_builddir
then
	test -L "$tmp_symlink"
	dst=`readlink -f -- "$tmp_symlink"`
	test -d "$dst/.git"
	echo "Removing temporary build directory '$dst'..."
	rm -rf -- "$dst"
	echo "Also removing the symlink to it ('$tmp_symlink')."
	rm -- "$tmp_symlink"
else
	test $# = 1
	src=$1
	test ! -e "$tmp_symlink"
	dst=`mktemp -d -- "${TMPDIR:-/tmp}/${0##*/}".XXXXXXXXXX`
	ln -s -- "$dst" "$tmp_symlink"
	echo "A temporary build directory has been created!"
	echo "A symlink '$tmp_symlink' pointing to it has also been created."
	echo
	echo "Repeat command with option -d in order to delete both."
	echo
	echo "Cloning the git source repository into the new directory..."
	echo
	set git clone -s
	test "$specific_branch" && set "$@" -b "$specific_branch"
	"$@" -- "$src" "$dst"
fi
echo "Done."
