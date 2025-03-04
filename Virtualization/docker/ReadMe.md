# Docker Nice2Know

## you should consider ...
- not be always `root` on your dockerhost!
- to add your main user to the docker group, so you can run the most common commands without being / becoming `root`<br>
  ```
  sudo usermod -aG docker $USER
  ```
## Nice2Know
- The using `docker-compose` the `.yml` file needs no `version: "3"` any more

### Movin the docker data apart from `/var/lib/docker`
Typically the docker daemon stores all data (images, containers, configs) below `/var/lib/docker`. If you follow the *old unix approch* to use separate volumes for e.g. `/tmp` and **`var`** you may run out of space, so getting messages like *no space left on the device*. Using absolute paths for the volumes solve this problem temporarily only as images and container still need increasing space.

A better approch might be to put all the docker stuff in an own volume, but maybe you don't want to mount it to `/var/lib/docker`?

Then you should set a new `data-root` path by:
- check actual setting by
  ```bash
  docker info | grep "Docker Root Dir"
  ```
  This should contain the standard path
  ```bash
  docker info | grep "Docker Root Dir"
   Docker Root Dir: /var/lib/docker
  ```
- edit or create file `/etc/docker/daemon.json`<br>
  add or change the following entry
  ```bash
  {
  "data-root": "/path/to/new/docker-data"
  }
  ```
- stop docker and verify, it hasn't restarted<br>
  ```bash
  systemctl stop docker
  systemctl stop docker.socket

  ps aux | grep -i docker | grep -v grep
  ```
  
>   [!WARNING] 
>   You should sync data before restarting the daemon, e.g. by<br>
>   `sudo rsync -axPS /var/lib/docker/ </path/to/new/docker-data>`

- restart docker<br>
  ```bash
  systemctl start docker
  ```
- verify setting of new path<br>
  ```bash
  docker info | grep "Docker Root Dir"
  ```

  
## Docker and UFW security flaw 
It has been discovered the Docker doesn't always honor UFW rules. Indeed, with an ordinary configuration, docker defines a bunch of rules for your containers, that bypass your *ufw* settings, including the `ufw default deny incoming` 😱

Fixing (thanks to [Jack Wallen](https://www.techrepublic.com/meet-the-team/us/jack-wallen/): [How to fix the Docker and UFW security flaw](https://www.techrepublic.com/article/how-to-fix-the-docker-and-ufw-security-flaw/)):

1. Edit the global docker config file `/etc/default/docker`  and add the following line:
   ```
   DOCKER_OPTS="--iptables=false"
   ```
2. Save and close that file. Restart the docker daemon with the command `sudo systemctl restart docker`.
3. Now, when you deploy a container, it will no longer alter iptables and will honor `ufw`.
