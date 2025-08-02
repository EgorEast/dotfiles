function y --wraps=yazi
    set tmpfile (mktemp -t yazi-cwd.XXXXXX)
    yazi --cwd-file=$tmpfile $argv
    if test -f $tmpfile
        cd (cat $tmpfile)
        rm $tmpfile
    end
end
