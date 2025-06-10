#!/bin/bash
. "$(dirname "$0")/evilban.conf"
IP="$1"

get_cidr() {
    local IP="$1"
    local INFO=$(curl -s https://ipinfo.io/$IP/json)
    local CIDR=$(echo "$INFO" | grep -oE '"cidr": ?"[^"]+"' | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}')
    [ -z "$CIDR" ] && CIDR=$(echo "$INFO" | grep -oE '"netblock": ?"[^"]+"' | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}')
    [ -z "$CIDR" ] && CIDR=$(echo "$INFO" | grep -oE '"range": ?"[^"]+"' | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}')
    if [[ "$CIDR" =~ / ]]; then
        echo "$CIDR"
        return
    fi
    # --- WHOIS fallback
    local WHOIS=$(whois $IP)
    local INETNUM=$(echo "$WHOIS" | grep -Ei 'inetnum:|netrange:|netblock:' | head -n1)
    local START=$(echo "$INETNUM" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1)
    local END=$(echo "$INETNUM" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | tail -n1)
    if [[ -n "$START" && -n "$END" && "$START" != "$END" ]]; then
        if command -v ipcalc >/dev/null; then
            ipcalc -r "$START" "$END" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}'
            return
        fi
    fi
    echo "$IP/32"
}

INFO=$(curl -s https://ipinfo.io/$IP/json)
ORG=$(echo "$INFO" | grep -Po '"org":\s*"\K[^"]+')

if [ -z "$ORG" ]; then
    WHOIS=$(whois $IP)
    ORG=$(echo "$WHOIS" | grep -m1 -i '^descr:' | sed 's/^[^:]*: *//')
    if [ -z "$ORG" ]; then
        ORG=$(echo "$WHOIS" | grep -m1 -i '^organization:' | sed 's/^[^:]*: *//')
    fi
    if [ -z "$ORG" ]; then
        ORG=$(echo "$WHOIS" | grep -m1 -i '^org-name:' | sed 's/^[^:]*: *//')
    fi
    if [ -z "$ORG" ]; then
        ORG=$(echo "$WHOIS" | grep -m1 -i '^owner:' | sed 's/^[^:]*: *//')
    fi
    if [ -z "$ORG" ]; then
        ORG=$(echo "$WHOIS" | grep -m1 -i '^netname:' | sed 's/^[^:]*: *//')
    fi
fi

BAN=0
while IFS= read -r evil; do
    [[ -z "$evil" ]] && continue
    echo "$ORG" | grep -i "$evil" && BAN=1 && MATCH="$evil" && break
done < "$PROVIDERS"

CIDRS=$(get_cidr "$IP")
if [[ $BAN -eq 1 ]]; then
    for CIDR in $CIDRS; do
        if ! ipset test evilban $CIDR &>/dev/null; then
            ipset add evilban $CIDR
            iptables -I INPUT -m set --match-set evilban src -j DROP
            echo "$(date '+%Y-%m-%d %H:%M:%S') | $CIDR | $ORG | matched: $MATCH | src: $IP" >> $BLOCKED_RANGES
            echo "IP range ban: $CIDR ($ORG, matched: $MATCH, src: $IP)"
        else
            echo "$CIDR is already banned ($ORG)"
        fi
		ipset add evilban_checked "$CIDR" 2>/dev/null
        grep -qx "$CIDR" "$CHECKED" || echo "$CIDR" >> "$CHECKED"
    done
else
    for CIDR in $CIDRS; do
	    ipset add evilban_checked "$CIDR" 2>/dev/null
        grep -qx "$CIDR" "$CHECKED" || echo "$CIDR" >> "$CHECKED"
    done
    echo "$IP OK (provider: $ORG)"
fi