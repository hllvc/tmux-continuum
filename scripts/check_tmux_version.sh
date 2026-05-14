#!/usr/bin/env bash

VERSION="$1"

# Parse "major.minor" from a version string like "tmux 3.4" or "1.9a".
parse_major() { echo "${1%%.*}"; }
parse_minor() { local m="${1#*.}"; echo "${m%%[^0-9]*}"; }

tmux_version_string() {
	tmux -V | sed 's/tmux //'
}

version_at_least() {
	local required="$1"
	local current
	current="$(tmux_version_string)"
	local req_major req_minor cur_major cur_minor
	req_major="$(parse_major "$required")"
	req_minor="$(parse_minor "$required")"
	cur_major="$(parse_major "$current")"
	cur_minor="$(parse_minor "$current")"
	[ "$cur_major" -gt "$req_major" ] || \
		{ [ "$cur_major" -eq "$req_major" ] && [ "${cur_minor:-0}" -ge "$req_minor" ]; }
}

main() {
	if ! version_at_least "$VERSION"; then
		exit 1
	fi
}
main
