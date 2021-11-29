#!/bin/sh
set -ex

# ----------------------------------------------------------------------
# CONFIGURATION

# "dev" to run latest development/test version
# "master" to run stable production version
BRANCH="dev"

# Where the game is supposed to be installed
INSTALLDIR="$HOME/.minetest/games/nodecore"

# A place to keep persistent staging files
STAGEDIR="$HOME/.nodecore"

# Original/mirror public git source repo
SRCREPO="https://gitlab.com/sztest/nodecore"

# ----------------------------------------------------------------------

throw() { set +ex; echo >&2; echo "ERROR: $*" >&2; echo >&2; exit 1; }

# Make sure all prereqs are available up-front, so any missing
# prereq errors happen immediately and not after a long-running
# op has started and user is no longer watching.
PREREQS="git rsync"
for X in $PREREQS; do
	if ! which "$X" >/dev/null; then
		throw "$X not found (requires: $PREREQS)" >&2
	fi
done

# Safety checks to avoid overwriting anything else
if [ -d "$INSTALLDIR" ]; then
	# Don't destroy actual working clones of the game
	if [ -e "$INSTALLDIR/.git" ]; then
		throw "$INSTALLDIR/.git exists; remove before retrying" >&2
	fi
	# Don't destroy other games or arbitrary other dirs
	if ! grep -q '^\s*name\s*=\s*NodeCore' "$INSTALLDIR/game.conf"; then
		throw "$INSTALLDIR exists but is not a copy of NodeCore; remove before retrying" >&2
	fi
elif [ -e "$INSTALLDIR" ]; then
	# Don't destroy files or other objects
	throw "$INSTALLDIR exists but is not a dir; remove before retrying" >&2
fi

# Mirror just the selected branch into local cache repo.
mkdir -p "$STAGEDIR"
cd "$STAGEDIR"
git init --bare
git fetch "$SRCREPO" "$BRANCH"
git branch -f current FETCH_HEAD
git gc --auto

# Create a temp dir (auto cleanup) to stage export.
export TMPD=`mktemp -d -t "${0##*/}-$$-XXXXXXXXXXXXXXXX"`
trap 'S=$?; cd /tmp; rm -rf "$TMPD"; exit $S' TERM INT HUP ALRM PIPE exit

# Extract an export of the repo, which includes correct
# version tagging, and excludes unnecessary sources.
git archive --format=tar current | tar -C "$TMPD" -xf -

# Install export to destination and cleanup old files.
rsync -rlt --inplace --delete-after "$TMPD/" "$INSTALLDIR/"