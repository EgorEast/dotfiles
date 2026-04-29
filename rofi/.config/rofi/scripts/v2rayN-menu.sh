#!/bin/bash
# Скрипт для rofi меню v2rayN

ACTION=$(echo -e "✓ Запустить/Активировать\n○ Статус\n✕ Закрыть" | rofi -dmenu -p "v2rayN:" -no-custom)

case "$ACTION" in
*"Запустить"*)
  ~/.local/bin/v2rayN-i3
  ;;
*"Статус"*)
  if pgrep -x v2rayN >/dev/null; then
    notify-send "v2rayN" "🟢 Запущен (PID: $(pgrep -x v2rayN))"
  else
    notify-send "v2rayN" "⛔ Не запущен"
  fi
  ;;
*"Закрыть"*)
  pkill -x v2rayN && notify-send "v2rayN" "Закрыт"
  ;;
esac
