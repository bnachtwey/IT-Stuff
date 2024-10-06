# Running WireHole on a VPS using docker
documentation will follow, do start with some helpfull / important remarks:
## remarks
1) by docker overrides your firewall settings, especially if you use `ufw`. So **all** port provided by your containers are accessible from the internet, neglection your security settings!<br>
   An explanation you can find [at techrepublic](https://www.techrepublic.com/article/how-to-fix-the-docker-and-ufw-security-flaw/).<br>
   The good news are, they also providing a workaround to get your security back:
   - add the following line to your docker settings at `/etc/default/docker`:<br>
     ```
     DOCKER_OPTS="--iptables=false"
     ```
     and restart docker issueing `systemctl restart docker`
2) The wirehole setup published by [*Fábio Assunção*](https://github.com/fabioassuncao/wirehole) starts a webserver to setup clients easily on port `51821`. Unfortunately, it's not secured by SSL or TLS. <br> 
   Concidering the problem mentioned in 1) your wirehole configuration can easily attacked uding MITM 😢<br>
   Workaround:<br>
   1) add the workaround mentioned above
   2) block port `51821` in your VPS's firewall
   3) access the webserser using a ssh-tunnel, so redirect the remote port to your local maschine, e.g.<br>
      ```
      ssh -N -L <localport>:<your VPS' IP>:51821 <user>@<your VPS' IP>
      ```
3) Newer version of *wg-easy* do not support the *WG_PASSWORT* in plain text any more. You have to provide it as an *bcrypt password hash*.<br>
   You can create such a hash easily by running the `wg-easy` container with the special command `wgpw`:<br>
   ```
   docker run -it ghcr.io/wg-easy/wg-easy wgpw YOUR_PASSWORD
   PASSWORD_HASH='$2b$12$coPqCsPtcFO.Ab99xylBNOW4.Iu7OOA2/ZIboHN6/oyxca3MWo7fW' // literally YOUR_PASSWORD
   ```
   Next you must change your config by adding another line:
   ```
   WG_PASSWORD_HASH=<hash created by wgpw>
   ```
   Further informantion you'll find [on the wg-easy github repo](https://github.com/wg-easy/wg-easy/blob/master/How_to_generate_an_bcrypt_hash.md)
