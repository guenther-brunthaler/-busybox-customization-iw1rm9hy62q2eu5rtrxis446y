#! /bin/sh
set -e
DEBUG=Y

# Variables:
# s_${ESCAPED_SETTING_VALUE}=${SETTING_NUMBER}
# sn_${SETTING_NUMBER}=${SETTING_VALUE}
# sn_${SETTING_NUMBER}_rc=${MAPPINGS_REF_COUNT}
# sn_${SETTING_NUMBER}_next=${NEXT_SETTING_NUMBER_OR_UNDEF}
# c_${CONFIG_NUMBER}=${CONFIG_NAME}
# c_${CONFIG_NUMBER}_ts=`date -d "$WHEN_CREATED" --rfc-3339=seconds`
# c_${CONFIG_NUMBER}_next=${NEXT_CONFIG_NUMBER_OR_UNDEF}
# m_${CONFIG_NUMBER}_${SETTING_NUMBER}=${NEXT_MAPPING_KEY_OR_UNDEF}

# Merged file format (numerically sorted by first 2 fields):
# 1 <SETTING_NUMBER> <SETTING_VALUE>
# ...
# 2 <CONFIG_NUMBER> <RFC3339_DATE> <RFC3339_TIME> <CONFIG_NAME>
# ...
# 3 <CONFIG_NUMBER> <SETTING_NUMBER>
# ...

die() {
	echo "ERROR: $*" >& 2
	false || exit
}

tag=lnuy0rbhsijwhi42zpugchabc
if [ x"$1" != x"$tag" ]; then
	# Run with clean environment in order to avoid conflicts with variable
	# name collisions.
	set -- "$0" "$tag" "$@"
	test -n "$-" && set -- -"$-" "$@"
	set -- "${SHELL:-/bin/sh}" "$@"
	set env -i TERM="$TERM" PATH="$PATH" "$@"
	exec "$@"
	die "Could not re-exec '$@'!"
fi
shift

cleanup() {
	test -n "$DEBUG" && set > set.txt
	rm -- "$T"
	test -z "$OK" && echo "Failed!" >& 2
}
OK=
APP=${0##*/}
T=`mktemp --tmpdir "$APP".XXXXXXXXXX`
trap cleanup 0

# Double all literal "Q"s.
# Pass literally all remaining alphanumerics and underscore.
# Transform all other characters into "Q" followed by 2-digit codepoint.
mangle_SV() {
	local w head tail off
	SV=`printf %s "$SV" | sed 's/Q/QQ/g'`
	while off=`expr x"$SV" : x'.*[^A-Za-z0-9_]'`
	do
		w=
		while [ $off -gt 2 ]; do
			w=$w"?"
			: $((off-= 1))
		done
		head=${SV#$w}; SV=${SV%"$head"}
		tail=${head#?}; head=${head%"$tail"}
		head=`
			printf '%s' "$head" | od -tx1 | {
				read dummy hex; echo Q$hex
			}
		`
		SV=$SV$head$tail
	done
}

# $1=\$$2
getvar() {
	eval "$1=\$$2"
}

# $1=$2
setvar() {
	local v_4i96tzfs9l3exrb3v5a0upu8v_1
	v_4i96tzfs9l3exrb3v5a0upu8v_1=$2
	getvar "$1" v_4i96tzfs9l3exrb3v5a0upu8v_1
}

# test -z "\$$1" test -n "$2" && $1=$2
setnewvar() {
	local v_4i96tzfs9l3exrb3v5a0upu8v_2
	eval "v_4i96tzfs9l3exrb3v5a0upu8v_2=\$$1"
	test -z "$v_4i96tzfs9l3exrb3v5a0upu8v_2" || die "Duplicate value" \
		"in line $lineno (variable '$1' already set)!"
	test -n "$2" || die "Attempt to set empty value" \
		"in line $lineno (for variable '$1')!"
	v_4i96tzfs9l3exrb3v5a0upu8v_2=$2
	getvar "$1" v_4i96tzfs9l3exrb3v5a0upu8v_2
}

unsetvar() {
	unset $* 2> /dev/null || :
}

# Use $first_sn, $last_sn, $max_sn, $SV, $index, $line.
add_setting() {
	test -z "$first_sn" && first_sn=$index
	setnewvar s_"$SV" "$index"
	setnewvar sn_"$index" "$line"
	setnewvar sn_"$index"_rc 0
	test -n "$last_sn" && setvar sn_"$last_sn"_next "$index"
	last_sn=$index
	test $index -gt $max_sn && max_sn=$index
}

# Use $first_c, $last_c, $max_c, $index, $cname, $ts.
add_config() {
	test -z "$first_c" && first_c=$index
	setnewvar c_"$index" "$cname"
	setnewvar c_"$index"_ts "$ts"
	unsetvar c_"$index"_next
	test -n "$last_c" && setvar c_"$last_c"_next "$index"
	last_c=$index
	test $index -gt $max_c && max_c=$index
}

# Use $first_m, $last_m, $m.
add_mapping() {
	local rc rcv
	test -z "$first_m" && first_m=$m
	unsetvar m_$m
	rcv=sn_${m#*_}_rc
	getvar rc $rcv
	setvar $rcv $((rc + 1))
	test -n "$last_m" && setvar m_"$last_m" "$m"
	last_m=$m
}

KEEP=
DELETE_CONFIG=
while getopts kd OPT; do
	case $OPT in
		k) KEEP=Y;;
		d) DELETE_CONFIG=Y;;
		*) false
	esac
done
shift $((OPTIND - 1))

merge_target=${1:?"Specify merge target file (empty file is allowed)"}
test -n "$merge_target"
test -f "$merge_target"
title=${2:?"Specify title of new config to merge or delete"}
test -n "$title"
add_config=$3
test $# -gt 3 && die "To many arguments!"
test -n "$add_config" && exec < "$add_config"

# Read current merge file.
first_sn=
last_sn=
max_sn=0
first_c=
last_c=
max_c=0
first_m=
last_m=
lineno=1
while read kind index line; do
	case $kind in
		1)
			SV=$line; mangle_SV
			add_setting
			test -n "$DEBUG" && printf 1 >& 2
			;;
		2)
			cname=${line#* * }; cname=${cname## }
			ts=${line%"$cname"}; ts=${ts%% }
			test -n "$ts"
			test -n "$cname"
			add_config
			test -n "$DEBUG" && printf 2 >& 2
			;;
		3)
			m=${index}_$line
			add_mapping
			test -n "$DEBUG" && printf 3 >& 2
			;;
		*) die "Unknown line type '$kind'!"
	esac
	: $((lineno+= 1))
done < "$merge_target"


if [ -n "$DELETE_CONFIG" ]; then
	deleted=0
	dmaps=0
	ncp=first_c
	while :
	do
		getvar ci "$ncp"
		test -z "$ci" && break
		getvar cname c_"$ci"
		if [ x"$cname" = x"$title" ]; then
			# Delete all associated mappings first.
			nmp=first_m
			while true; do
				getvar m "$nmp"
				test -z "$m" && break
				case $m in
					"$ci"_*)
						getvar $nmp m_"$m"
						unsetvar "$m"
						rcv=sn_${m#*_}_rc
						getvar rc $rcv
						setvar $rcv $((rc - 1))
						: $((dmaps+= 1))
						continue
				esac
				nmp=m_$m
			done
			getvar $ncp c_${ci}_next
			unsetvar c_${ci}
			unsetvar c_${ci}_ts
			: $((deleted+= 1))
			continue
			
		fi
		ncp=c_${ci}_next
	done
	echo "$deleted configurations with $dmaps mappings" \
		"have been deleted." >& 2
else
	# Add config definition.
	ci=$((max_c + 1))
	index=$ci
	cname=$title
	ts=`date --rfc-3339=seconds`
	add_config

	# Merge config.
	lineno=1
	while read line; do
		SV=$line; mangle_SV
		getvar index s_"$SV"
		if [ -z "$index" ]; then
			index=$((max_sn + 1))
			add_setting
		fi
		m=${ci}_$index
		add_mapping
		: $((lineno+= 1))
		test -n "$DEBUG" && printf M >& 2
	done
fi

# Write merged config.
{
	index=$first_sn
	while [ -n "$index" ]; do
		getvar line sn_"$index"
		getvar rc sn_"$index"_rc
		test x"$rc" != x"0" && echo "1 $index $line"
		getvar index sn_"$index"_next
		test -n "$DEBUG" && printf 1 >& 2
	done
	index=$first_c
	while [ -n "$index" ]; do
		getvar cname c_"$index"
		getvar ts c_"$index"_ts
		echo "2 $index $ts $cname"
		getvar index c_"$index"_next
		test -n "$DEBUG" && printf 2 >& 2
	done
	index=$first_m
	while [ -n "$index" ]; do
		echo "3 $index"
		getvar index m_"$index"
		test -n "$DEBUG" && printf 3 >& 2
	done | tr _ " "
} > "$T"
# Rename written config replacing original.
mode=`stat -c %a -- "$merge_target"`
tn=${merge_target}.orig
mv -- "$merge_target" "$tn"
cat -- "$T" > "$merge_target"
chmod -- $mode "$merge_target"
test -z "$KEEP" && rm -- "$tn"
OK=Y
