#!/bin/bash
url="$1"
code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 20 -A "Mozilla/5.0 (compatible; seonaut-rescan)" -I "$url" 2>/dev/null)
[ "$code" = "000" ] || [ "$code" = "405" ] && code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 25 -A "Mozilla/5.0" --range 0-0 "$url" 2>/dev/null)
echo -e "$code\t$url"
