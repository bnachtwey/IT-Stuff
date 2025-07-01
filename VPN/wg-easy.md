## initally just a couple of notes

wg-eady expects by default a TLS secured connection. If run *inside* a local network, where you cannot get a certificate, you want to skip this *TSL only* setting.

So adjust your `docker-compose.yml` file by removing some comments:
change
```bash
    # environment:
    #  Optional:
    #  - PORT=51821
    #  - HOST=0.0.0.0
    #  - INSECURE=false
```
to

```bash
    environment:
    #  Optional:
    #  - PORT=51821
    #  - HOST=0.0.0.0
     - INSECURE=true
```

then destroy your container and run `docker compose up -d` again
