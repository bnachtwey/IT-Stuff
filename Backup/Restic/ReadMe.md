# My notes on Restic

All the information below can -- of course -- also derived from the [Restic Documentation Page](https://restic.readthedocs.io/en/latest/010_introduction.html).

Nevertheless, I wrote down, how to do backup using several targets.

> [!NOTE
>
> I put all my configs, logs and script to `/local/Restic/{bin|config|log}` including the ssh key if used.

## local backup

Doing a _Restic Backup_  inside your computer may make sense, if you like to have many points in time, but due to any reason cannot use snapshots.

## remote backup to a cloud storage using ssh

As part of the golden [_3-2-1-1-0 rule_](https://en.wikipedia.org/wiki/Glossary_of_backup_terms) at least _one remote copy_ is recommended.

Using a cloud storage with `ssh` access like [Hetzner StorageBox](https://www.hetzner.com/storage/storage-box) is eligible to fulfill this.

### create dedicated ssh key without passphrase

_T.B.D._ figure out how to use ssh key _with_ passphrase.

_By now_ I only used ssh keys without passphrase, so this guide uses no passphrase.

1) create ssh key using e.g. `ed25519`:

   ```bash
   ssh-keygen -t ed25519 -C "Hetzner Storagebox sub2" -f /local/Restic/config/HSB-sub2
   ```

2) copy _public key_ to your cloud storage

### preparation @ Hetzner

Using the _Hetzner StorageBox_ you can define additional accounts and assign dedicated folders with non-current access. So you can do your backup from several machines into one Box.

1) create folder for each Machine
2) create sub-accounts for each machine and assign previously created folder
3) create ssh-key for each subfolder
  
   > [!NOTE]
   >
   > Unfortunately, you cannot assign a ssh key for each sub account, but there's a workaround:
   >
   > 1) create a subfolder `.ssh` in the machine's subfolder of your storage box
   >
   >     ```bash
   >     mkdir <subfolder/.ssh>
   >     chmod 700 <subfolder/.ssh>
   >     ```
   >
   > 2) copy the _ssh public key_ to your main account (AFAIR you cannot access the subfolder directly)
   > 3) move the keyfile's content to  `<machine folder>/.ssh/authorized_keys`
   > 4) fix POSIX ACLn

4) now you should be able to access the subfolder with the subaccount's ssh key :-)

> [!IMPORTANT]
>
> consider the user who the backup script runs:
>
> - need to create a ssh config for your cloud storage,
> - don't forget `include config.d/*` in your `config` ;-)

---

## some scripts and systemd services :-)

- local backup: [`lbackup.sh`](./lbackup.sh)
- local prune: [`lprune.sh`](./lprunde.sh)
- remote backup & prune: [`rbackup.sh`](.rbackup.sh)

- service for local backup: [`lbackup.service`](./lbackup.service)
- service for local prune:  [`lprunde.service`](./lprune.service)
- service for remote backup: [`rbackup.service`](./rbackup.service)

- timer for running local backup at 06:00 -- 23:00/1h: [`lbackup.timer`](./lbackup.timer)
- timer for running local prune at 06:30 -- 23:30/1h: [`lprune.timer`](./lprune.timer)
- timer for running remote backup & prune at 12:00 : [`rbackup.timer`](./rbackup.timer)
