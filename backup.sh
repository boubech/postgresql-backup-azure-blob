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

[ "${MAX_BACKUP_RETENTION_IN_SECONDS}" == "" ] && echo "No purge configured" && exit 0

./purge.sh

exit $?