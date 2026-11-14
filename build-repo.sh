#!/usr/bin/env bash
# Build packages from this tree and refresh the vistree pacman repository.
#
# Usage:
#   ./build-repo.sh                 build every package
#   ./build-repo.sh andy scs        build only the named packages
#
# Environment:
#   REPO        output directory for packages and the repo database (default: ./repo)
#   BUILDDIR    makepkg build directory                         (default: ./.build)
#   SRCDEST     downloaded source cache                         (default: ~/kernelbuild)
#   DB_NAME     repository database name                        (default: vistree)
#   MAKEPKG_OPTS extra options passed to makepkg                (default: empty)
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO="${REPO:-$ROOT/repo}"
BUILDDIR="${BUILDDIR:-$ROOT/.build}"
SRCDEST="${SRCDEST:-$HOME/kernelbuild}"
DB_NAME="${DB_NAME:-vistree}"
MAKEPKG_OPTS="${MAKEPKG_OPTS:-}"

usage() {
	cat <<EOF
Usage: $(basename "$0") [package ...]

Build packages from this tree and update the $DB_NAME repository database.
With no arguments every package in the tree is built.

Environment overrides:
  REPO=$REPO
  BUILDDIR=$BUILDDIR
  SRCDEST=$SRCDEST
  DB_NAME=$DB_NAME
  MAKEPKG_OPTS=$MAKEPKG_OPTS
EOF
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
	usage
	exit 0
fi

targets=()
for arg in "$@"; do
	if [[ -f "$arg/PKGBUILD" ]]; then
		targets+=("$(cd -- "$arg" && pwd)")
	elif [[ -f "$ROOT/$arg/PKGBUILD" ]]; then
		targets+=("$ROOT/$arg")
	else
		printf 'error: no PKGBUILD found for %s\n' "$arg" >&2
		exit 1
	fi
done

if ((${#targets[@]} == 0)); then
	while IFS= read -r pkgbuild; do
		targets+=("$(dirname -- "$pkgbuild")")
	done < <(
		find "$ROOT" -mindepth 2 -maxdepth 3 -name PKGBUILD -print | sort |
			while IFS= read -r pkgbuild; do
				# Skip recipes nested inside another recipe's directory.
				if [[ ! -f "$(dirname "$(dirname "$pkgbuild")")/PKGBUILD" ]]; then
					printf '%s\n' "$pkgbuild"
				fi
			done
	)
fi

mkdir -p "$REPO" "$BUILDDIR"

failures=()

for dir in "${targets[@]}"; do
	if [[ "$dir" == "$ROOT"/* ]]; then
		name="${dir#"$ROOT"/}" # e.g. "andy" or "artix/system/bash"
	else
		name="$(basename -- "$dir")"
	fi
	key="${name//\//-}" # unique per recipe, safe as a directory name
	printf '==> Building %s\n' "$name"
	# shellcheck disable=SC2086 # MAKEPKG_OPTS is intentionally word-split
	if ! (
		cd -- "$dir"
		PKGDEST="$REPO" \
		BUILDDIR="$BUILDDIR/$key" \
		SRCDEST="$SRCDEST" \
			makepkg --force --noconfirm $MAKEPKG_OPTS
	); then
		failures+=("$name")
	fi
done

mapfile -t packages < <(
	find "$REPO" -maxdepth 1 -type f -name '*.pkg.tar.*' ! -name '*.sig' -print | sort
)

if ((${#packages[@]} == 0)); then
	printf 'error: no packages found in %s\n' "$REPO" >&2
	exit 1
fi

printf '==> Updating %s database\n' "$DB_NAME"
repo-add --remove "$REPO/$DB_NAME.db.tar.gz" "${packages[@]}"

if ((${#failures[@]})); then
	printf 'error: failed to build: %s\n' "${failures[*]}" >&2
	exit 1
fi

printf '==> Repository ready: %s\n' "$REPO"
