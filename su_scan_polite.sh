#!/bin/bash
# Polite sequential scan: real-browser UA, Accept headers, random 1.5-3.5s delay, resumable
OUT=su_sitemap_scan.tsv
touch "$OUT"
while IFS= read -r url; do
  grep -qF	"$url" "$OUT" && continue
  res=$(curl -s -o /dev/null -w '%{http_code}|%{content_type}|%{redirect_url}' \
    --max-time 30 \
    -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36' \
    -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' \
    -H 'Accept-Language: en-US,en;q=0.9' \
    --compressed "$url" 2>/dev/null)
  echo -e "${res%%|*}\t$(echo "$res" | cut -d'|' -f2)\t$(echo "$res" | cut -d'|' -f3)\t$url" >> "$OUT"
  # 1 in 12 URLs gets a longer pause, like a human reading a page
  if [ $((RANDOM % 12)) -eq 0 ]; then sleep "$(printf '4.%02d' $((RANDOM % 90)))"; else sleep "$(printf '1.%02d' $((RANDOM % 50 + 15)))"; fi
done < su_sitemap_urls_all.txt
echo DONE
