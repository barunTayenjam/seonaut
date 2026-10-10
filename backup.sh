#!/bin/sh
# Dump the SEOnaut MySQL database into ./backups with a timestamp.
# Restore with: docker exec -i SEOnaut-db mysql -uroot -proot seonaut < <dumpfile>
set -e
DIR="$(cd "$(dirname "$0")" && pwd)/backups"
mkdir -p "$DIR"
FILE="$DIR/seonaut-$(date +%Y%m%d-%H%M).sql"
docker exec "${SEONAUT_DB:-SEOnaut-db}" sh -c 'mysqldump -uroot -proot --single-transaction --routines seonaut' > "$FILE"
echo "wrote $FILE ($(du -h "$FILE" | cut -f1))"