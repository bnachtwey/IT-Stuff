# Collecting some thoughts on best practises

-- raw edition, needs many beautifications and additions :-( --

## DB2
- to avoid "cannot start due to full log filesystems", place a dummy file in the ACTLOG directory, 10GB should work well, e.g. for linux by
  ```bash
  dd if=/dev/urandom of=/actlog/dummy.10G-file bs=1M count=10240
  ```
  I suggest to use _random_ data instead of zeros (from `/dev/zero`) saving reals space instead of "dedup and compression savings"

  - if there's no such file, some other approaches may work
    1) if db2 itself is still able to start: [do a db2 backup from the db2 cli](https://www.ibm.com/support/pages/archive-log-directories-are-full-and-server-will-not-start)
    2) Linux: check if there are usable _admin reserved blocks_
       ```bash
       root@host:~# tune2fs -l /dev/mapper/filesystem  | grep -E "Block size|Reserved block count"
       Reserved block count:     1041561
       Block size:               4096
       ```
       and descrease it, e.g. for ext2
       ```bash
       root@host:~# tune2fs -m 1 /dev/mapper/filesystem
       tune2fs 1.47.2 (1-Jan-2025)
       Setting reserved blocks percentage to 1% (208312 blocks)
       
       root@host:~# tune2fs -l /dev/mapper/filesystem  | grep -E "Block size|Reserved block count"
       Reserved block count:     208312
       Block size:               4096
       ```
    3) [Move the actlog to another location](https://www.ibm.com/docs/en/tsm/7.1.0?topic=mdrls-moving-only-active-log-archive-log-archive-failover-log)

        Althogh documented for TSM7, it also works for ISP8.1 :-)
    some Linux ideas:
    5) if your are using an LVM, you can extand the logical volume (LV)
    6) if your volume group (VG) has no space left, add another physical volume (PV) to extend the VG, then extend your LV
    7) if you have no further PV nor space left in your VG, you may use a file as PV to extend VG and LV

       t.b.d.

       
    8) if you've applied the last step you need to remove that _Fake-PV_, so
       - do a db2 backup
       - stop TSM/SP
       - umount actlog filesystem
       - resize your volume, e.g. by `lvresize -L <newsize> --resizefs <path>`

         => I suggest to reduce it to a smaller size and extend afterwards
       - ensure your LV resides on the remaining PV
       - reduce VG by removing the extra PV
       - exten your LV either to full VG size ... or have a 10GB resever left for the next crash
