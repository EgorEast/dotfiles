function claude
    # 1. Проверка активного VPN-интерфейса
    set -l VPN_INTERFACES tun0 singbox_tun amn0
    set -l vpn_on false

    for iface in $VPN_INTERFACES
        if ip link show $iface up &>/dev/null
            set vpn_on true
            break
        end
    end

    if test "$vpn_on" = false
        echo "❌ Ошибка: VPN не подключен (ожидаются интерфейсы: $VPN_INTERFACES)"
        echo "Запуск claude отменен в целях безопасности."
        return 1
    end

    # 2. Проверка страны через GeoIP
    set -l COUNTRY (curl -s --max-time 5 https://ipinfo.io/country | string trim)

    if test -z "$COUNTRY"
        echo "❌ Ошибка: Не удалось определить IP/страну. Проверьте интернет."
        return 1
    end

    # 3. Список заблокированных стран (можно дополнять)
    set -l BLOCKED_COUNTRIES RU BY CN IR KP UA TR

    for cc in $BLOCKED_COUNTRIES
        if test "$COUNTRY" = "$cc"
            echo "❌ Ошибка: Ваша текущая локация - $COUNTRY. Запуск из этой страны заблокирован."
            return 1
        end
    end

    # 4. Запуск оригинального /usr/bin/claude
    command claude $argv
end
