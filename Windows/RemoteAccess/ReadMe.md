# Remote Access to a Windows11 VM using RDP

## suggestes Approach by [MS copilot](https://m365.cloud.microsoft/chat)

To access **a single application on a Windows 11 VM using RDP**, you can use **RemoteApp mode** instead of delivering the full desktop. Here’s how:

---

### ✅ **Option 1: Configure RemoteApp on Windows 11 (Pro/Enterprise)**
RemoteApp lets you publish an application so it appears as if it runs locally on the client.

**Steps:**
1. **Enable Remote Desktop**  
   - Go to **Settings → System → Remote Desktop** and turn it on.

2. **Install the Application**  
   - Ensure the app you want to publish is installed on the VM.

3. **Allow RemoteApp Execution**  
   - Open **Local Group Policy Editor** (`gpedit.msc`):  
     `Computer Configuration → Administrative Templates → Windows Components → Remote Desktop Services → Remote Desktop Session Host → Connections`  
     Enable **Allow remote start of unlisted programs**.  
   - Or set registry key:  
     ```cmd
     reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v fAllowUnlistedRemotePrograms /t REG_DWORD /d 1
     ```

4. **Restrict to Specific App (Optional)**  
   - Create keys under:  
     `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server\TSAppAllowList\Applications`  
     Example for Acrobat Reader:  
     ```reg
     [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server\TSAppAllowList\Applications\MyAdobeReaderApp]
     "Name"="Adobe Reader"
     "Path"="C:\\Program Files\\Adobe\\Acrobat DC\\Acrobat\\Acrobat.exe"
     ```

5. **Create RDP File for RemoteApp**  
   - Save your RDP connection and edit the `.rdp` file:  
     ```
     remoteapplicationmode:i:1
     remoteapplicationname:s:YourAppName
     remoteapplicationprogram:s:C:\Path\To\App.exe
     ```
   - Double-click the `.rdp` file to launch only that app.

---

### ✅ **Option 2: Use RemoteApp Tool**
If you prefer a GUI, use [RemoteApp Tool](https://github.com/kimmknight/remoteapptool) to:
- Create/manage RemoteApps on Windows 11.
- Generate `.RDP` or MSI installers for clients.
- Configure icons and session options easily.

---

### ✅ **Option 3: Group Policy for Single App**
For kiosk-like setups:
- In **gpedit.msc**:  
  `User Configuration → Administrative Templates → System → Custom User Interface`  
  Enable and set the app path (e.g., `C:\Program Files\App\App.exe`).  
This forces the session to start only that app.

---

#### **Important Notes**
- Requires **Windows 11 Pro or Enterprise** (RemoteApp is not supported on Home edition).
- Ensure firewall allows RDP (TCP 3389).
- If using Azure Virtual Desktop or RDS, you can publish apps via **RemoteApp collections** for enterprise scenarios.

---
---

To configure **Remmina on Linux** for remote access to **Outlook** running on the foreign host `VM11`, you can use **RDP with RemoteApp mode** so only Outlook is launched instead of the full desktop.

---

### ✅ **Steps to Create Remmina Profile**

1. **Install Remmina and RDP Plugin**
   ```bash
   sudo apt update
   sudo apt install remmina remmina-plugin-rdp
   ```

2. **Create a New Connection in Remmina**
   - Open **Remmina** → Click **+** to add a new profile.
   - **Protocol**: `RDP - Remote Desktop Protocol`
   - **Server**: `VM11` (or its IP address)
   - **Username / Password**: Your Windows credentials.
   - **Domain**: If required by your environment.

3. **Enable RemoteApp Mode for Outlook**
   - In the **Advanced** tab of the profile:
     - Add these **RDP options** under “Extra Parameters”:
       ```
       remoteapplicationmode:i:1
       remoteapplicationname:s:Outlook
       remoteapplicationprogram:s:C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE
       ```
     - (Adjust the path if Outlook is installed elsewhere.)

4. **Optional: Clipboard & Drive Redirection**
   - Enable **Clipboard sharing** and **Drive redirection** in the advanced settings if needed.

5. **Save and Connect**
   - Click **Save** and then **Connect**.  
   - Remmina will start an RDP session that launches **only Outlook** from `B11VM`.

---

### ✅ **Alternative: Use `.rdp` File**
If you prefer, create an `.rdp` file with:
```
full address:s:B11VM
remoteapplicationmode:i:1
remoteapplicationname:s:Outlook
remoteapplicationprogram:s:C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE
```
Then import this file into Remmina.

---

#### **Requirements**
- `B11VM` must have **Remote Desktop enabled** and allow RemoteApp execution.
- Outlook must be installed on `VM11`.
- Windows edition should be **Pro or Enterprise** (RemoteApp is not supported on Home).
