function npmlo -d "Run ESLint with visible output, collect error files and open them in editor (npm lint:open, only errors)"
    set editor (printf 'nvim\nnvim --remote-silent\ncode -r' | fzf --prompt='Select editor: ')

    # ищем локальный eslint
    if test -x ./node_modules/.bin/eslint
        set eslint_cmd ./node_modules/.bin/eslint
    else
        set eslint_cmd (command -v eslint)
        if test -z "$eslint_cmd"
            set eslint_cmd "npx --no-install eslint"
        end
    end

    # временный файл для ошибок
    set tmpfile (mktemp)

    # запускаем eslint (stdout + stderr → tee → tmpfile)
    $eslint_cmd . 2>&1 | tee $tmpfile

    # берём только строки с "error"
    # находим имя файла из предыдущей строки перед error-сообщениями
    set files (awk '
        /^[^ ]/ {file=$1}
        /[0-9]+:[0-9]+[[:space:]]+error/ {print file}
    ' $tmpfile | sort -u)

    rm -f $tmpfile

    if test (count $files) -gt 0
        $editor $files
    else
        echo 'No files with errors found'
    end
end
