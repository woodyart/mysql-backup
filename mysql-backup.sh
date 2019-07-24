#!/bin/bash

MYSQL_DEFAULTS=$1
SAVEDIR=$2
DAYSOLD=$3

TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
EXCLUDES="mysql\|information_schema\|performance_schema"
DATABASES=$(mysql --defaults-file=$MYSQL_DEFAULTS \
                  --batch \
                  --skip-column-names \
                  -e "SHOW DATABASES;" | grep -E -v "$EXCLUDES")

# Backup database
for db in $DATABASES; do
  mysqldump --defaults-file=$MYSQL_DEFAULTS \
            --add-drop-table \
            --compress \
            --dump-date \
            $db | \
            gzip -c > $SAVEDIR/$db-$TIMESTAMP.tar.gz
  [ $? != 0 ] && logger -s "$0 - $db backup failed"
done

# Remove old backups
find $SAVEDIR -type f -name '*.tar.gz' -mtime +$DAYSOLD -delete
[ $? != 0 ] && logger -s "$0 - Failed remove old backups"
