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
│   │   ├── challenge1_suid/
│   │   ├── challenge2_sudo/
│   │   └── challenge3_cron/
│   ├── medium/
│   │   ├── challenge1_capabilities/
│   │   ├── challenge2_path_hijack/
│   │   └── challenge3_ld_preload/
│   └── hard/
│       ├── challenge1_wildcard_injection/
│       ├── challenge2_docker_escape/
│       └── challenge3_rbash_escape/
└── windows/
    ├── easy/
    │   ├── challenge1_unquoted_path/
    │   ├── challenge2_always_install_elevated/
    │   └── challenge3_weak_service_perms/
    ├── medium/
    │   ├── challenge1_dll_hijack/
    │   ├── challenge2_scheduled_task/
    │   └── challenge3_registry_autorun/
    └── hard/
        ├── challenge1_seimpersonate/
        ├── challenge2_sam_dump/
        └── challenge3_pass_the_hash/
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
4. Hints are in collapsible sections inside each challenge — use them if stuck
5. Full solution with explanation is at the bottom of each file

---

## Flag Format

```
CTF{...}
```

---

## Easy Level

| # | Platform | Challenge |
|---|----------|-----------|
| 1 | Linux | [challenge1_suid](linux/easy/challenge1_suid/) |
| 2 | Linux | [challenge2_sudo](linux/easy/challenge2_sudo/) |
| 3 | Linux | [challenge3_cron](linux/easy/challenge3_cron/) |
| 4 | Windows | [challenge1_unquoted_path](windows/easy/challenge1_unquoted_path/) |
| 5 | Windows | [challenge2_always_install_elevated](windows/easy/challenge2_always_install_elevated/) |
| 6 | Windows | [challenge3_weak_service_perms](windows/easy/challenge3_weak_service_perms/) |

<details>
<summary>Show techniques</summary>

| # | Platform | Technique |
|---|----------|-----------|
| 1 | Linux | Exploiting SUID bit on `find` |
| 2 | Linux | Abusing `sudo vim` to spawn a root shell |
| 3 | Linux | Overwriting a root-owned cron job script |
| 4 | Windows | Planting a binary in an unquoted service path |
| 5 | Windows | Crafting a malicious MSI that runs as SYSTEM |
| 6 | Windows | Replacing a world-writable service binary |

</details>

---

## Medium Level

| # | Platform | Challenge |
|---|----------|-----------|
| 1 | Linux | [challenge1_capabilities](linux/medium/challenge1_capabilities/) |
| 2 | Linux | [challenge2_path_hijack](linux/medium/challenge2_path_hijack/) |
| 3 | Linux | [challenge3_ld_preload](linux/medium/challenge3_ld_preload/) |
| 4 | Windows | [challenge1_dll_hijack](windows/medium/challenge1_dll_hijack/) |
| 5 | Windows | [challenge2_scheduled_task](windows/medium/challenge2_scheduled_task/) |
| 6 | Windows | [challenge3_registry_autorun](windows/medium/challenge3_registry_autorun/) |

<details>
<summary>Show techniques</summary>

| # | Platform | Technique |
|---|----------|-----------|
| 1 | Linux | `cap_setuid` on Python to call `setuid(0)` |
| 2 | Linux | Prepend a malicious binary into PATH for a SUID process |
| 3 | Linux | Inject a shared library via sudo's `env_keep` |
| 4 | Windows | Plant a malicious DLL in a writable application directory |
| 5 | Windows | Overwrite the binary of a SYSTEM-run scheduled task |
| 6 | Windows | Replace an autorun binary before the next logon |

</details>

---

## Hard Level

| # | Platform | Challenge |
|---|----------|-----------|
| 1 | Linux | [challenge1_wildcard_injection](linux/hard/challenge1_wildcard_injection/) |
| 2 | Linux | [challenge2_docker_escape](linux/hard/challenge2_docker_escape/) |
| 3 | Linux | [challenge3_rbash_escape](linux/hard/challenge3_rbash_escape/) |
| 4 | Windows | [challenge1_seimpersonate](windows/hard/challenge1_seimpersonate/) |
| 5 | Windows | [challenge2_sam_dump](windows/hard/challenge2_sam_dump/) |
| 6 | Windows | [challenge3_pass_the_hash](windows/hard/challenge3_pass_the_hash/) |

<details>
<summary>Show techniques</summary>

| # | Platform | Technique |
|---|----------|-----------|
| 1 | Linux | Abuse `tar *` in a privileged cron job |
| 2 | Linux | Break out of a container via the Docker daemon socket |
| 3 | Linux | Escape `rbash` then escalate via sudo |
| 4 | Windows | Token impersonation with PrintSpoofer or GodPotato |
| 5 | Windows | Extract NTLM hashes as a Backup Operator |
| 6 | Windows | Authenticate as Administrator using only an NTLM hash |

</details>

---

## Disclaimer

These challenges are for education and authorized security training only.
