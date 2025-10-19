# Can I automatically backup my bitwarden tresor?

Bitwarden does not offer built-in automatic backup of vaults for cloud-hosted accounts, but you can automate backups on personal computers or self-hosted servers using third-party tools, scripts, or dedicated automation projects.

### Methods for Automatic Backup

- **Bitwarden CLI Script:** You can use the official Bitwarden CLI to export your vault with a script, and schedule it with cron (Linux/macOS) or Task Scheduler (Windows). The script can log in, export the vault in encrypted form, and save it to a secure directory. This process can be set to run at regular intervals automatically.[^5][^6]
- **Community Tools:** There are open-source automation apps like "Bitwarden Auto-Backup Manager" (Electron-based), "bitwarden-portal" (Docker image), and "lazywarden" (Python tool) which can automate encrypted backups, manage retention, and sometimes restore backups with minimal intervention.[^1][^2][^9]
- **Self-hosted Deployments:** If running Bitwarden's official server or Vaultwarden, there are options for automating database backups, often running nightly backup jobs using built-in features or external tools.[^3]


### How It Works

- Automated backups use your Bitwarden credentials and either the CLI or API to sync and export your encrypted vault file. You can set these tools/scripts to generate backups at your preferred frequency (e.g., daily, weekly) using standard scheduling software.
- These solutions often let you set encryption passwords and retain a number of recent backups while deleting older ones securely.[^9][^1]
- To restore from a backup, import the encrypted file through Bitwarden’s import function, entering the password you set for the backup encryption.[^2][^6]


### Considerations

- Keep backup files secure as they contain sensitive data, even if encrypted.
- Backups stored on local drives should be in encrypted locations or with strict access controls.
- Automated solutions may require entering your master password into a script or storing it securely for unattended operations, so review the risks and security of your setup.[^4][^6]

Automatic backup for Bitwarden is possible using community tools, CLI scripts, and features in self-hosted versions; it just requires setup and scheduled execution, since it’s not natively built into the cloud app.[^6][^1][^2][^3][^5][^9]
<span style="display:none">[^7][^8]</span>

<div align="center">⁂</div>

[^1]: https://github.com/Reaper0x1/bitwarden-portal

[^2]: https://community.bitwarden.com/t/i-made-a-bitwarden-automatic-backup-manager/71431

[^3]: https://bitwarden.com/help/backup-on-premise/

[^4]: https://www.reddit.com/r/Bitwarden/comments/ruyzrc/simple_way_to_automate_backupsexports/

[^5]: https://dev.to/binarypatrick/bitwarden-automated-backup-374a

[^6]: https://bitwarden.com/blog/how-to-back-up-and-encrypt-your-bitwarden-vault-from-the-command-line/

[^7]: https://bitwarden.com/resources/guide-how-to-create-and-store-a-backup-of-your-bitwarden-vault/

[^8]: https://community.bitwarden.com/t/automatic-backup-of-vault/17419

[^9]: https://github.com/querylab/lazywarden

