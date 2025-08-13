function disks
    echo "╓───── m o u n t . p o i n t s"
    echo "╙────────────────────────────────────── ─ ─ "

    lsblk -a

    echo ""
    echo "╓───── d i s k . u s a g e"
    echo "╙────────────────────────────────────── ─ ─ "

    df -h
end
