<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# Set up automated Bitwarden exports to a self-hosted Vaultwarden

You can automate exports from Bitwarden to your self-hosted Vaultwarden using scripting and open-source tools that utilize Bitwarden’s CLI and Vaultwarden’s API. The typical setup involves regularly exporting your Bitwarden vault (possibly encrypted) and importing it into Vaultwarden, often with a Docker container or custom script.

### Overview of the Process

- **Automated Exports:** Use the Bitwarden CLI (`bw`) or automation tools like "lazywarden" or "bitwarden-portal" to script the export process. You can set up a schedule (e.g., using cron jobs) that exports your Bitwarden vault in `.json` or encrypted format to a secure folder.[^1][^8]
- **Transfer and Import:** The exported file can then be imported into your Vaultwarden server using the import function within the web vault, or by scripting the process. Some automation tools overwrite the Vaultwarden vault as part of their schedule, preserving previous backups as needed.[^1]
- **Automation Tools:** Some community tools, like "lazywarden" (Python), manage exports, automate imports, keep backup copies, and can be run as Docker containers alongside Vaultwarden.[^8][^1]


### How to Set It Up

1. **Install Bitwarden CLI:** Set up the Bitwarden CLI tool on a trusted computer that can securely access your account. Authenticate the CLI using your master password or environment secrets.[^2][^8]
2. **Write Export Script:** Script a process to log in, export the vault, and (optionally) encrypt the file. The Bitwarden CLI and tools like "lazywarden" can do this automatically.
3. **Schedule the Script:** Use cron (Linux/macOS) or Task Scheduler (Windows) to run your export script at regular intervals (daily, weekly, etc.).[^1]
4. **Import to Vaultwarden:**
    - Manual: Login to your Vaultwarden web vault and use the import function to upload the exported `.json` file.[^4][^1]
    - Automated: Some tools offer features or scripts to directly import or overwrite the Vaultwarden contents with the new export file. Dockerized solutions can run both services together for easier orchestration.[^8][^1]

### Notes and Best Practices

- Automated export/import may not copy over attachments or organization data. Check if your chosen tool supports them.[^2][^1]
- Always secure and encrypt your exported files since they contain all vault data. Use the encrypted `.json` format whenever possible.[^2][^8]
- Store backup files in a secure, preferably encrypted, location with adequate access controls.
- Regularly test your backup and restore process to ensure it works as intended for disaster recovery.

This setup leverages community projects and scripting for reliable, regular Bitwarden-to-Vaultwarden synchronization and backup.[^8][^1][^2]
<span style="display:none">[^3][^5][^6][^7]</span>

<div align="center">⁂</div>

[^1]: https://www.reddit.com/r/Bitwarden/comments/1j8ysgy/export_your_bitwarden_vault_into_vaultwarden/

[^2]: https://bitwarden.com/help/export-your-data/

[^3]: https://pieterhollander.nl/post/bitwarden/

[^4]: https://bitwarden.com/help/migration/

[^5]: https://vaultwarden.discourse.group/t/automatic-export-vault/3055

[^6]: https://forums.lawrencesystems.com/t/bitwarden-free-self-hosted-on-premise-backup-and-high-availability/23284

[^7]: https://bitwarden.com/help/self-host-an-organization/

[^8]: https://github.com/querylab/lazywarden

