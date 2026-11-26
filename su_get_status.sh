#!/bin/bash
url="$1"
out=$(curl -s -o /dev/null -w "%{http_code}|%{redirect_url}" --max-time 25 -A "Mozilla/5.0 (compatible; seonaut-suscan)" "$url" 2>/dev/null)
code="${out%|*}"; loc="${out#*|}"
echo -e "$code\t$loc\t$url"
