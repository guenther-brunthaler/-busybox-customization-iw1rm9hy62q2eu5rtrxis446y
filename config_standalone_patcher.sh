#! /bin/sh
# Filter for modifying a normalized configuration as created by
# ./config_normalizer, enabling options to build a statically-linked
# "stand-alone" version of Busybox, which allows all applets to be used in the
# built-in shell without actually installing them anywhere in the real file
# system. This is very convenient when used for emergency recovery, but has
# the severy disadvantage that PATH is mostly ignored and the only way to
# override the built-in applets is manually specifying the full path to a
# replacement utility.
#
# Version 2020.145
# Copyright (c) 2019-2020 Günther Brunthaler. All rights reserved.
#
# This script is free software.
# Distribution is permitted under the terms of the GPLv3.

static=config_static_patcher.sh

set -e
APP=${0##*/}
trap 'test $? = 0 || echo "$APP failed!" >& 2' 0

while getopts '' opt
do
	case $opt in
		*) false || exit
	esac
done
shift `expr $OPTIND - 1 || :`

test $# = 0

static=`dirname -- "$0"`/$static
test -f "$static"

sh -- "$static" \
| sed '
	s/^\(FEATURE_SH_STANDALONE\)=.*/\1/
	s/^FEATURE_SH_STANDALONE$/&=y/
'
