function ansible-vault-encrypt
    set -l vault_pass_file ~/.matrix-vault-pass

    # Проверяем наличие файла с мастер-паролем
    if not test -f $vault_pass_file
        echo "Файл $vault_pass_file не найден."
        read -l -P "Создать его сейчас? [y/N]: " answer
        if not string match -qi y -- $answer
            echo "Отменено."
            return 1
        end
        read -s -l -P "Введите мастер-пароль Vault: " vault_pass
        echo
        if test -z "$vault_pass"
            echo "Пароль не может быть пустым."
            return 1
        end
        echo $vault_pass >$vault_pass_file
        chmod 600 $vault_pass_file
        set -e vault_pass
        echo "Файл $vault_pass_file создан с правами 600."
    end

    # Проверка аргумента
    if test (count $argv) -ne 1
        echo "Использование: ansible-vault-encrypt <имя_переменной>"
        echo "Пример: ansible-vault-encrypt ntfy_egoreast_password"
        return 1
    end

    # Запрашиваем пароль для шифрования
    read -s -l -P "Пароль для шифрования: " secret
    echo
    if test -z "$secret"
        echo "Пароль не может быть пустым."
        return 1
    end

    ansible-vault encrypt_string --vault-password-file $vault_pass_file "$secret" --name "$argv[1]"
end
