#!/bin/sh

set -eu

kind=${1:-}
client=${2:-}
socket_path=${3:-}
pane=${4:-}
start_dir=${5:-$HOME}
[ -n "$client" ] && [ -n "$socket_path" ] && [ -n "$pane" ] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0

case "$kind" in
    side) direction=-h size='25%' ;;
    bottom) direction=-v size=3 ;;
    *) exit 0 ;;
esac

t() {
    tmux -S "$socket_path" "$@"
}

info=$(t display-message -p -t "$pane" '#{session_id} #{window_id} #{window_panes}') || exit 0
read -r session window window_panes <<EOF
$info
EOF

float=$(t list-panes -s -t "$session" -f "#{==:#{@float_pane},$kind}" \
    -F '#{pane_id} #{window_id}' | head -n 1) || exit 0

if [ -z "$float" ]; then
    new_pane=$(t split-window "$direction" -f -l "$size" -t "$pane" -c "$start_dir" \
        -P -F '#{pane_id}') || exit 0
    t set-option -p -t "$new_pane" @float_pane "$kind"
    exit 0
fi

float_pane=${float%% *}
float_window=${float#* }

if [ "$float_window" = "$window" ]; then
    if [ "$window_panes" -gt 1 ]; then
        t break-pane -d -s "$float_pane" -n "float-$kind"
    else
        t display-message -c "$client" 'Type exit to close this pane'
    fi
    exit 0
fi

t join-pane "$direction" -f -l "$size" -s "$float_pane" -t "$pane"
