function npmct -d "Run TypeScript build with visible output, collect error files and open them in editor (npm check:types-open)"
    set editor (printf 'nvim\nnvim --remote-silent\ncode -r' | fzf --prompt='Select editor: ')

    # ищем локальный tsc
    if test -x ./node_modules/.bin/tsc
        set tsc_cmd ./node_modules/.bin/tsc
    else
        set tsc_cmd (command -v tsc)
        if test -z "$tsc_cmd"
            set tsc_cmd "npx --no-install tsc"
        end
    end

    # временный файл для ошибок
    set tmpfile (mktemp)

    # прогоняем tsc: и stdout, и stderr → tee → tmpfile
    $tsc_cmd -b tsconfig.json 2>&1 | tee $tmpfile

    # вытаскиваем файлы с ошибками
    set files (grep -oE '[^ (]+.tsx?' $tmpfile | sort -u)

    rm -f $tmpfile

    if test (count $files) -gt 0
        $editor $files
    else
        echo 'No files with errors found'
    end
end
