function npm
    if test (count $argv) -ge 1
        if test "$argv[1]" = i -o "$argv[1]" = install
            command npq install $argv[2..-1]
        else
            command npm $argv
        end
    else
        command npm
    end
end
