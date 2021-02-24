#!/bin/bash

echo "Job started: $(date)"

DATE=$(date $FILENAME_DATE_FORMAT_SUFFIX)
FILE="$FILENAME_PREFIX-$DATE.sql"

echo "Start postgresql dump in file $FILE.."
export PGPASSWORD=${PG_PASSWORD}
export PGPASSFILE=${PG_PASSFILE}

echo "PG_HOST=$PG_HOST"
echo "PG_USER=$PG_USER"
echo "PG_PORT=$PG_PORT"
echo "PG_DB=$PG_DB"
echo "PG_EXTRA_OPTS=$PG_EXTRA_OPTS"

pg_dump -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -f "$FILE" -d "$PG_DB" $PG_EXTRA_OPTS || exit 1
unset PGPASSWORD

echo "Make a tar file.."
tar -czvf $FILE.tar.gz $FILE || exit 1

echo "Push tar file in Azure Blob Storage.."
azcopy copy "$FILE.tar.gz" "${AZ_BLOB_SAS_URL}" || exit 1

echo "Job finished: $(date)"

azcopy list ${AZ_BLOB_SAS_URL} > existing_file || exit 1

[ "${BACKUP_PURGED_AFTER}" == "" ] && echo "No purge configured" && exit 0

echo "Purge obsoleted backup created before $BACKUP_PURGED_AFTER seconds..."

export DELETE_BEFORE=$(date $FILENAME_DATE_FORMAT_SUFFIX -d@"$(( `date +%s`-$BACKUP_PURGED_AFTER))")
echo "Delete backup before $DELETE_BEFORE "

azcopy list $AZ_BLOB_SAS_URL | sed "s#INFO: $FILENAME_PREFIX-\(.*\).sql.tar.gz;.*#$FILENAME_PREFIX-;\1;.sql.tar.gz#" | grep "^$FILENAME_PREFIX" > existingBackups
cat existingBackups | tr ";" "\t"  | awk "{if (\$2 < $DELETE_BEFORE){print \$0;}}" | tr -d '\t' > backupsToDelete

echo "Backups to delete :"
cat backupsToDelete
azcopy rm $AZ_BLOB_SAS_URL --recursive=true --list-of-files=backupsToDelete

exit 0