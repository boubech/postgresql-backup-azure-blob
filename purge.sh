#!/bin/bash

echo "Purge obsoleted backup created before $MAX_BACKUP_RETENTION_IN_SECONDS seconds..."

export DELETE_BEFORE=$(date $FILENAME_DATE_FORMAT_SUFFIX -d@"$(( `date +%s`-$MAX_BACKUP_RETENTION_IN_SECONDS))")
echo "Delete backup before $DELETE_BEFORE "

azcopy list $AZ_BLOB_SAS_URL | sed "s#INFO: $FILENAME_PREFIX-\(.*\).sql.tar.gz;.*#$FILENAME_PREFIX-;\1;.sql.tar.gz#" | grep "^$FILENAME_PREFIX" > existingBackups
cat existingBackups | tr ";" "\t"  | awk "{if (\$2 < $DELETE_BEFORE){print \$0;}}" | tr -d '\t' > backupsToDelete

echo "Backups to delete :"
cat backupsToDelete
azcopy rm $AZ_BLOB_SAS_URL --recursive=true --list-of-files=backupsToDelete

exit $?