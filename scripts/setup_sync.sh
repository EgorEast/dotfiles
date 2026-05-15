#!/bin/bash

# Завершаем скрипт при любой ошибке
set -e

# Определяем домашнюю директорию
ACTUAL_HOME="$HOME"

echo "========================================"
echo " Настройка зеркалирования папок"
echo "========================================"

# 1. Запрос путей у пользователя
echo ""
read -p "Введите путь к ИСХОДНОЙ папке (Source, например ~/Logseq): " RAW_SOURCE
read -p "Введите путь к ЦЕЛЕВОЙ папке (Target, например /run/media/$USER/MyDAS/Backup/Logseq): " RAW_TARGET

# 2. Обработка путей (замена ~ на домашнюю директорию и добавление слэша в конец)
SOURCE="${RAW_SOURCE/#\~/$ACTUAL_HOME}"
TARGET="${RAW_TARGET/#\~/$ACTUAL_HOME}"

# Убираем слэш в конце, если он есть, а затем обязательно добавляем его.
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
    echo "✅ Папка $TARGET создана."
  else
    echo "❌ Отмена. Целевая папка не создана."
    exit 1
  fi
fi

# 5. Генерация уникальных имен на основе имени исходной папки
# Берем последнее имя папки из пути, переводим в нижний регистр, убираем спецсимволы
DIR_NAME=$(basename "${SOURCE%/}")
SYNC_NAME="sync-$(echo "$DIR_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')"

# На случай, если имя получится пустым
if [ -z "$SYNC_NAME" ] || [ "$SYNC_NAME" == "sync-" ]; then
  SYNC_NAME="sync-custom"
fi

SCRIPT_PATH="${ACTUAL_HOME}/.local/bin/${SYNC_NAME}.sh"
SERVICE_PATH="/etc/systemd/system/${SYNC_NAME}.service"

echo "Имя сервиса будет: $SYNC_NAME"
echo ""

# 6. Установка зависимостей (запросит пароль sudo)
echo "[1/6] Проверка и установка пакетов rsync и inotify-tools..."
sudo pacman -S --needed --noconfirm rsync inotify-tools

# 7. Создание директории для скриптов
echo "[2/6] Создание директории для скриптов..."
mkdir -p "${ACTUAL_HOME}/.local/bin"

# 8. Создание скрипта синхронизации
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

# Выдаем права на выполнение
chmod +x "$SCRIPT_PATH"

# 9. Создание systemd сервиса (запросит пароль sudo для записи в /etc)
echo "[4/6] Создание сервиса $SERVICE_PATH..."
cat <<EOF | sudo tee "$SERVICE_PATH" >/dev/null
[Unit]
Description=Real-time mirror sync using inotify ($SOURCE -> $TARGET)
After=network.target

[Service]
Type=simple
User=$USER
ExecStart=$SCRIPT_PATH
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 10. Перезагрузка systemd (запросит пароль sudo)
echo "[5/6] Перезагрузка systemd..."
sudo systemctl daemon-reload

# Сбрасываем возможные предыдущие ошибки
sudo systemctl reset-failed "${SYNC_NAME}.service" 2>/dev/null || true

# 11. Запуск и добавление в автозагрузку (запросит пароль sudo)
echo "[6/6] Запуск сервиса..."
sudo systemctl enable --now "${SYNC_NAME}.service"

echo ""
echo "========================================"
echo " ✅ Готово! Синхронизация настроена!"
echo " Имя сервиса: $SYNC_NAME"
echo "========================================"
sudo systemctl status "${SYNC_NAME}.service" --no-pager
