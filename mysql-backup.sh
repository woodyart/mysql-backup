#!/bin/bash

function help() {
  echo "
Use script with next options:

OPTIONS
  -d or --defaults config_file
          Specify mysql defaults file with credentials

  -s or --savedir path
          Path to store backups

  -k or --keepdays number
          Days to store backups

EXAPMLE
  $0 -d /etc/mysql/debian.cnf -s /home/backups -k 30"
}

if [[ "$#" -eq 0 ]]; then
  echo "ERROR
  Parameters not set"; help
  exit 1
fi

while [[ "$#" -gt 0 ]]; do case $1 in
  -d|--defaults) MYSQL_DEFAULTS="$2"; shift;;
  -s|--savedir) SAVEDIR="$2"; shift;;
  -k|--keepdays) DAYSOLD="$2"; shift;;
  *) echo "ERROR
  Unknown parameter passed: $1"; help; exit 1;;
esac; shift; done

if [[ -z $MYSQL_DEFAULTS || -z $SAVEDIR || -z $DAYSOLD ]]; then
  echo "ERROR
  Parameters not set completely"; help
  exit 1
fi

TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
EXCLUDES="mysql\|information_schema\|performance_schema"
DATABASES=$(mysql --defaults-file=$MYSQL_DEFAULTS \
                  --batch \
                  --skip-column-names \
                  -e "SHOW DATABASES;" | grep -v "$EXCLUDES")

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
