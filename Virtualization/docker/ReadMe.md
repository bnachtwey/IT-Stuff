# Docker Nice2Know

## Installing Docker on Debian

due to the [offical guide](https://docs.docker.com/engine/install/debian/#install-using-the-repository)

### Prepare

```bash
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
```

### Install

remove old docker stuff first

```bash
sudo apt-get -y remove $(dpkg -l | grep docker | awk '{print $2}' | xargs)
sudo apt-get -y autoremove
```
then install newly

```bash
sudo apt-get update
sudo apt-get install -y docker-ce
```
> There's no need to install `docker-compose` seperately, btw that causes problems like this
> ```bash
> dpkg: error processing archive /var/cache/apt/archives/docker-compose-plugin_5.0.1-1~debian.13~trixie_amd64.deb (--unpack):
>  trying to overwrite '/usr/libexec/docker/cli-plugins/docker-compose', which is also in package docker-compose (2.26.1-4)
> ```

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

> deprecated
> 1. Edit the global docker config file `/etc/default/docker`  and add the following line:
> ```
> DOCKER_OPTS="--iptables=false"
> ```
1. Edit the global docker config file `/etc/default/daemon.json`  and add the following line:
   ```
   "iptables": false
   ```
> [!NOTE]
> Multiple entries are seperated by `;`   
3. Save and close that file. Restart the docker daemon with the command `sudo systemctl restart docker`.
4. Now, when you deploy a container, it will no longer alter iptables and will honor `ufw`.
