# ReadMe

- [Tastenbelegung mit Udev unter Linux anpassen](https://www.heise.de/ratgeber/Tastenbelegung-mit-Udev-unter-Linux-anpassen-10632721.html), heise+, Paywall

  In Summary:

  1) Create generic hwdb-file `/etc/udev/hwdb.d/90-capslock.hwdb` with

     ```bash
     evdev:input:*-e0,1,4,11,14,*
       KEYBOARD_KEY_70039=key_leftshift
     ```

  2) reload hwdb
 
     ```bash
     sudo systemd-hwdb update
     ```
  3) trigger udveb
 
     ```bash
     sudo udevadm trigger
     ```
