function z --wraps=__zoxide_z
    __zoxide_z $argv

    if test $status -eq 0
        check_directory_for_new_repository
    end
end
