#!/bin/bash
. "$(dirname "$0")/evilban.conf"

IPSET_NAME="evilban_checked"

# 1. Refreshing ipset:
ipset create $IPSET_NAME hash:net -exist
ipset flush $IPSET_NAME
while read CIDR; do
    [[ -z "$CIDR" ]] && continue
    [[ ! "$CIDR" =~ / ]] && continue
    ipset add $IPSET_NAME "$CIDR" 2>/dev/null
done < "$CHECKED"

# 2. Computing IP:
IP_LIST=$(/usr/local/sbin/ddos -v 4 | awk '{print $2}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort | uniq)

for IP in $IP_LIST; do
    if ipset test $IPSET_NAME $IP 2>/dev/null; then
        echo "$IP уже обработан (есть в одной из подсетей кеша через ipset)"
        continue
    fi
    # Not found. Call the banhammer
    $PROGDIR/evilban_provider_by_range.sh $IP
done
