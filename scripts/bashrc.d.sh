#!/usr/bin/env bash

log() {
  printf '%s\n' "$*"
}

# Append bashrc.d sourcing block if not already present
bashrc_marker="# slop:bashrc.d"
if [[ -f "$HOME/.bashrc" ]] && ! grep -qF "$bashrc_marker" "$HOME/.bashrc"; then
  cat >> "$HOME/.bashrc" <<EOF

$bashrc_marker
if [ -d "\$HOME/.bashrc.d" ]; then
  for config in "\$HOME/.bashrc.d"/*.sh; do
    [ -r "\$config" ] && source "\$config"
  done
fi
EOF
  log "appended bashrc.d sourcing block to ~/.bashrc"
else
  log "ok ~/.bashrc already sources bashrc.d"
fi
