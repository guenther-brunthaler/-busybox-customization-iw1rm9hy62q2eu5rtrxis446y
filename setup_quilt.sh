#! /bin/false
# *Source* this, don't try to execute it.
hw4tpsl60mzd5e2muvvvwymvg_0=`pwd`
hw4tpsl60mzd5e2muvvvwymvg_1=$hw4tpsl60mzd5e2muvvvwymvg_0/patches
if test -d "$hw4tpsl60mzd5e2muvvvwymvg_1"
then
	set -x
	export QUILT_PATCHES=$hw4tpsl60mzd5e2muvvvwymvg_1
	set +x
else
	echo "Missing '$hw4tpsl60mzd5e2muvvvwymvg_1'!" >& 2
fi
hw4tpsl60mzd5e2muvvvwymvg_1=`
	find "$hw4tpsl60mzd5e2muvvvwymvg_0" \
		-path "$hw4tpsl60mzd5e2muvvvwymvg_0/busybox*" -type d \
		'(' -name "*.git" -prune -o -print -prune ')'
`
hw4tpsl60mzd5e2muvvvwymvg_1=$hw4tpsl60mzd5e2muvvvwymvg_1/.pc
if test -d "$hw4tpsl60mzd5e2muvvvwymvg_1"
then
	set -x
	export QUILT_PC=$hw4tpsl60mzd5e2muvvvwymvg_1
	set +x
else
	echo "Missing '$hw4tpsl60mzd5e2muvvvwymvg_1'!" >& 2
fi
unset hw4tpsl60mzd5e2muvvvwymvg_0 hw4tpsl60mzd5e2muvvvwymvg_1
