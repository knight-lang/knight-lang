#!/bin/bash

# (This program is nearly 100% POSIX-compliant, except the very last line where
# we execute the program. Maybe one day the `< <(cat ...)` can be reworked to
# be POSIX-compliant.)

## Provides a nice interface for running `examples/knight.kn`.
# Even though `examples/knight.kn` fully implements the Knight specifications,
# it requires an interpreter to run, which is what all the different
# implementations supply. To make it easy to execute "knight in knight", this
# file is provided as a way to cleanly execute `examples/knight.kn`.
#
# Note that `bootstrap` will actually read all `-f`s itself, instead of
# deferring them to `examples/knight.kn`: This is because the Knight specs don't
# provide a way for Knight programs to access the file system, and thus this
# shim must do it.
#
# `examples/knight.kn` itself accepts programs in a "HEREDOC" format: it reads
# a single line from stdin, and then will read lines until it sees the exact
# same line again. This program does this for you, so you don't need to think
# about it. (The janky hack is required because the Knight specs don't support
# command-line arguments, so no `-e`, and because `knight.kn` should be able to
# support `PROMPT`, so we couldn't read to the very end either.)
##

if [ "${KNIGHT_TRACE:-0}" -ne 0 ]; then
	export KNIGHT_TRACE="$((KNIGHT_TRACE - 1))"
	set -x
fi

# Safety first!
set -uf

# The name of the script: used in `die` and `usage` messages
readonly scriptname="${0##*/}"

# Print out a message with `$scriptname:` prepended before it, then exit.
die () {
	fmt="%s: $1\\n"
	shift
	# shellcheck disable=SC2059
	printf >&2 "$fmt" "$scriptname" "$@"
	exit 1
}

# Print out the usage
shortusage () { cat; } <<SHORT_USAGE
usage: $scriptname [-vh] [-k path] -e expr [--] [interpreter ...]
       $scriptname [-vh] [-k path] -f path [--] [interpreter ...]
SHORT_USAGE
longusage () { cat; } <<LONG_USAGE
NAME
	$scriptname

SYNOPSIS
	$scriptname [-vh] [-k path] -e expr [--] [interpreter ...]
	$scriptname [-vh] [-k path] -f path [--] [interpreter ...]

OPTIONS
	-h   print out this message and exit.
	-v   print the final command and its stdin before executing it
	-e   the program to execute. Mutually exclusive with '-f'
	-f   the path to execute. Mutually exclusive with '-e'
	-k   sets the path to "knight.kn", overwriting the default \$KNIGHT_KN.

ENVIRONMENT
	\$KNIGHT          Interpreter to use when 'interpreter' isn't supplied.
	                 DEFAULT: ./knight

	\$KNIGHT_KN       Path to 'knight.kn' when -k is not supplied.
	                 DEFAULT: \$KNIIGHT_ROOTDIR/examples/knight.kn

	\$KNIGHT_ROOTDIR  Root directory for knight. Used to default \$KNIGHT_KN.
	                 DEFAULT: directory containing this script.

	\$KNIGHT_TRACE    If nonempty, enables XTRACE at program start. Used for
	                 debugging knight scripts themselves.
LONG_USAGE

################################################################################
#                            Command-line Arguments                            #
################################################################################

## Initial arguments
knight_kn=${KNIGHT_KN:-}
verbose=
unset program # `unset` instead of empty string so we can tell if it was set.

while getopts ':hvf:k:e:' flag; do
	case $flag in
	h) longusage; exit ;;
	v) verbose=1 ;;
	k) knight_kn=$OPTARG ;;

	e)
		[ -n "${program+1}" ] && die 'only one of -e or -f may be given'
		program=$OPTARG ;;
	f)
		[ -n "${program+1}" ] && die 'only one of -e or -f may be given'

		# Ensure we give to Knight the exact program, including
		# any trailing newlines.
		program=$(cat -- "$OPTARG" && printf x) || \
			die "cannot read file: %s" "$OPTARG"
		program=${program%?x} ;;
	:)  die 'missing required argument for -%s' "$OPTARG"  ;;
	\?) die 'unknown option: -%s' "$OPTARG" ;;
	esac
done

shift $((OPTIND - 1))

# Default interpreter
[ $# -eq 0 ] && set -- "${KNIGHT:-./knight}"

################################################################################
#                              Validate Arguments                              #
################################################################################

# Since we don't want to do any manipulations of `program` so that `knight.kn`
# receives the entire program, we check for whether or not `program` is set, not
# if it's empty.
[ -z "${program+1}" ] && { shortusage >&2; exit 1; }

# Find the knight.kn path, which is what's going to happen the vast majority of
# the time. In that case, it's relative to this program.
if [ -z "$knight_kn" ]; then
	if [ -z "${KNIGHT_ROOTDIR-}" ]; then
		# We gotta do this trick in case the directory ends in a newline
		# for some bizarre reason.
		{
			KNIGHT_ROOTDIR=$(dirname -- "$0" && printf x) &&
			KNIGHT_ROOTDIR=$(realpath -- "${KNIGHT_ROOTDIR%?x}" && printf x)
			KNIGHT_ROOTDIR=$(dirname -- "${KNIGHT_ROOTDIR%?x}" && printf x);
		} || {
			die 'cannot get enclosing directory of: %s' "$0"
		}
		KNIGHT_ROOTDIR=${KNIGHT_ROOTDIR%?x}
	fi

	# Ensure that `knight.kn` actually exists
	knight_kn=$KNIGHT_ROOTDIR/examples/knight.kn
	if [ ! -f "$knight_kn" ]; then
		die "the default knight.kn doesn't exist: %s" "$knight_kn"
	fi
fi

################################################################################
#                            Find Unique EOF Marker                            #
################################################################################

# Because people calling this script might be nesting multiple Knight invocatio-
# ns themselves, this finds a unique string that can be used as the "heredoc"
# and is guaranteed not to already exist in the code.
iter=0
newline='
'
while
	# Use an `X` at the start to make it less likely that we'll get a match,
	# as `examples/knight.kn` doesn't used `X`.
	unique_string=X_END_OF_KNIGHT_PROGRAM_$iter
	! case $program in *"$newline$unique_string$newline"*) false; esac
do
	iter=$((iter + 1))
done

################################################################################
#                             Execute the Program                              #
################################################################################
program="$unique_string
$program
$unique_string
" # Has to be on its own line

# TODO: make this posix-compliant
exec < <(printf %s "$program"; cat 2>&-)

if [ -n "$verbose" ]; then
	cat <<END >&2
==PROGRAM=================
$program==END OF PROGRAM=================

END
	PS4= # so `set -x` doesn't print out the leading `+`
	set -x
fi

"$@" -f "$knight_kn"
