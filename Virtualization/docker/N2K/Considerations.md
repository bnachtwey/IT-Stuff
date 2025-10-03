# you should consider ... (good practises in a nutshell)
- not be always `root` on your dockerhost!
- to add your main user to the docker group, so you can run the most common commands without being / becoming `root`<br>
  ```
  sudo usermod -aG docker $USER
  ```
- use [WatchTower](https://github.com/containrrr/watchtower) to keep your container updated automatically<br>
  [Article in the _Linux Handbook_](https://linuxhandbook.com/watchtower/)
- user [Portainer](https://www.portainer.io/) for easy container management
- use either _docker files_ or _docker compose files_ (I suggest), but do not mix.
