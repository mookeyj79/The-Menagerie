#!/usr/bin/env bash

FLAG="$HOME/.config/bat/.bat_cache_initialized"
if command -v batcat >/dev/null 2>&1 && [[ ! -f "$FLAG" ]]; then
    mkdir -p "$(dirname "$FLAG")"
    /usr/bin/batcat cache --build >/dev/null 2>&1 || true
    touch "$FLAG"
fi
