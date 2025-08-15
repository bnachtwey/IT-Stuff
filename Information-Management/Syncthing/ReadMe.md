# My notes on Synthing

[Sything](https://docs.syncthing.net/index.html) seems to be a quite nice opportunity to keep data _in sync_ for at least two devices.

But there are also some limitation I will have a look on

- Synthing tries direct connections, so
  - both devices need to _see_ each other, e.g. by
    - being in the same VLAN
    - being exposed to the internet (OK, at least the Synthing port `22067`)
  - as a failback, the offical _syncthing relay server_ can be used, but
    - then it's not fully controlled by the user
  - as an alternative, you may run your own, private relay server using [strelaysrv](https://docs.syncthing.net/users/strelaysrv.html)
