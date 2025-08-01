if not status is-interactive
    exit
end

# Created by `pipx` on 2025-03-14 06:55:59
set PATH $PATH /home/egoreast/.local/bin

zoxide init fish | source
caniuse --completion-fish | source

# Эти пути будут добавлены в $PATH единожды
fish_add_path -m ~/bin ~/.local/bin

# Определим переменные XDG
set -q XDG_DATA_HOME || set -U XDG_DATA_HOME $HOME/.local/share
set -q XDG_STATE_HOME || set -U XDG_STATE_HOME $HOME/.local/state
set -q XDG_CONFIG_HOME || set -U XDG_CONFIG_HOME $HOME/.config
set -q XDG_CACHE_HOME || set -U XDG_CACHE_HOME $HOME/.cache

set -U fish_key_bindings fish_vi_key_bindings

# Двойное нажатие ESC не работает, если выставить меньше
set -g fish_escape_delay_ms 300

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx BROWSER xdg-open
set -x TERMINAL kitty

set -x PAGER delta --line-numbers --features=collared-trogon-egoreast --hyperlinks --hyperlinks-file-link-format="lazygit-edit://{path}:{line}"
set -x GOOGLE_CLOUD_PROJECT for-gemini-464307

# pj plugin settings. Usage - pj <project name>
set -U PROJECT_PATHS ~/Programming/exarh-web ~/Yandex.Disk/ ~/Yandex.Disk/Obsidian/
# done plugin settings
set -U __done_min_cmd_duration 20000 # default: 5000 ms
set -U __done_exclude '^(v|nvim|y|yazi|m|cmus|g|lazygit)' # default: all git commands, except push and pull. accepts a regex.
set -U __done_notify_sound 1
# pisces plugin settings - autoclose pair sybols
set -U pisces_only_insert_at_eol 1

alias ai='gemini'
alias browser='yandex-browser-stable'
alias calendar='calcurse'
alias check_saved_git_passwords='seahorse'
alias check_saved_git_passwords_in_terminal='secret-tool'
alias connect_on_ssh="kitten ssh"
alias disk_usage='gdu'
alias download_from_youtube='yt-dlp' # download with 128x720 resolution and to Downloads folder
alias download_from_youtube_best='yt-dlp -f "bestvideo+bestaudio"'
alias download_playlist_from_youtube='yt-dlp --output "~/Youtube/%(playlist_title)s/%(title)s.%(ext)s"'
alias download_playlist_from_youtube_best='yt-dlp --output "~/Youtube/%(playlist_title)s/%(title)s.%(ext)s" -f "bestvideo+bestaudio"'
alias enable_keyboard1="sudo chmod 777 /dev/hidraw1"
alias enable_keyboard2="sudo chmod 777 /dev/hidraw2"
alias g="lazygit"
alias generate_license='license' # Usage - license <license_name>. Example - license mit >> LICENSE
alias live-server-run='live-server --port=3000 --host=localhost'
alias ls='lsd'
alias m="cmus"
alias project_jump='pj'
alias rebuild_greenclip='yay -S greenclip --rebuild'
alias repo_info='onefetch'
alias resources_usage='btm'
alias resources_usage_htop='htop'
alias run_bash_command='bax'
alias set_keyboard_layout='setxkbmap -layout us,ru -option grp:rwin_toggle'
alias system_info='fastfetch'
alias update_fisher='fisher update'
alias update_global_npm_packages='sudo npm update -g'
alias update_npm_packages_in_project_interactive='ncu -i --format group'
alias update_packages='sudo pacman -Syu'
alias update_packages_yay='yay'
alias update_yazi_packages='ya pkg upgrade ndtoan96/ouch dedukun/relative-motions lpanebr/yazi-plugins:first-non-directory h-hg/yamb yazi-rs/plugins:chmod Lil-Dank/lazygit boydaihungst/restore yazi-rs/plugins:git yazi-rs/plugins:full-border yazi-rs/plugins:piper BennyOe/tokyo-night DreamMaoMao/fg'
alias v="nvim"
alias y="yazi"
alias yandex-disk='yandex-disk'
