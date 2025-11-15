# Housekeeping tasks

## [Repairing PG Inconsistencies](https://docs.ceph.com/en/pacific/rados/operations/pg-repair/)

- identify broken PGs

  ```bash
  ceph health detail
  ```
- investigate -- if you like

- fix them

  ```bash
  ceph pg repair {pgid}
  ```
