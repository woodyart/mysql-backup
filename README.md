# mysql-backup

The script backups all mysql/mariadb databases in separate files.

## Usage

### Run manually

Use following options to run script

* `-d` or `--defaults` - specify file with credentials
* `-s` or `--savedir` - Path to store backups
* `-k` or `--keepdays` - Days to store backups

#### Example

```
mysql-backup.sh -d /etc/mysql/debian.cnf -s /opt/backups -k 30
```

### Automatically run

Add job to crontab to launch script periodically with command `crontab -e`

#### Example

```
*/5 * * * * /var/scripts/mysql-backup.sh -d /etc/mysql/debian.cnf -s /opt/backups -k 30
```

### Check logs

In normal case there is no specified logs when the script is finished success.

#### Example: The cron job was started
```
Jul 26 23:15:01 server1 CRON[14394]: (dbackup) CMD (/home/dbackup/scripts/mysql-backup/mysql-backup.sh -d /home/dbackup/.my.cnf -s /home/dbackup/backups/db -k 1)
```

If something going wrong the script logs may be found in syslog

#### Example: syslog errors

```
Jul 26 23:15:01 server1 dbackup: /home/dbackup/scripts/mysql-backup/mysql-backup.sh - test1 backup failed
Jul 26 23:15:01 server1 dbackup: /home/dbackup/scripts/mysql-backup/mysql-backup.sh - test2 backup failed
Jul 26 23:15:01 server1 dbackup: /home/dbackup/scripts/mysql-backup/mysql-backup.sh - test3 backup failed
Jul 26 23:15:01 server1 dbackup: /home/dbackup/scripts/mysql-backup/mysql-backup.sh - Failed remove old backups
```
