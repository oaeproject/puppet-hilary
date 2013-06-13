#!/bin/bash

DB_DATA_DIR="<%= db_data_dir %>"
DB_BACKUP_DIR="<%= db_backup_dir %>"

TMP_OUTPUT="/tmp/backup.out"

function say {
    echo "$1" | tee -a $TMP_OUTPUT
}

function exit_if_error {
    if [ "$?" -ne "0" ]; then
        echo $1 | tee -a $TMP_OUTPUT
        exit $?
    fi
}

rm -rf $TMP_OUTPUT



say "Starting Cassandra backup for directory..."
say

say "1. What is in the backup dir now"
say "ls -l $DB_BACKUP_DIR"
say

ls -l $DB_BACKUP_DIR | tee -a $TMP_OUTPUT
say

exit_if_error "Error listing backup dir files"



say "2. Tar, compress, md5 and stream to NFS the source data all in one pass"
say "tar -c $DB_DATA_DIR | gzip | tee $DB_BACKUP_DIR/_latest.tar.gz | md5sum -b - > $DB_BACKUP_DIR/_latest.tar.gz.md5"
say

tar -c $DB_DATA_DIR | gzip | tee $DB_BACKUP_DIR/_latest.tar.gz | md5sum -b - > $DB_BACKUP_DIR/_latest.tar.gz.md5
say

exit_if_error "Error transferring source data to NFS"



say "3. Verify the md5 sum of the file after NFS transfer"
say "md5sum -c $DB_BACKUP_DIR/_latest.tar.gz.md5 < $DB_BACKUP_DIR/_latest.tar.gz"
say

md5sum -c $DB_BACKUP_DIR/_latest.tar.gz.md5 < $DB_BACKUP_DIR/_latest.tar.gz | tee -a $TMP_OUTPUT
say

exit_if_error "MD5 sum verification failed"



say "4. Overwrite the old backup with the new one (point-in-time backups can be done with the hardlinks within these backups)"
say

mv $DB_BACKUP_DIR/_latest.tar.gz.md5 $DB_BACKUP_DIR/latest.tar.gz.md5
exit_if_error "Error replacing the latest md5"

mv $DB_BACKUP_DIR/_latest.tar.gz $DB_BACKUP_DIR/latest.tar.gz
exit_if_error "Error replacing the latest backup data"



say "5. What is in the backup dir now"
say "ls -l $DB_BACKUP_DIR"
say

ls -l $DB_BACKUP_DIR | tee -a $TMP_OUTPUT
exit_if_error "Error listing backup dir files"
say



mv $TMP_OUTPUT $DB_BACKUP_DIR/backup.log
exit_if_error "Error replacing the latest backup.log"

exit 0