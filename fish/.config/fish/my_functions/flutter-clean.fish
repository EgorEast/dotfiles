function flutter-clean
    fusermount -uq ~/.cache/flutter_sdk 2>/dev/null
    rm -rf ~/.cache/flutter_sdk ~/.cache/flutter_local
    echo "Кэш Flutter очищен"
end
