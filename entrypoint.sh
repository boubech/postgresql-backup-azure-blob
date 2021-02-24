#!/bin/bash

set -e

export FILENAME_PREFIX=${FILENAME_PREFIX:-dump}
export FILENAME_DATE_FORMAT_SUFFIX=${FILENAME_DATE_FORMAT_SUFFIX:-+%Y%m%d%H%M%S}
export BACKUP_PURGED_AFTER=${BACKUP_PURGED_AFTER:-2592000}
export PG_USER=${PG_USER:-postgres}
export PG_DB=${PG_DB:-postgres}
export PG_HOST=${PG_HOST:-postgres}
export PG_PORT=${PG_PORT:-5432}

[ "${AZ_BLOB_SAS_URL}" == "" ] && echo "Variable env. AZ_BLOB_SAS_URL undefined" && exit 1

if [ "${CRON_SCHEDULE}" == "" ]
then
  sh backup.sh
else
  exec go-cron "$CRON_SCHEDULE" /bin/sh backup.sh
fi

exit 0