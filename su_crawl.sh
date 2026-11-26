#!/bin/bash
# Focused BFS crawl of /su/ section: discover + verify live HTML pages
SEEN="$1"; QUEUE="$2"
: > "$SEEN"; : > "$QUEUE"
SEEDS="https://www.searchunify.com/su/sitemap/ https://www.searchunify.com/su/community-helper/ https://www.searchunify.com/su/platform/artificial-intelligence-for-cognitive-search/ https://www.searchunify.com/su/products/knowbler/customers/ https://www.searchunify.com/su/solutions/searchunify-for-high-tech/ https://www.searchunify.com/su/solutions/searchunify-for-support/ https://www.searchunify.com/su/solutions/searchunify-for-zendesk/support/ https://www.searchunify.com/su/ai-agents-for-customer-support-a-deep-dive/ https://www.searchunify.com/su/llm-use-cases-for-customer-support-and-self-service/"
for s in $SEEDS; do echo "$s" >> "$QUEUE"; done
PASS=0
while :; do
  PASS=$((PASS+1))
  NEW=0
  while read -r url; do
    grep -qxF "$url" "$SEEN" && continue
    echo "$url" >> "$SEEN"
    body=$(curl -s --max-time 30 -A "Mozilla/5.0 (compatible; seonaut-suscan)" -L --max-redirs 4 "$url" 2>/dev/null)
    # extract /su/ hrefs, strip anchors/params-dupes, only same-host paths
    echo "$body" | grep -oE 'href="[^"]*"' | sed 's/href="//; s/"$//' \
      | grep -E '^https://www\.searchunify\.com/su/' \
      | sed 's/#.*$//' | sort -u > /tmp/su_found.$$
    while read -r f; do
      grep -qxF "$f" "$SEEN" || { echo "$f" >> "$QUEUE"; NEW=$((NEW+1)); }
    done < /tmp/su_found.$$
    rm -f /tmp/su_found.$$
  done < <(sort -u "$QUEUE")
  [ "$NEW" -eq 0 ] && break
  [ "$PASS" -ge 4 ] && break
done
sort -u "$SEEN"
