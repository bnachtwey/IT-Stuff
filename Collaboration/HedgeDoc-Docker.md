# My Notes on installing [HedgeDoc](https://hedgedoc.org/)

in addition to [David Augustat's HowTo](https://davidaugustat.com/web/hedgedoc-on-docker-compose)

- run as a docker container using `docker compose`
- put credentials and further information into `.env` file
- use port `3300` as `3000` may be used by `linkwarden local vault`

## `hedgedoc/docker-compose.yaml`

```yaml
services:
  database:
    container_name: hedgedoc-db
    image: postgres:16-alpine
    environment:
      - POSTGRES_USER=hedgedoc
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=hedgedoc
    volumes:
      - ${DB_VOLUME_PATH}:/var/lib/postgresql/data
    restart: always
  app:
    container_name: hedgedoc-app
    image: quay.io/hedgedoc/hedgedoc:latest
    environment:
      - CMD_DB_URL=postgres://hedgedoc:${POSTGRES_PASSWORD}@database:5432/hedgedoc
      - CMD_DOMAIN=${CMD_DOMAIN}
      - CMD_PORT=${CMD_PORT}
      - CMD_URL_ADDPORT=false
      - NODE_ENV=production
      - CMD_ALLOW_ANONYMOUS=false
      - CMD_ALLOW_ANONYMOUS_EDITS=true
      - CMD_DEFAULT_PERMISSION=private
      - CMD_ALLOW_EMAIL_REGISTER=false
      - CMD_ALLOW_FREEURL=true
      - CMD_ALLOW_GRAVATAR=false
      - CMD_PROTOCOL_USESSL=true
    volumes:
      - ${UPLOADS_VOLUME_PATH}:/hedgedoc/public/uploads
    ports:
      - "${CMD_PORT}:${CMD_PORT}"
    restart: always
    depends_on:
      - database
volumes:
  database:
  uploads:
```

## corresponding `hedgedoc/.env` file aka `hedgedoc-env`

```yaml
# Application domain
CMD_DOMAIN=192.168.178.103
CMD_PORT=3300

# Database credentials
POSTGRES_PASSWORD=change_this_password

# Volume paths (host-side locations)
DB_VOLUME_PATH=/container/hedgedoc/database
UPLOADS_VOLUME_PATH=/container/hedgedoc/uploads
```

## Conciderations

- setting `CMD_URL_ADDPORT` to `true` causes problems with NPM as each internal link will direct to the port used inside the container
- setting `CMD_PROTOCOL_USESSL` to `true` is necessary to allow cookies passing through NPM, e.g. for credentials

## add local users

```bash
docker exec -it hedgedoc-app /hedgedoc/bin/manage_users --add john@example.com
```

## Backup and restore

As I use no docker volumes, but dedicated folders to store the data, the backup script suggested by David fails (partly):

```bash
# bash backup-hedgedoc.sh
hedgedoc_uploads
docker: Error response from daemon: error evaluating symlinks from mount source "/docker/volumes/hedgedoc_uploads/_data": lstat /docker/volumes/hedgedoc_uploads: no such file or directory

Run 'docker run --help' for more information
Error: Failed to start busybox backup container
tar: hedgedoc_uploads_backup.tgz: Cannot stat: No such file or directory
tar: Exiting with failure status due to previous errors
Backup created: hedgedoc_backup_2025-10-22_18-26-49.tgz
```

## nu approach for uploads

```bash
tar -cf uploads.$(date --utc "+%F--%HU%m").tgz $(docker inspect hedgedoc-app --format '{{json .Mounts}}' | jq | grep "Source" | awk -F '"' '{print $4}')
```
