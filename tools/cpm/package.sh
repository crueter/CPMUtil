#!/bin/sh -e

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

RETURN=0

usage() {
	cat <<EOF
Usage: cpmutil.sh package [command]

Operate on a package or packages.

Commands:
    hash            	Verify the hash of a package, and update it if needed
    update          	Check for updates for a package
    fetch           	Fetch a package and place it in the cache
    add             	Add a new package
    rm              	Remove a package
    version         	Change the version of a package
    which           	Check if a package is defined
    url             	Get the download URL for a package
    dir             	Get the local directory for a package
    reset           	Reset a fetched package to its original state
    patch           	Create an in-tree patch based on local modifications
    get-updater-info	Output updatable package info (key git_host repo version)

EOF

	exit $RETURN
}

SCRIPTS=$(CDPATH='' cd -- "$(dirname -- "$0")/package" && pwd)
CMAKE="$CMAKE/package"

export SCRIPTS CMAKE

while :; do
	case "$1" in
	dir | fetch | hash | reset | rm | url | version | which | get-updater-info)
		cmd="$1"
		shift
		cmake -P "$CMAKE/$cmd.cmake" -- "$@"
		break
		;;
	add | patch | update)
		cmd="$1"
		shift
		"$SCRIPTS/$cmd".sh "$@"
		break
		;;
	*) usage ;;
	esac

	shift
done
