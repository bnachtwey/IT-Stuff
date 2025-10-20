# My Notes on installing [HedgeDoc](https://hedgedoc.org/)

in addition to [David Augustat's HowTo](https://davidaugustat.com/web/hedgedoc-on-docker-compose)

- run as a docker container using `docker compose`
- put credentials and further information into `.env` file
- use port `3300` as `3000` may be used by `nginx proxy manager (NPM)`

## `hedgedoc-compose.yaml`

```yaml
version: '3.8'

services:
  database:
    container_name: hedgedoc-db
    image: postgres:16-alpine
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
    volumes:
      - ${DB_VOLUME_PATH}:/var/lib/postgresql/data
    restart: unless-stopped

  app:
    container_name: hedgedoc-app
    image: quay.io/hedgedoc/hedgedoc:latest
    environment:
      - CMD_DB_URL=postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@database:5432/${POSTGRES_DB}
      - CMD_DOMAIN=${CMD_DOMAIN}
      - CMD_PORT={CMD_PORT}
      - CMD_URL_ADDPORT=true
      - NODE_ENV=production
      - CMD_ALLOW_ANONYMOUS=false
      - CMD_ALLOW_ANONYMOUS_EDITS=true
      - CMD_DEFAULT_PERMISSION=private
      - CMD_ALLOW_EMAIL_REGISTER=false
      - CMD_ALLOW_FREEURL=true
      - CMD_ALLOW_GRAVATAR=false
    volumes:
      - ${UPLOADS_VOLUME_PATH}:/hedgedoc/public/uploads
    ports:
      - 3300:3300
    restart: unless-stopped
    depends_on:
      - database

volumes:
  database:
  uploads:
```

## corresponding `.env` file aka `hedgedoc-env`:

```yaml
# Application domain
CMD_DOMAIN=192.168.178.103

# Database credentials
POSTGRES_USER=hedgedoc
POSTGRES_PASSWORD=change_this_password
POSTGRES_DB=hedgedoc

# Volume paths (host-side locations)
DB_VOLUME_PATH=/local/docker/hedgedoc-database
UPLOADS_VOLUME_PATH=/local/docker/hedgedoc-uploads
```

## start up

```bash
docker compose -f hedgedoc-compose.yaml --env-file hedgedoc-env
```

## Check: Does it work?

T.B.D.

## add local users

```bash
docker exec -it hedgedoc-app /hedgedoc/bin/manage_users --add john@example.com
```
