#!/bin/bash
. "$(dirname "$0")/evilban.conf"

TMP="$LOGDIR/_checked.tmp"

if command -v aggregate &>/dev/null; then
    aggregate < "$CHECKED" > "$TMP"
    mv "$TMP" "$CHECKED"
    echo "[evilban_cidr_aggregate] Aggregation done through aggregate."
elif command -v iprange &>/dev/null; then
    iprange --aggregate < "$CHECKED" > "$TMP"
    mv "$TMP" "$CHECKED"
    echo "[evilban_cidr_aggregate] Aggregation done through iprange."
else
    echo "[evilban_cidr_aggregate] Nor aggregate, nor iprange is found! Please instal one of them."
    exit 1
fi
