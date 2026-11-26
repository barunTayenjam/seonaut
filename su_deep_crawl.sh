#!/bin/bash
# Recursive polite crawl of /su/ - discover every live /su/ page
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
OUT=su_deep_scan.tsv
SEEN=su_deep_seen.txt
: > "$OUT"; : > "$SEEN"

seeds_urls=(
"https://www.searchunify.com/su/ai-agents-for-customer-support-a-deep-dive/"
"https://www.searchunify.com/su/community-helper/"
"https://www.searchunify.com/su/platform/artificial-intelligence-for-cognitive-search/"
"https://www.searchunify.com/su/products/knowbler/customers/"
"https://www.searchunify.com/su/sitemap/"
"https://www.searchunify.com/su/solutions/searchunify-for-high-tech/"
"https://www.searchunify.com/su/solutions/searchunify-for-support/"
"https://www.searchunify.com/su/solutions/searchunify-for-zendesk/support/"
"https://www.searchunify.com/su/llm-use-cases-for-customer-support-and-self-service/"
"https://www.searchunify.com/su/video/searchunify-for-adobe-experience-manager/"
"https://www.searchunify.com/su/products/knowbler/faq/"
"https://www.searchunify.com/su/how-abbyy-accelerates-customer-support-self-service-experiences-with-searchunify/"
"https://www.searchunify.com/su/how-flexera-improved-self-service-enhanced-agent-productivity-with-searchunify/"
"https://www.searchunify.com/su/knowbler-privacy-policy/"
"https://www.searchunify.com/su/outreach-unsubscribe/"
"https://www.searchunify.com/su/products/agent-helper/analytics/"
)

discover() {
  # print all /su/ hrefs found on the given pages
  while IFS= read -r url; do
    curl -s --max-time 30 -A "$UA" -H 'Accept: text/html' "$url" 2>/dev/null \
      | grep -oE 'href="[^"]*"' | sed 's/href="//; s/"$//' \
      | grep -E '^https://www\.searchunify\.com/su/' | sed 's/#.*$//' | sort -u
    sleep 2
  done
}

checkone() {
  local url="$1"
  grep -qxF "$url" "$SEEN" && return
  echo "$url" >> "$SEEN"
  res=$(curl -s -o /dev/null -w '%{http_code}|%{content_type}|%{redirect_url}' --max-time 30 -A "$UA" -H 'Accept: text/html' "$url" 2>/dev/null)
  local code=$(echo "$res" | cut -d'|' -f1)
  local ct=$(echo "$res" | cut -d'|' -f2)
  local loc=$(echo "$res" | cut -d'|' -f3)
  echo -e "$code\t$ct\t$url\t$loc" >> "$OUT"
}

# seed checks
for u in "${seeds_urls[@]}"; do checkone "$u"; sleep 1; done

# BFS discovery rounds
for round in 1 2 3; do
  echo "=== round $round ===" >&2
  discover < "$SEEN" | sort -u > /tmp/new_links.$$
  while IFS= read -r url; do
    checkone "$url"
    if [ $((RANDOM % 12)) -eq 0 ]; then sleep 4; else sleep 1.5; fi
  done < /tmp/new_links.$$
  rm -f /tmp/new_links.$$
done

# summary
echo "=== LIVE HTML pages (200+text/html) ==="
awk -F'\t' '$1==200 && $2 ~ /html/ {print $3}' "$OUT" | sort -u
echo "=== counts ==="
awk -F'\t' '{print $1}' "$OUT" | sort | uniq -c | sort -rn
echo DONE
