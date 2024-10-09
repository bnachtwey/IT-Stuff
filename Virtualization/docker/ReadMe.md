# Docker Nice2Know

## you should consider ...
- not be always `root` on your dockerhost!
- to add your main user to the docker group, so you can run the most common commands without being / becoming `root`<br>
  ```
  sudo usermod -aG docker $USER
  ```
## Nice2Know
- The using `docker-compose` the `.yml` file needs no `version: "3"` any more

  
## Docker and UFW security flaw 
It has been discovered the Docker doesn't always honor UFW rules. Indeed, with an ordinary configuration, docker defines a bunch of rules for your containers, that bypass your *ufw* settings, including the `ufw default deny incoming` 😱

Fixing (thanks to [Jack Wallen](https://www.techrepublic.com/meet-the-team/us/jack-wallen/): [How to fix the Docker and UFW security flaw](https://www.techrepublic.com/article/how-to-fix-the-docker-and-ufw-security-flaw/)):

1. Edit the global docker config file `/etc/default/docker`  and add the following line:
   ```
   DOCKER_OPTS="--iptables=false"
   ```
2. Save and close that file. Restart the docker daemon with the command `sudo systemctl restart docker`.
3. Now, when you deploy a container, it will no longer alter iptables and will honor `ufw`.
