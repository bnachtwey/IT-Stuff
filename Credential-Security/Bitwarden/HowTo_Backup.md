<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# How to backup my bitwarden tresor and how to access that backup?

To backup your Bitwarden vault, you can export your data as an encrypted file using the web or desktop app. Accessing that backup later requires importing it back into Bitwarden using your account or the password chosen during encryption.

### Creating a Backup

- Open Bitwarden (web or desktop app).
- Sync your vault to make sure all recent changes are saved.
- Go to the menu and select “Export Vault.”
- Choose the file format you want:
    - **.json (Encrypted):** Recommended for security. You can encrypt with your account (account restricted) or choose a separate password (password protected).[^1][^3]
    - **.json or .csv (Unencrypted):** These are readable and should be stored very securely since anyone with the file can view your passwords.[^3]
- Save the backup file to a secure location, such as a USB drive or encrypted volume. Protect this file, especially if it’s not encrypted, since it contains all your credentials in plain text if not protected.[^2][^4]


### Accessing the Backup

- To restore or access your backup, open Bitwarden and choose the “Import Vault” option.
- If your backup is an encrypted .json file:
    - If it’s account-restricted, only your account can import and decrypt it.[^3]
    - If password-protected, enter the password set during export to decrypt the file.[^3]
- For unencrypted backups (.json or .csv), you can view the content directly but should only import on trusted devices.

Always keep backup files secure, preferably in an encrypted location or physically locked environment. Refresh your backups regularly, especially after major updates to your vault.[^4][^3]
<span style="display:none">[^10][^5][^6][^7][^8][^9]</span>

<div align="center">⁂</div>

[^1]: https://bitwarden.com/blog/how-to-back-up-and-encrypt-your-bitwarden-vault-from-the-command-line/

[^2]: https://bitwarden.com/resources/guide-how-to-create-and-store-a-backup-of-your-bitwarden-vault/

[^3]: https://bitwarden.com/blog/how-to-export-your-bitwarden-vault/

[^4]: https://www.reddit.com/r/Bitwarden/comments/y6d588/making_bitwarden_backups_one_approach/

[^5]: https://www.youtube.com/watch?v=AB5UcxBlAiM

[^6]: https://bitwarden.com/help/backup-on-premise/

[^7]: https://community.bitwarden.com/t/how-to-a-users-guide-to-backing-up-your-bitwarden-vault/44083?page=3

[^8]: https://www.youtube.com/watch?v=UCj22qLsHCI

[^9]: https://www.reddit.com/r/Bitwarden/comments/1f995wl/making_bitwarden_backups_version_20/

[^10]: https://gist.github.com/iAnonymous3000/27c5c7f30b0a8b82ca492f1664e41567

