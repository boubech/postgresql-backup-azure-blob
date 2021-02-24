# postgres-backup-azure-blob-storage

## Usage example

```yaml
postgres:
  image: postgres
  environment:
    POSTGRES_USER: user
    POSTGRES_PASSWORD: password

db-backup-azure-blob-storage:
  image: jboubechtoula/postgres-backup-azure-blob-storage
  links:
    - postgres
  environment:
    CRON_SCHEDULE: '@every 60s'
    FILENAME_PREFIX: my-db-dump
    AZ_BLOB_SAS_URL: 'https://my-storage.blob.core.windows.net/my-container?sp=cl....2BY%3D'
    PG_DATABASE: dbname
    PG_HOST: postgres
    PG_USER: user
    PG_PASSWORD: password
    PG_EXTRA_OPTS: '--schema=public --blobs'
```

# Arguments
| Argument             | Desc.                            | Default value |
|----------------------|----------------------------------|---------------|
| FILENAME_PREFIX      | Filename prefix in blob storage               | my-dump         |
| FILENAME_DATE_SUFFIX | Date format suffix filename in blob storage  | +%Y%m%d%H%M%S  |
| AZ_BLOB_SAS_URL      | Azure Token SAS for blob storage (with read/write authorizations)  |   |
| PG_USER      | PostgreSQL Username  | postgres  |
| PG_DB      | PostgreSQL Database  | postgres  |
| PG_HOST      | PostgreSQL Host  | postgres  |
| PG_PORT      | PostgreSQL Port  | 5432  |
| PG_PASSWORD      | PostgreSQL Password (like PG_PASSWORD)  |   |
| PG_PASSFILE | PostgreSQL Password file (like PGPASSFILE) | |
| PG_EXTRA_OPTS | PostgreSQL Dump extra arguments | |
| CRON_SCHEDULE | Schedule a cron job (example: @every 1h) https://pkg.go.dev/github.com/robfig/cron | |
| MAX_BACKUP_RETENTION_IN_SECONDS | Purge existing backup after N seconds | |