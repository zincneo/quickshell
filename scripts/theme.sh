#!/usr/bin/env sh
# Usage: theme.sh dark|light
# Switches kitty, qutebrowser, fcitx5 and niri backdrop colours to the given mode.
set -eu

mode="${1:?usage: theme.sh dark|light}"
case "$mode" in
    dark|light) ;;
    *) echo "unknown mode: $mode" >&2; exit 1 ;;
esac

# Resolve the symlink so sed -i edits the real file and keeps the link intact.
conf="$(readlink -f "${XDG_CONFIG_HOME:-$HOME/.config}/kitty/kitty.conf")"
sed -i "2s|^include .*|include themes/${mode}.conf|" "$conf"

# SIGUSR1 makes running kitty instances reload their configuration.
pkill -USR1 -x kitty || true

# Point qutebrowser's THEME line at the matching palette (themes/<mode>.py).
qb_conf="$(readlink -f "${XDG_CONFIG_HOME:-$HOME/.config}/qutebrowser/config.py")"
sed -i "s|^THEME = .*|THEME = \"${mode}\"|" "$qb_conf"

# Only reload when a qutebrowser instance is running: ':config-source' would
# otherwise start a new browser window.
if pgrep -f qutebrowser >/dev/null 2>&1; then
    qutebrowser ':config-source' >/dev/null 2>&1 || true
fi

# Niri reloads config.kdl automatically when it changes.
case "$mode" in
    dark) backdrop=#24273a ;;
    light) backdrop=#eff1f5 ;;
esac
niri_conf="$(readlink -f "${XDG_CONFIG_HOME:-$HOME/.config}/niri/config.kdl")"
sed -i "s|^\(\s*backdrop-color \)\".*\"|\1\"${backdrop}\"|" "$niri_conf"

# Match fcitx5's candidate-window theme (Theme= line) to the same mode.
fcitx_conf="${XDG_CONFIG_HOME:-$HOME/.config}/fcitx5/conf/classicui.conf"
if [ -f "$fcitx_conf" ]; then
    case "$mode" in
        dark) fcitx_theme=catppuccin-macchiato-lavender ;;
        light) fcitx_theme=catppuccin-latte-lavender ;;
    esac
    sed -i "s|^Theme=.*|Theme=${fcitx_theme}|" "$fcitx_conf"
    fcitx5 -r -d >/dev/null 2>&1 || true
fi
