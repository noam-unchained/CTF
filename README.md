# CTF Privilege Escalation Challenges

A collection of hands-on offensive-security challenges themed around Django Unchained.
Three parts: **Linux labs** and **Windows labs** (18 single-host privilege-escalation
challenges across easy/medium/hard), plus a full **Active Directory lab** (a multi-host
domain you attack from SSH all the way to Domain Admin).

---

## Story

You are **Django** - a bounty hunter riding through hostile territory.
Broomhilda is locked away in Candyland, guarded by Calvin Candie, his enforcer Stephen,
and every misconfiguration their sysadmin ever made.

Each challenge is a door. You have the skills to open them all.

---

## Structure

```
CTF_Challenges/
├── linux/                     # Linux labs (Docker)
│   ├── easy/    candyland_gate · the_house · stephens_log
│   ├── medium/  the_cellar · the_stables · schultz_library
│   └── hard/    the_archive · the_cage · the_chains
├── windows/                   # Windows labs (VM) + AD lab (Docker)
│   ├── easy/    front_porch · the_parlor · servants_quarters
│   ├── medium/  the_workshop · the_clocktower · candyland_records
│   ├── hard/    the_impersonator · the_vault · stephens_shadow
│   └── ad_range/
│       └── candyland/         # multi-host Active Directory range
```

---

## Prerequisites

**New to Docker?** Read the [Setup Guide](SETUP.md) first - it walks through
installing Docker on Mac, Windows, and Linux, checking that it works, and what
the build/run commands actually do.

- **Linux labs** - [Docker Desktop](https://www.docker.com/products/docker-desktop/); each folder has a `Dockerfile`, build and run it to get a shell.
- **Windows labs** - a Windows 10 / Server 2019+ VM; each folder has a `setup.ps1`, run as Administrator. **Snapshot the VM before running setup and revert after each challenge.**
- **Active Directory lab** - Docker + Compose (runs the whole domain on your laptop via Samba AD). See its own [README](windows/ad_range/candyland/README.md).

---

## How to Play

1. Read `instructions.md` (labs) or `README.md` (AD range) in the folder.
2. Set up the environment (Docker or VM).
3. Escalate privileges / reach Domain Admin and capture the flag.
4. Hints are in collapsible sections - use them if stuck.
5. Full solution with explanation is at the bottom of each file.

Flag format: `CTF{...}`

---

# Linux Labs

Single-host privilege escalation. Build the `Dockerfile`, get a low-priv shell, escalate to root.

| Level | Challenge | Technique |
|-------|-----------|-----------|
| Easy | [candyland_gate](linux/easy/candyland_gate/) | SUID bit on `find` |
| Easy | [the_house](linux/easy/the_house/) | `sudo vim` shell escape |
| Easy | [stephens_log](linux/easy/stephens_log/) | Overwrite a root-owned cron script |
| Medium | [the_cellar](linux/medium/the_cellar/) | `cap_setuid` on Python |
| Medium | [the_stables](linux/medium/the_stables/) | PATH hijack of a SUID process |
| Medium | [schultz_library](linux/medium/schultz_library/) | Shared-library injection via sudo `env_keep` |
| Hard | [the_archive](linux/hard/the_archive/) | `tar *` wildcard injection in cron |
| Hard | [the_cage](linux/hard/the_cage/) | Docker daemon socket container escape |
| Hard | [the_chains](linux/hard/the_chains/) | `rbash` escape then sudo escalation |

---

# Windows Labs

Single-host privilege escalation on a Windows VM. Run `setup.ps1` as Administrator, then work up to SYSTEM/Administrator.

| Level | Challenge | Technique |
|-------|-----------|-----------|
| Easy | [front_porch](windows/easy/front_porch/) | Unquoted service path |
| Easy | [the_parlor](windows/easy/the_parlor/) | Malicious MSI running as SYSTEM |
| Easy | [servants_quarters](windows/easy/servants_quarters/) | World-writable service binary |
| Medium | [the_workshop](windows/medium/the_workshop/) | DLL planting in a writable app dir |
| Medium | [the_clocktower](windows/medium/the_clocktower/) | Overwrite a SYSTEM scheduled-task binary |
| Medium | [candyland_records](windows/medium/candyland_records/) | Replace an autorun binary before logon |
| Hard | [the_impersonator](windows/hard/the_impersonator/) | Token impersonation (PrintSpoofer / GodPotato) |
| Hard | [the_vault](windows/hard/the_vault/) | Dump NTLM hashes as a Backup Operator |
| Hard | [stephens_shadow](windows/hard/stephens_shadow/) | Pass-the-Hash as Administrator |

---

# Active Directory Lab

**[Raid on Candyland](windows/ad_range/candyland/)** - a full multi-host Windows AD network
(domain `CANDYLAND.LOCAL`), not a single-host privesc. You SSH into a foothold inside the
domain and chain the standard AD attacks to Domain Admin. Runs on Docker via Samba AD.

| Range | Entry | Goal |
|-------|-------|------|
| [candyland](windows/ad_range/candyland/) | SSH foothold + one low-priv domain account | Domain Admin |

<details>
<summary>Show attack chain</summary>

Enumeration (SMB null session / LDAP / RID) &rarr; AS-REP Roasting &rarr; Password Spraying
&rarr; Kerberoasting &rarr; SMB share looting &rarr; ACL abuse (GenericAll via BloodHound)
&rarr; DCSync &rarr; Pass-the-Hash. 15+ accounts, service SPNs, mixed authenticated /
credentialed entry, downloadable tooling on the foothold.

</details>

---

## Disclaimer

These challenges are for education and authorized security training only.
