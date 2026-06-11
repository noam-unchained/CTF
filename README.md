# CTF Privilege Escalation Challenges

A collection of hands-on privilege escalation challenges for Linux and Windows,
themed around Django Unchained. Three difficulty levels, 18 challenges total.

---

## Story

You are **Django** — a bounty hunter riding through hostile territory.
Broomhilda is locked away in Candyland, guarded by Calvin Candie, his enforcer Stephen,
and every misconfiguration their sysadmin ever made.

Each challenge is a door. You have the skills to open them all.

---

## Structure

```
CTF_Challenges/
├── linux/
│   ├── easy/
│   │   ├── challenge1_suid/               — SUID binary abuse
│   │   ├── challenge2_sudo/               — Sudo misconfiguration
│   │   └── challenge3_cron/               — Writable cron script
│   ├── medium/
│   │   ├── challenge1_capabilities/       — Linux capabilities abuse
│   │   ├── challenge2_path_hijack/        — PATH hijacking via SUID binary
│   │   └── challenge3_ld_preload/         — LD_PRELOAD injection via sudo
│   └── hard/
│       ├── challenge1_wildcard_injection/  — Tar wildcard injection via cron
│       ├── challenge2_docker_escape/       — Docker socket container escape
│       └── challenge3_rbash_escape/        — Restricted shell escape + sudo
└── windows/
    ├── easy/
    │   ├── challenge1_unquoted_path/           — Unquoted service path
    │   ├── challenge2_always_install_elevated/ — AlwaysInstallElevated MSI
    │   └── challenge3_weak_service_perms/      — Weak service binary permissions
    ├── medium/
    │   ├── challenge1_dll_hijack/              — DLL hijacking
    │   ├── challenge2_scheduled_task/          — Scheduled task with writable binary
    │   └── challenge3_registry_autorun/        — Registry autorun hijack
    └── hard/
        ├── challenge1_seimpersonate/           — SeImpersonatePrivilege (PrintSpoofer/GodPotato)
        ├── challenge2_sam_dump/                — SAM dump via Backup Operator
        └── challenge3_pass_the_hash/           — Pass-the-Hash with NTLM
```

---

## Prerequisites

### Linux challenges
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) — works on Mac, Linux, Windows
- Each challenge folder has a `Dockerfile` — build and run it to get a shell

### Windows challenges
- A Windows 10 or Windows Server 2019/2022 VM (VMware, VirtualBox, UTM, Parallels)
- Each challenge has a `setup.ps1` — run as Administrator to configure the environment
- **Always take a VM snapshot before running setup — revert after each challenge**

---

## How to Play

1. Read `instructions.md` in each challenge folder
2. Set up the environment (Docker or VM)
3. Try to escalate privileges and capture the flag
4. Hints are in collapsible sections — use them if stuck
5. Full solution with explanation is at the bottom of each file

---

## Flag Format

```
CTF{...}
```

---

## Easy Level

| # | Platform | Challenge | Technique |
|---|----------|-----------|-----------|
| 1 | Linux | SUID Binary Abuse | Exploiting SUID bit on `find` |
| 2 | Linux | Sudo Misconfiguration | Abusing `sudo vim` to spawn a root shell |
| 3 | Linux | Writable Cron Script | Overwriting a root-owned cron job script |
| 4 | Windows | Unquoted Service Path | Planting a binary in an unquoted service path |
| 5 | Windows | AlwaysInstallElevated | Crafting a malicious MSI that runs as SYSTEM |
| 6 | Windows | Weak Service Binary Permissions | Replacing a world-writable service binary |

---

## Medium Level

| # | Platform | Challenge | Technique |
|---|----------|-----------|-----------|
| 1 | Linux | Linux Capabilities Abuse | `cap_setuid` on Python to call `setuid(0)` |
| 2 | Linux | PATH Hijacking | Prepend a malicious binary into PATH for a SUID process |
| 3 | Linux | LD_PRELOAD Injection | Inject a shared library via sudo's `env_keep` |
| 4 | Windows | DLL Hijacking | Plant a malicious DLL in a writable application directory |
| 5 | Windows | Scheduled Task Binary Replace | Overwrite the binary of a SYSTEM-run scheduled task |
| 6 | Windows | Registry Autorun Hijack | Replace an autorun binary before the next logon |

---

## Hard Level

| # | Platform | Challenge | Technique |
|---|----------|-----------|-----------|
| 1 | Linux | Tar Wildcard Injection | Abuse `tar *` in a privileged cron job |
| 2 | Linux | Docker Socket Escape | Break out of a container via the Docker daemon |
| 3 | Linux | Restricted Shell Escape | Escape `rbash` then escalate via sudo |
| 4 | Windows | SeImpersonatePrivilege | Token impersonation with PrintSpoofer or GodPotato |
| 5 | Windows | SAM Database Dump | Extract NTLM hashes as a Backup Operator |
| 6 | Windows | Pass-the-Hash | Authenticate as Administrator using only an NTLM hash |

---

## Disclaimer

These challenges are for education and authorized security training only.
