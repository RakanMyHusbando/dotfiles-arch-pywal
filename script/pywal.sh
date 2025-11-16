#!/usr/bin/env bash

declare -A relink=(
    [custom-vencord-colors.css]="$HOME/.config/vesktop/themes/pywal.css"
    [custom-spicetify-colors.ini]="$HOME/.config/spicetify/Themes/spicewal/color.ini"
    [custom-nchat-usercolor-colors.conf]="$HOME/.config/nchat/usercolor.conf"
    [custom-nchat-color-colors.conf]="$HOME/.config/nchat/color.conf"
)

echo_and_notify() {
    if [[ -z "$1" ]]; then
        echo "No message provided to echo_and_notify."
        return 1
    fi
    echo "$1"
    notify-send "$@"
}

reload_mako_notification () {
    local config_file="$HOME/.config/mako/config"
    
    echo_and_notify "Reloading Mako configuration."

    if ! command -v makoctl &>/dev/null; then
        echo_and_notify "Failed: Mako is not installed."
        return 1 
    fi

    if [[ ! -f "$config_file" ]]; then
        echo_and_notify "Failed: Mako configuration file not found at $config_file."
        return 1 
    fi

    # Set default colors
    sed -i "0,/^background-color[[:space:]]*=.*/s//background-color=${background}89/" "$config_file"
    sed -i "0,/^text-color[[:space:]]*=.*/s//text-color=${foreground}/" "$config_file"
    sed -i "0,/^border-color[[:space:]]*=.*/s//border-color=${color6}/" "$config_file"

    makoctl reload
}

reload_waybar() {
    echo_and_notify "Reloading Waybar configuration."
    if ! command -v waybar &>/dev/null; then
        echo_and_notify "Failed: Waybar is not installed."
        return 1 
    fi

    pkill waybar
    hyprctl dispatch exec waybar &>/dev/null
}

set_wallpaper() {
    if command -v swww &>/dev/null; then
        swww img $(cat "$HOME/.cache/wal/wal") --transition-type fade --transition-duration 0.5
    elif command -v swaybg &>/dev/null; then
        swaybg -m fill -i "$HOME/.cache/wal/wal" &
    elif command -v feh &>/dev/null; then
        feh --bg-fill "$HOME/.cache/wal/wal"
    elif command -v nitrogen &>/dev/null; then
        nitrogen --set-zoom-fill "$HOME/.cache/wal/wal"
    else
        echo_and_notify "No supported wallpaper setter found (swww, swaybg, feh, nitrogen)." --urgency low
    fi
}

# Get color environment variables from pywal
source ~/.cache/wal/colors.sh

# Loop through the relink array and create symlinks for pywal-generated color files
echo_and_notify "Relinking pywal color files."
for var in "${!relink[@]}"; do 
    if [[ ! -d "${relink[$var]%/*}" ]]; then
        echo "Creating directory: ${relink[$var]%/*}"
        mkdir -p "${relink[$var]%/*}"
    fi
    [[ -f "${relink[$var]}" ]] &&  rm ${relink[$var]}
    ln -sf "$HOME/.cache/wal/$var" ${relink[$var]}
done

kvantummanager  --set pywal-orchis-dark

reload_mako_notification
reload_waybar
set_wallpaper
