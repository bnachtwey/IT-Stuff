# Using ssh with Windows

<!--
AIA Primarily AI, Content edits, Human-initiated, Reviewed v1.0

# changelog
# date          version    remark
# 2026-02-23    0.1        initial coding: take suggestion from *copilot*, rudimentary verify and fix ;-)
-->

using Powershell and also FIDO2-Keys

## 0) What you need (both ends)

### On your Windows client

* **Windows 10 22H2/11** with **OpenSSH Client** **v8.6+** (Win11 23H2 ships ≥8.9/9.x).  
    Check:

    ```powershell
    ssh -V
    ```

    If it’s old, update via **Settings → Optional features → OpenSSH Client** or via winget:

    ```powershell
    winget install --id Microsoft.OpenSSH.Beta
    ```

* A **FIDO2 security key** (USB‑A/C/NFC) or **Windows Hello** configured (PIN/biometric).

### On the SSH server (Linux/BSD/Windows)

* **OpenSSH Server v8.2+** **with FIDO (“sk”) support** compiled in.  
    Check on the server:

    ```bash
    ssh -V           # 8.2 or newer
    # Confirm key algorithms include sk-*:
    ssh -Q key | egrep 'sk-ecdsa|sk-ed25519'
    ```

    If `sk-*` isn’t listed, install a newer OpenSSH build (or the distro package that includes `libfido2`/`libsk-support`).

***

## 1) Generate a FIDO2 SSH key (from PowerShell)

OpenSSH uses two FIDO2 key types:

* `ed25519-sk` (fast, modern; recommended)
* `ecdsa-sk` (P‑256)

> [!Note]
>
> With FIDO keys, the “private key” never leaves the device; OpenSSH stores only a **handle**.

### A) External FIDO2 security key (YubiKey/Solo/Feitian)

Insert your key, then run:

```powershell
ssh-keygen -t ed25519-sk -f $HOME\.ssh\id_ed25519_sk `
  -O resident `
  -O verify-required `
  -C "bjorn@win11 (FIDO2 ed25519-sk)"
```

What the options do:

* `-O resident`     → stores a discoverable credential on the key (handy for roaming)
* `-O verify-required` → requires user presence/verification (PIN/biometric) every use

You’ll be prompted to **touch** the key and (if set) enter the **FIDO PIN**.

### B) Windows Hello as the authenticator (no external key)

If you want to bind to the local device’s **Windows Hello** instead of a USB key:

```powershell
ssh-keygen -t ed25519-sk -f $HOME\.ssh\id_ed25519_sk_winhello `
  -O resident -O verify-required -O platform=winhello `
  -C "bjorn@win11 (WinHello ed25519-sk)"
```

> `-O platform=winhello` tells OpenSSH to use the platform authenticator (Windows WebAuthn → Windows Hello).

This creates:

* `id_ed25519_sk` (public metadata/handle file)
* `id_ed25519_sk.pub` (your public key to copy to servers)

***

## 2) Install the public key on the server

Copy the **.pub** to the server and append to `~/.ssh/authorized_keys`:

```powershell
scp $HOME\.ssh\id_ed25519_sk.pub user@server:/tmp/
ssh user@server "umask 077; mkdir -p ~/.ssh; cat /tmp/id_ed25519_sk.pub >> ~/.ssh/authorized_keys; rm /tmp/id_ed25519_sk.pub"
```

You’ll see the key type in `authorized_keys` as:

* `sk-ssh-ed25519@openssh.com AAAAC3Nza… bjorn@win11 (…)`

***

## 3) (Optional) Use the SSH agent on Windows

The Windows OpenSSH agent can hold references to your FIDO key handles (no secrets leave the hardware).

Start and persist the agent:

```powershell
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
```

Add the key:

```powershell
ssh-add $HOME\.ssh\id_ed25519_sk
# For Windows Hello-backed key:
ssh-add $HOME\.ssh\id_ed25519_sk_winhello
```

List loaded keys:

```powershell
ssh-add -l
```

> If a prompt appears, **touch** the security key or complete **Windows Hello** verification.

***

## 4) Connect over SSH (from PowerShell)

Basic:

```powershell
ssh user@server
```

If you keep multiple identities, be explicit:

```powershell
ssh -i $HOME\.ssh\id_ed25519_sk user@server
```

Or configure per‑host in `~/.ssh/config`:

```text
Host myserver
    HostName server.example.com
    User user
    IdentityFile ~/.ssh/id_ed25519_sk
    IdentitiesOnly yes
```

***

## 5) Advanced & Recovery

### Fetch “resident” keys from the security key

If you generated resident credentials and later switch machines, you can pull the public keys from the token:

```powershell
ssh-keygen -K -f $HOME\.ssh\ # extracts to ~/.ssh/id_* files (touch key when asked)
```

### Enforce verification per use

If you didn’t set `-O verify-required` at creation, you can still demand verification on each auth attempt using the agent:

```powershell
ssh-add -c $HOME\.ssh\id_ed25519_sk   # “confirm” each use
```

### PIN & touch policy

* Set a FIDO2 **PIN** on your key (vendor tool or `ykman fido access change-pin`) to enable **user verification**.
* Some servers or compliance profiles require **UV** (user verification). Your `verify-required` keys will satisfy that.

***

## 6) Common pitfalls & fixes (Windows)

* **No “sk-” algorithms on the server**  
    → Upgrade OpenSSH Server (≥8.2) and install `libfido2` where required.

* **Client says “feature not supported”**  
    → Upgrade **OpenSSH Client** on Windows to 8.6+ (Win11 recommended).

* **Agent not persisting keys**  
    → Ensure `ssh-agent` service is **Running** and **Automatic** (see step 3).

* **Multiple keys; wrong key chosen**  
    → Use `ssh -i …` or `IdentitiesOnly yes` in `~/.ssh/config`.

* **Enterprise policies blocking WebAuthn/WinHello**  
    → If your tenant enforces only certain authenticators, use the **external FIDO2 key** path (A) above.

***

## 7) Bonus: Use the same FIDO2 key for Git over SSH (PowerShell)

```powershell
# One-time: tell Git which SSH to use (Win OpenSSH)
git config --global core.sshCommand "ssh -i $HOME/.ssh/id_ed25519_sk -F $HOME/.ssh/config"
# Then clone/push as usual:
git clone git@github.com:org/repo.git
```

(You already get GitHub’s “new SSH key added” emails when you add keys—handy for auditing.)

***

## 8) Security posture notes (aligns with your “no SMS” stance)

* **FIDO2 (ed25519‑sk)** is **phishing‑resistant** and binds authentication to the origin (SSH here).
* Prefer **hardware keys** or **Windows Hello** over SMS/voice or push fatigue.
* Keep **two** authenticators (primary + spare) and have a documented **recovery** plan.

***

### Want a one‑pager for your team?

I can generate a **drop‑in `~/.ssh/config` template**, a **PowerShell bootstrap script** that:

* verifies OpenSSH version,
* enables `ssh-agent`,
* creates a FIDO2 key,
* and prints copy‑paste server commands.

Would you like the **external key** version, the **Windows Hello** version, or **both**?
