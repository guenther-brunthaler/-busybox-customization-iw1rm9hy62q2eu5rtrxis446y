#! /bin/sh
# Filter for modifying a normalized configuration as created by
# ./config_normalizer, enabling options to build a static Busybox version
# instead of the default dynamically-linked one.
#
# Version 2020.145
# Copyright (c) 2019-2020 Günther Brunthaler. All rights reserved.
#
# This script is free software.
# Distribution is permitted under the terms of the GPLv3.

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

sed '
	s/^\(STATIC\)=.*$/\1/
	s/^STATIC$/&=y/
'
