# CTF Privilege Escalation Challenges

A collection of hands-on privilege escalation challenges for Linux and Windows.

---

## Structure

```
CTF_Challenges/
├── linux/
│   ├── easy/
│   │   ├── challenge1_suid/             — SUID binary abuse
│   │   ├── challenge2_sudo/             — Sudo misconfiguration
│   │   └── challenge3_cron/             — Writable cron script
│   ├── medium/
│   │   ├── challenge1_capabilities/     — Linux capabilities abuse
│   │   ├── challenge2_path_hijack/      — PATH hijacking via SUID binary
│   │   └── challenge3_ld_preload/       — LD_PRELOAD injection via sudo
│   └── hard/                            (coming soon)
└── windows/
    ├── easy/
    │   ├── challenge1_unquoted_path/           — Unquoted service path
    │   ├── challenge2_always_install_elevated/ — AlwaysInstallElevated MSI
    │   └── challenge3_weak_service_perms/      — Weak service binary permissions
    ├── medium/
    │   ├── challenge1_dll_hijack/         — DLL hijacking
    │   ├── challenge2_scheduled_task/     — Scheduled task with writable binary
    │   └── challenge3_registry_autorun/   — Registry autorun hijack
    └── hard/                              (coming soon)
```

---

## Prerequisites

### Linux challenges
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (works on Mac, Linux, Windows)
- Each challenge has a `Dockerfile` — build and run it to get a shell

### Windows challenges
- A Windows 10 or Windows Server 2019/2022 VM (VMware, VirtualBox, UTM, Parallels)
- Each challenge has a `setup.ps1` — run it as Administrator to configure the environment
- **Always take a VM snapshot before running setup — revert after each challenge**

---

## How to Play

1. Read `instructions.md` in each challenge folder
2. Set up the environment (Docker or VM)
3. Try to escalate privileges and capture the flag
4. Hints are hidden in collapsible sections — use them if stuck
5. The full solution is at the bottom of each instructions file

---

## Flags Format

All flags follow the format: `CTF{...}`

---

## Easy Level — Challenges

| # | Platform | Challenge | Technique |
|---|----------|-----------|-----------|
| 1 | Linux | SUID Binary Abuse | Exploiting SUID bit on `find` |
| 2 | Linux | Sudo Misconfiguration | Abusing `sudo vim` to spawn a root shell |
| 3 | Linux | Writable Cron Script | Overwriting a root-owned cron job script |
| 4 | Windows | Unquoted Service Path | Planting a binary in an unquoted service path |
| 5 | Windows | AlwaysInstallElevated | Crafting a malicious MSI that runs as SYSTEM |
| 6 | Windows | Weak Service Binary Permissions | Replacing a world-writable service binary |

---

## Medium Level — Challenges

| # | Platform | Challenge | Technique |
|---|----------|-----------|-----------|
| 1 | Linux | Linux Capabilities Abuse | `cap_setuid` on Python to call `setuid(0)` |
| 2 | Linux | PATH Hijacking | Prepend a malicious binary into PATH for a SUID process |
| 3 | Linux | LD_PRELOAD Injection | Inject a shared library via sudo's `env_keep` |
| 4 | Windows | DLL Hijacking | Plant a malicious DLL in a writable application directory |
| 5 | Windows | Scheduled Task Binary Replace | Overwrite the binary of a SYSTEM-run scheduled task |
| 6 | Windows | Registry Autorun Hijack | Replace an autorun binary before the next logon |
