#!/usr/bin/env sh
# Usage: kitty-theme.sh dark|light
# Points kitty.conf's theme include (line 2) at themes/<mode>.conf and reloads kitty.
set -eu

mode="${1:?usage: kitty-theme.sh dark|light}"
case "$mode" in
    dark|light) ;;
    *) echo "unknown mode: $mode" >&2; exit 1 ;;
esac

# Resolve the symlink so sed -i edits the real file and keeps the link intact.
conf="$(readlink -f "${XDG_CONFIG_HOME:-$HOME/.config}/kitty/kitty.conf")"
sed -i "2s|^include .*|include themes/${mode}.conf|" "$conf"

# SIGUSR1 makes running kitty instances reload their configuration.
pkill -USR1 -x kitty || true

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
