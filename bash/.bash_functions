#!/usr/bin/env bash

# aliases
# function t() {
#   X=$#
#   [[ $X -eq 0 ]] || X=X
#   tmux new-session -A -s $X
#   tmux set-environment LC_ALL 'en_US.UTF-8'
#   tmux set-environment LANG 'en_US.UTF-8'
# }

npm() {
  if [[ "$1" == "i" || "$1" == "install" ]]; then
    shift
    npq install "$@"
  else
    command npm "$@"
  fi
}

y() {
  tmpfile=$(mktemp -t yazi-cwd.XXXXXX)
  yazi --cwd-file="$tmpfile" "$@"
  if [[ -f $tmpfile ]]; then
    cd "$(cat "$tmpfile")" || return
    rm "$tmpfile"
  fi
}

pj() {
  local argc=$#
  if [[ -z "${PROJECT_PATHS[*]}" ]]; then
    echo 'Add some directories to the environment variable $PROJECT_PATHS to get started!'
    echo '  export PROJECT_PATHS=(~/dir1 ~/dir2)'
    return 1
  elif [[ $argc -le 0 || $argc -gt 2 ]]; then
    echo 'Usage: pj [open] [PROJECT]'
    return 1
  elif [[ $argc -eq 2 && $1 != "open" ]]; then
    echo 'Usage: pj [open] [PROJECT]'
    return 1
  elif [[ "$1" == "--help" ]]; then
    echo 'Usage: pj [open] [PROJECT]'
  elif [[ "$1" == "open" ]]; then
    local target
    target=$(find "${PROJECT_PATHS[@]}" -maxdepth 1 -name "$2" | head -n 1)
    if [[ -n "$target" ]]; then
      cd "$target" || return
      eval "$EDITOR \"$target\""
    else
      echo "No such project: $2"
      return 1
    fi
  else
    local target
    target=$(find "${PROJECT_PATHS[@]}" -maxdepth 1 -name "$1" | head -n 1)
    if [[ -n "$target" ]]; then
      cd "$target" || return
    else
      echo "No such project: $1"
      return 1
    fi
  fi
}

__project_basenames() {
  local project_basenames=()
  for pp in "${PROJECT_PATHS[@]}"; do
    if [[ -n "$(ls -A "$pp" 2>/dev/null)" ]]; then
      project_basenames+=("$(basename "$pp")")
      while IFS= read -r project; do
        project_basenames+=("$project")
      done < <(find "$pp" -maxdepth 1 -mindepth 1 -type d -not -name '.*' -exec basename {} \;)
    fi
  done
  echo "${project_basenames[@]}"
}

license() {
  local base_url="https://api.github.com/licenses"
  local headers="Accept: application/vnd.github.drax-preview+json"

  if [[ -n "$1" ]]; then
    local license="$1"
    local res
    res=$(curl --silent --header "$headers" "$base_url/$license" | jq '.body')
    echo -e "$res" | sed -e 's/^"//' -e 's/"$//'
  else
    local res
    res=$(curl --silent --header "$headers" "$base_url")
    echo "Available Licenses: "
    echo
    echo "$res" | jq -r '.[].key'
  fi
}

disks() {
  echo "╓───── m o u n t . p o i n t s"
  echo "╙────────────────────────────────────── ─ ─ "

  lsblk -a

  echo ""
  echo "╓───── d i s k . u s a g e"
  echo "╙────────────────────────────────────── ─ ─ "

  df -h
}

# Защита от запуска Claude без VPN или из РФ
claude() {
  # 1. Проверка активного VPN-интерфейса
  local VPN_INTERFACES=("tun0" "singbox_tun")
  local vpn_on=false

  for iface in "${VPN_INTERFACES[@]}"; do
    if ip link show "$iface" up &>/dev/null; then
      vpn_on=true
      break
    fi
  done

  if [ "$vpn_on" = false ]; then
    echo "❌ Ошибка: VPN не подключен (ожидаются интерфейсы: ${VPN_INTERFACES[*]})"
    echo "Запуск claude отменен в целях безопасности."
    return 1
  fi

  # 2. Проверка страны через GeoIP
  local COUNTRY
  COUNTRY=$(curl -s --max-time 5 https://ipinfo.io/country)

  if [ -z "$COUNTRY" ]; then
    echo "❌ Ошибка: Не удалось определить IP/страну. Проверьте интернет."
    return 1
  fi

  # Очищаем от лишних символов
  COUNTRY=$(echo "$COUNTRY" | tr -d '[:space:]')

  # 3. Список заблокированных стран
  local BLOCKED_COUNTRIES=("RU" "BY" "CN" "IR" "KP")

  for cc in "${BLOCKED_COUNTRIES[@]}"; do
    if [ "$COUNTRY" == "$cc" ]; then
      echo "❌ Ошибка: Ваша текущая локация - $COUNTRY. Запуск из этой страны заблокирован."
      return 1
    fi
  done

  # 4. Запуск оригинального /usr/bin/claude
  command claude "$@"
}
