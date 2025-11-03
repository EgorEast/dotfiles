if not status is-interactive
    exit
end

# Created by `pipx` on 2025-03-14 06:55:59
set PATH $PATH /home/egoreast/.local/bin
set -gx fish_user_paths $HOME/.cargo/bin $fish_user_paths

zoxide init fish | source
caniuse --completion-fish | source
cruise completion fish | source

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
set -gx MANPAGER "sh -c 'awk '\''{ gsub(/\x1B\[[0-9;]*m/, \"\", \$0); gsub(/.\x08/, \"\", \$0); print }'\'' | bat -p -lman'"

abbr -a --position anywhere -- --help '--help | bat -plhelp'
abbr -a --position anywhere -- -h '-h | bat -plhelp'

set -x PAGER delta --line-numbers --features=collared-trogon-egoreast --hyperlinks --hyperlinks-file-link-format="lazygit-edit://{path}:{line}"
set -x GOOGLE_CLOUD_PROJECT for-gemini-464307

set -gx ATAC_KEY_BINDINGS ~/.config/atac/vim_key_bindings.toml

# pj plugin settings. Usage - pj <project name>
set -U PROJECT_PATHS ~/Programming/exarh-web ~/Yandex.Disk/ ~/Yandex.Disk/Obsidian/
# done plugin settings
set -U __done_min_cmd_duration 20000 # default: 5000 ms
set -U __done_exclude '^(v|e|se|nvim|y|yazi|m|cmus|g|lazygit|ai|gemini|cal)' # default: all git commands, except push and pull. accepts a regex.
set -U __done_notify_sound 1
# pisces plugin settings - autoclose pair sybols
set -U pisces_only_insert_at_eol 1

alias 'cd..'='cd ../'
alias 'z..'='z ../'
alias ZZ='exit'
alias b='blobdrop' # Usage - blobdrop <file_name> - copy file to blobdrop
alias browser='yandex-browser-stable'
alias bt='bluetuith --confirm-on-quit'
alias c='clear'
alias cal='calcurse'
alias calc='LC_ALL=en_US.UTF-8 qalc'
alias cat='bat'
alias check_saved_git_passwords='seahorse'
alias check_saved_git_passwords_in_terminal='secret-tool'
alias connect_on_ssh='kitten ssh'
alias cp='cp -r'
alias curld='curl -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36"'
alias curlh='curl -sILX GET'
alias curlm='curl -A "Mozilla/5.0 (iPhone; CPU iPhone OS 6_1_3 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) CriOS/28.0.1500.12 Mobile/10B329 Safari/8536.25"'
alias download_from_youtube='yt-dlp' # download with 128x720 resolution and to Downloads folder
alias download_from_youtube_best='yt-dlp -f "bestvideo+bestaudio"'
alias download_playlist_from_youtube='yt-dlp --output "~/Youtube/%(playlist_title)s/%(title)s.%(ext)s"'
alias download_playlist_from_youtube_best='yt-dlp --output "~/Youtube/%(playlist_title)s/%(title)s.%(ext)s" -f "bestvideo+bestaudio"'
alias e='$EDITOR'
alias enable_keyboard1='sudo chmod 777 /dev/hidraw1'
alias enable_keyboard2='sudo chmod 777 /dev/hidraw2'
alias format_to_fat32='sudo mkfs.vfat -F32' # use: format_to_fat32 -n "NEW_NAME" /dev/sdX
alias fzf='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'
alias g='lazygit'
alias ga='git add'
alias gb='git branch'
alias gc='git clone'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gcs='git commit -S -m'
alias gd='git difftool'
alias gdc='git difftool --cached'
alias generate_license='license' # Usage - license <license_name>. Example - license mit >> LICENSE
alias get_files_type_statistics='cloc'
alias gf='git fetch'
alias gg='git graph'
alias ggg='git graphgpg'
alias gm='git merge'
alias gp='git push'
alias gpr='gh pr create'
alias gr='git rebase -i'
alias gs='git status -sb'
alias gt='git tag'
alias gu='git reset @ -- '
alias gx='git reset --hard @'
alias ils='timg --grid=2x1 --upscale=i --center --title --frames=1 -b lightgray -B darkgray --pattern-size=1 '
alias jqp='jqp --config ~/.config/jqp/config.yaml'
alias l='lsd -lhF'
alias la='lsd -ahF'
alias live-server-run='live-server --port=3000 --host=localhost'
alias lla='lsd -lahF'
alias ls='lsd'
alias lt='lsd --tree'
alias m='cmus'
alias mkdir='mkdir -p'
alias mm='mmtui'
alias npmd='npm run dev'
alias npmh='npm run host'
alias npml='npm run lint'
alias npmp='npm run preview'
alias npmt='npm run test'
alias npmtw='npm run test:watch'
alias ollama_run='ollama serve & ollama run deepseek-coder-v2'
alias open_spreadsheet_tui='sc-im'
alias ovpn_connect='~/ovpn/run-ovpn.sh'
alias print_file='lp' # lp -d ИМЯ_ПРИНТЕРА -n КОЛИЧЕСТВО_КОПИЙ image.png
alias project_jump='pj'
alias psef='ps -ef'
alias rain='terminal-rain --rain-color blue --lightning-color white'
alias read_docx_as_md='pandoc  --from docx --to markdown --standalone --no-highlight'
alias rebuild_greenclip='yay -S greenclip --rebuild'
alias repo_info='onefetch'
alias resources_usage='btop'
alias rmrf='rm -rf'
alias run_bash_command='bax'
alias scp='scp -r'
alias se='sudo $EDITOR'
alias set_keyboard_layout='setxkbmap -layout us,ru -option grp:rwin_toggle'
alias system_info='fastfetch'
alias tree='tree -CAFa -I "CVS|*.*.package|.svn|.git|.hg|node_modules|bower_components" --dirsfirst'
alias update_all='update_yazi_packages && update_fisher && update_packages && update_global_npm_packages && update_packages_yay'
alias update_fisher='fisher update'
alias update_global_npm_packages='sudo npm update -g'
alias update_mirrors_list='sudo reflector --protocol https --latest 10 --sort rate --fastest 5 --save /etc/pacman.d/mirrorlist'
alias update_npm_packages_in_project_interactive='ncu -i --format group'
alias update_packages='sudo pacman -Syu'
alias update_packages_yay='yay'
alias update_yazi_packages='ya pkg upgrade'
alias v='nvim'
alias vimdiff='nvim -d -u ~/.config/nvim/init.vim'
alias yandex-disk='yandex-disk'

# functions that must be declared after everything
for f in ~/.config/fish/my_functions/*.fish
    source $f
end
