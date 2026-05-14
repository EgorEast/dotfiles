#!/bin/bash

# Завершаем скрипт при любой ошибке
set -e

# Определяем реального пользователя (даже если скрипт запущен через sudo)
ACTUAL_USER=${SUDO_USER:-$USER}
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

echo "========================================"
echo " Настройка зеркалирования папок"
echo " Пользователь: $ACTUAL_USER"
echo "========================================"

# 1. Запрос путей у пользователя
echo ""
read -p "Введите путь к ИСХОДНОЙ папке (Source, например ~/Logseq): " RAW_SOURCE
read -p "Введите путь к ЦЕЛЕВОЙ папке (Target, например /run/media/$ACTUAL_USER/MyDAS/Backup/Logseq): " RAW_TARGET

# 2. Обработка путей (замена ~ на домашнюю директорию и добавление слэша в конец)
SOURCE="${RAW_SOURCE/#\~/$ACTUAL_HOME}"
TARGET="${RAW_TARGET/#\~/$ACTUAL_HOME}"

# Убираем слэш в конце, если он есть, а затем обязательно добавляем его.
# Это критически важно для правильной работы rsync!
SOURCE="${SOURCE%/}/"
TARGET="${TARGET%/}/"

echo ""
echo "Будут использованы следующие пути:"
echo "Источник: $SOURCE"
echo "Цель:     $TARGET"
echo ""

# 3. Проверка существования исходной папки
if [ ! -d "$SOURCE" ]; then
  echo "❌ Ошибка: Исходная папка не существует: $SOURCE"
  exit 1
fi

# 4. Проверка существования целевой папки
if [ ! -d "$TARGET" ]; then
  read -p "⚠️ Целевая папка не существует. Создать её? (y/n): " CREATE_DIR
  if [[ "$CREATE_DIR" =~ ^[YyДд]$ ]]; then
    mkdir -p "$TARGET"
    chown "$ACTUAL_USER:$ACTUAL_USER" "$TARGET"
    echo "✅ Папка $TARGET создана."
  else
    echo "❌ Отмена. Целевая папка не создана."
    exit 1
  fi
fi

SCRIPT_PATH="${ACTUAL_HOME}/.local/bin/mirror-sync.sh"
SERVICE_PATH="/etc/systemd/system/mirror-sync.service"

# 5. Установка зависимостей
echo ""
echo "[1/6] Установка пакетов rsync и inotify-tools..."
pacman -S --needed --noconfirm rsync inotify-tools

# 6. Создание директории для скрипта
echo "[2/6] Создание директории для скрипта..."
mkdir -p "${ACTUAL_HOME}/.local/bin"

# 7. Создание скрипта синхронизации
echo "[3/6] Создание скрипта $SCRIPT_PATH..."
cat <<EOF >"$SCRIPT_PATH"
#!/bin/bash

SOURCE="$SOURCE"
TARGET="$TARGET"

# Первичная синхронизация при запуске
rsync -a --delete "\$SOURCE" "\$TARGET"

# Бесконечный цикл
while true; do
    # Ждем изменений
    inotifywait -r -e modify,create,delete,move "\$SOURCE"
    
    # Пауза 5 секунд (чтобы программы дописали все временные файлы)
    sleep 5
    
    # Синхронизация
    rsync -a --delete "\$SOURCE" "\$TARGET"
done
EOF

# Выдаем права на выполнение и меняем владельца на вашего пользователя
chmod +x "$SCRIPT_PATH"
chown "$ACTUAL_USER:$ACTUAL_USER" "$SCRIPT_PATH"

# 8. Создание systemd сервиса
echo "[4/6] Создание сервиса $SERVICE_PATH..."
cat <<EOF >"$SERVICE_PATH"
[Unit]
Description=Real-time mirror sync using inotify ($SOURCE -> $TARGET)
After=network.target

[Service]
Type=simple
User=$ACTUAL_USER
ExecStart=$SCRIPT_PATH
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 9. Перезагрузка systemd
echo "[5/6] Перезагрузка systemd..."
systemctl daemon-reload

# Сбрасываем возможные предыдущие ошибки
systemctl reset-failed mirror-sync.service 2>/dev/null || true

# 10. Запуск и добавление в автозагрузку
echo "[6/6] Запуск сервиса..."
systemctl enable --now mirror-sync.service

echo ""
echo "========================================"
echo " ✅ Готово! Синхронизация настроена и запущена!"
echo " Статус сервиса:"
echo "========================================"
systemctl status mirror-sync.service --no-pager
