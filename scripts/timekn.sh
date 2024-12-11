#!/bin/sh

# Support the user's preferred shell, which allows for timing mechanisms
if [ -z "$__TIMEKN_HAS_BEEN_RUN" ] && [ -n "$SHELL" ]; then
	__TIMEKN_HAS_BEEN_RUN=1 exec "$SHELL" -- "$0" "$@"
fi

# Support `KNIGHT_TRACE`, which is used for debugging knight-lang scripts.
if [ "${KNIGHT_TRACE:=0}" -ne 0 ]; then
	export KNIGHT_TRACE="$((KNIGHT_TRACE - 1))"
	_xtrace=1
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
	printf >&2 "$fmt" "$scriptname" "$@"
	exit 1
}

# Print out the usage
shortusage () { cat; } <<SHORT_USAGE
usage: $scriptname [-och] [-n count] [--] args-for-bootstrap ...
SHORT_USAGE

usage () { cat; } <<USAGE
NAME
	$scriptname

SYNOPSIS
	$scriptname [-ocCh] [-n count] [--] args-for-bootstrap ...

DESCRIPTION
	Wrapper around 'bootstrap.sh' that executes it \`count\` times and
	prints the execution duration. Used to time Knight implementations. By
	default, the output of 'bootstrap.sh' is surpressed, and any non-zero
	return statuses by it are

OPTIONS
	-h   Print out this message and exit.
	-n   Specify the amount of times to iterate. Defaults to 50.
	-o   Don't surpress the stdout of knight programs.
	-c   Continue even if a Knight implementation fails.
	-s   Ensure 'count' successful results happen. Implies '-c'
USAGE

quiet=1
abort=1
count=50
require_success=

while getopts ':hocsn:' flag; do
	case $flag in
	h) usage; exit ;;
	o) quiet= ;;
	c) abort= ;;
	s) abort= require_success=1 ;;
	n)
		case $OPTARG in
			*[!0-9]*) die 'count expects an integer'
		esac
		count=$OPTARG
		;;
	:) die 'missing required argument for -%s' "$OPTARG"  ;;
	?) break ;;
	esac
done

## Delete the parsed arguments
[ -n "${ZSH_VERSION-}" ] && : $((OPTIND+=1)) # Bug with zsh?
shift $((OPTIND - 2))

set -e

timescript=$(mktemp)

# Ensure `timescript` is removed when we exit
cleanup () { rm -f "$timescript"; }
trap cleanup EXIT
for signal in HUP INT QUIT TERM; do
    # shellcheck disable=SC2064
    trap "cleanup || :; trap - $signal EXIT; kill -s $signal $$" "$signal"
done

chmod u+x "$timescript"

# If `KNIGHT_TRACE` is enabled, then add it to the shell file.
[ "${KNIGHT_TRACE}" -ne 0 ] && cat <<'SHELL' >>$timescript
if [ "${KNIGHT_TRACE:-0}" -ne 0 ]
then
	KNIGHT_TRACE="$((KNIGHT_TRACE - 1))"
	export KNIGHT_TRACE
	set -x
fi
SHELL

# If the script's quiet, have it redirect its stdout to `/dev/null`
[ -n "$quiet" ] && echo 'exec >/dev/null' >>$timescript

# If we're aborting on error, add the `abort` function, and export this script's
# name for the error message
if [ -n "$abort" ]; then
	cat <<'SHELL' >>$timescript
abort () {
	status=$?
	printf >&2 '%s: execution #%d failed with status %d\n' \
		"$__TIMEKN_SCRIPT_NAME" $1 $status
	exit $status
}
SHELL
	export __TIMEKN_SCRIPT_NAME="$scriptname"
fi

# Output the meat of the program into the script. Note that we've already done
# validation for `count` when it was assigned, so no need to quote it.
[ -n "$require_success" ] &&
cat <<SHELL >>$timescript
i=0
while [ \$((i+=1)) -le $count ]
do
	"\$@" ${abort:+|| abort \$i} ${require_success:+|| i=\$((i-1))}
done
SHELL

# Get the path to the bootstrap function
if [ -n "${KNIGHT_ROOTDIR-}" ]; then
	bootstrap=$KNIGHT_ROOTDIR/scripts/bootstrap.sh
else
	enclosing_dir=$(dirname -- "$0" && printf x)
	bootstrap=${enclosing_dir%?x}/bootstrap.sh
fi

[ -n "${_xtrace-}" ] && cat "$timescript"

# Populate the command that `time` will use
set -- "$timescript" "$bootstrap" "$@"

# If `time` is not a builtin shell construct, ensure `--` is the first arg.
# (This is needed because in shells like bash or zsh, `time` is a keyword which
# doesn't support leading `--`s, whereas in dash `time` is the POSIX-required
# `time` program)
[ "$(command -v time)" != time ] && set -- -- "$@"

# Use `/bin/sh` instead of $SHELL to ensure we're executing the POSIX-compliant
# timescript program with a POSIX-compliant shell.
time -p /bin/sh "$@"
