#!/bin/sh -e

# SPDX-FileCopyrightText: Copyright 2026 crueter
# SPDX-License-Identifier: LGPL-3.0-or-later

filter_out() {
	TAGS=$(echo "$TAGS" | jq "[.[] | select(.name | test(\"$1\"; \"i\") | not)]")
}

filter_in() {
	TAGS=$(echo "$TAGS" | jq "[.[] | select(.name | test(\"$1\"; \"i\"))]")
}

usage() {
	cat <<EOF
Usage: cpmutil.sh package update [-n|--dry-run] [-a|--all] [PACKAGE]...

Check a specific package or packages for updates.

Options:
    -n, --dry-run 	Do not update the package if it has an update available
    -a, --all    	Operate on all packages in this project.
    -c, --commit   	Automatically generate a commit message

EOF

	exit 0
}

while :; do
	case "$1" in
	-[a-z]*)
		opt=$(printf '%s' "$1" | sed 's/^-//')
		while [ -n "$opt" ]; do
			char=$(echo "$opt" | cut -c1)
			opt=$(echo "$opt" | cut -c2-)

			case "$char" in
			a) ALL=1 ;;
			n) UPDATE=false ;;
			c) COMMIT=true ;;
			h) usage ;;
			*) die "Invalid option -$char" ;;
			esac
		done
		;;
	--dry-run) UPDATE=false ;;
	--all) ALL=1 ;;
	--help) usage ;;
	--commit) COMMIT=true ;;
	"$0") break ;;
	"") break ;;
	*) packages="$packages $1" ;;
	esac

	shift
done

[ "$ALL" != 1 ] || packages="${LIBS:-$packages}"
: "${UPDATE:=true}"
: "${COMMIT:=false}"

if [ -n "$packages" ]; then
	# shellcheck disable=SC2086
	info=$(cmake -P "$CMAKE/get-updater-info.cmake" -- $packages)
else
	info=$(cmake -P "$CMAKE/get-updater-info.cmake" --)
	[ -n "$info" ] || usage
fi

while read -r key git_host repo version artifact; do
	[ -n "$key" ] || continue

	echo "-- Package $key"

	# TODO(crueter): Support for forgejo_token?
	if [ "$artifact" != "null" ]; then
		endpoint="/repos/$repo/releases"
	else
		endpoint="/repos/$repo/tags"
	fi

	if command -v gh >/dev/null 2>&1; then
		TAGS=$(gh api --method GET "$endpoint")
	elif [ "$git_host" = github.com ]; then
		TAGS=$(curl -sfL "https://api.github.com$endpoint")
	else
		TAGS=$(curl -sfL "https://$git_host/api/v1$endpoint")
	fi

	# normalize releases to tags format for filtering
	if [ "$artifact" != "null" ]; then
		TAGS=$(echo "$TAGS" | jq '[.[] | {name: .tag_name}]')
	fi

	# filter out some commonly known annoyances
	# TODO add more

	if [ "$key" = "vulkan-validation-layers" ]; then
		filter_in vulkan-sdk
	else
		filter_out vulkan-sdk
	fi

	filter_out yotta # mbedtls

	filter_out vksc

	# ignore betas/alphas (remove if needed)
	filter_out alpha
	filter_out beta
	filter_out rc

	# Add package-specific overrides here, e.g. here for fmt:
	[ "$key" != fmt ] || filter_out v0.11

	# Or for OpenSSL:
	if [ "$key" = openssl ]; then
		filter_out rsaref
		filter_in "openssl-"
	fi

	LATEST=$(echo "$TAGS" | jq -r '.[0].name')

	if [ "$LATEST" = "null" ] ||
		{ [ "$LATEST" = "$version" ] && [ "$FORCE" != "true" ]; }; then
		echo "-- * Up-to-date"
		continue
	fi

	_commit="$_commit
* $key: $version -> $LATEST"

	echo "-- * Version $LATEST available, current is $version"

	if [ "$UPDATE" = "true" ]; then
		cmake -P "$CMAKE/version.cmake" -- "$key" "$LATEST"
	fi
done <<EOF
$info
EOF

if [ "$UPDATE" = "true" ] && [ "$COMMIT" = "true" ] && [ -n "$_commit" ]; then
	git add "cpmfile.json"
	git commit -m "Update dependencies
$_commit"
fi
