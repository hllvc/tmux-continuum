#!/usr/bin/env bash

# Maintainer: Sven Vowe @nuclearglow
# Contact maintainer for any change to this file.

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/../helpers.sh"
source "$CURRENT_DIR/../variables.sh"

template() {
	local resurrect_save_script_path
	resurrect_save_script_path="$(get_tmux_option "$resurrect_save_path_option" "")"
	local tmux_path
	tmux_path="$(command -v tmux)"
	local systemd_tmux_server_start_cmd
	systemd_tmux_server_start_cmd="$(get_tmux_option "${systemd_tmux_server_start_cmd_option}" "${systemd_tmux_server_start_cmd_default}")"

	cat <<-EOF
	[Unit]
	Description=tmux default session (detached)
	Documentation=man:tmux(1)

	[Service]
	Type=forking
	Environment=DISPLAY=:0
	ExecStart=${tmux_path} ${systemd_tmux_server_start_cmd}

	ExecStop=${resurrect_save_script_path}
	ExecStop=${tmux_path} kill-server
	KillMode=control-group

	RestartSec=2

	[Install]
	WantedBy=default.target
	EOF
}

systemd_tmux_is_enabled() {
	systemctl --user is-enabled "$(basename "${systemd_unit_file_path}")" >/dev/null 2>&1
}

enable_tmux_unit_on_boot() {
	if ! systemd_tmux_is_enabled; then
		systemctl --user enable "${systemd_service_name}"
	fi
}

write_unit_file() {
	template > "${systemd_unit_file_path}"
}

write_unit_file_unless_exists() {
	local systemd_unit_file_dir
	systemd_unit_file_dir="$(dirname "${systemd_unit_file_path}")"
	if ! [ -d "$systemd_unit_file_dir" ]; then
		mkdir -p "$systemd_unit_file_dir"
		write_unit_file
	elif ! [ -e "${systemd_unit_file_path}" ]; then
		write_unit_file
	fi
}

main() {
	write_unit_file_unless_exists
	enable_tmux_unit_on_boot
}
main
