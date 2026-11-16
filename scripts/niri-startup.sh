#!/usr/bin/env bash
# Launch desktop apps at niri startup and lay them out:
#   term:  Alacritty (maximized)
#   web:   Zen (maximized)
#   chat:  Discord | Spotify   (halves)
#   games: Steam   | Heroic    (halves)
# Window rules in niri/overrides.kdl handle placement/size on open; this script
# launches in order and then enforces column order (apps map asynchronously).

TIMEOUT=120

run() { setsid -f "$@" >/dev/null 2>&1; }

run alacritty
run flatpak run app.zen_browser.zen
run flatpak run com.discordapp.Discord
run flatpak run com.spotify.Client
run steam
run heroic

# find_window <app-id regex> <title regex> -> prints window id
find_window() {
    niri msg --json windows | jq -r --arg a "$1" --arg t "$2" \
        'first(.[] | select((.app_id // "") | test($a)) | select((.title // "") | test($t)) | .id) // empty'
}

# place <workspace> <column index> <width|-> <app-id regex> <title regex>
place() {
    local ws=$1 idx=$2 width=$3 id deadline=$((SECONDS + TIMEOUT))
    until id=$(find_window "$4" "$5") && [[ -n $id ]]; do
        (( SECONDS > deadline )) && { echo "niri-startup: no window for $4" >&2; return 1; }
        sleep 0.5
    done
    niri msg action move-window-to-workspace --window-id "$id" --focus false "$ws"
    niri msg action focus-window --id "$id"
    niri msg action move-column-to-index "$idx"
    [[ $width != - ]] && niri msg action set-column-width "$width"
}

place term  1 -   '^Alacritty$'               '.'
place web   1 -   '^app\.zen_browser\.zen$'   '.'
place chat  1 50% '^discord$'                 'Discord$'   # skip the updater splash
place chat  2 50% '^spotify$'                 '.'
place games 1 50% '^steam$'                   '^Steam$'    # skip login/update windows
place games 2 50% '(?i)^heroic$'              '.'

niri msg action focus-workspace term
