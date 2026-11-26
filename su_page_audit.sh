#!/bin/bash
# Fetch each live /su/ page, extract title, canonical, robots, h1, word count
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
OUT=su_page_audit.tsv
: > "$OUT"
urls=(
"https://www.searchunify.com/su/ai-agents-for-customer-support-a-deep-dive/"
"https://www.searchunify.com/su/community-helper/"
"https://www.searchunify.com/su/how-abbyy-accelerates-customer-support-self-service-experiences-with-searchunify/"
"https://www.searchunify.com/su/how-flexera-improved-self-service-enhanced-agent-productivity-with-searchunify/"
"https://www.searchunify.com/su/knowbler-privacy-policy/"
"https://www.searchunify.com/su/llm-use-cases-for-customer-support-and-self-service/"
"https://www.searchunify.com/su/outreach-unsubscribe/"
"https://www.searchunify.com/su/platform/artificial-intelligence-for-cognitive-search/"
"https://www.searchunify.com/su/products/agent-helper/analytics/"
"https://www.searchunify.com/su/products/knowbler/customers/"
"https://www.searchunify.com/su/products/knowbler/faq/"
"https://www.searchunify.com/su/sitemap/"
"https://www.searchunify.com/su/solutions/searchunify-for-high-tech/"
"https://www.searchunify.com/su/solutions/searchunify-for-support/"
"https://www.searchunify.com/su/solutions/searchunify-for-zendesk/support/"
)
for u in "${urls[@]}"; do
  html=$(curl -s --max-time 30 -A "$UA" -H 'Accept: text/html' "$u" 2>/dev/null)
  title=$(echo "$html" | grep -oE '<title>[^<]*' | head -1 | sed 's/<title>//; s/^ *//; s/ *$//')
  canon=$(echo "$html" | grep -oE '<link rel="canonical" href="[^"]*"' | head -1 | sed 's/.*href="//; s/"$//')
  robots=$(echo "$html" | grep -oE '<meta name="robots" content="[^"]*"' | head -1 | sed 's/.*content="//; s/"$//')
  h1=$(echo "$html" | grep -oE '<h1[^>]*>[^<]*' | head -1 | sed 's/<h1[^>]*>//' | tr -d '\n' | sed 's/^ *//; s/ *$//')
  words=$(echo "$html" | sed 's/<script[^>]*>.*<\/script>//g; s/<style[^>]*>.*<\/style>//g; s/<[^>]*>/ /g' 2>/dev/null | tr -s ' \n' ' \n' | wc -w)
  echo -e "$u\t$title\t$canon\t$robots\t$h1\t$words" >> "$OUT"
  sleep 3
done
column -t -s $'\t' "$OUT" | cut -c1-200
echo DONE
