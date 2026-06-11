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
│   │   ├── candyland_gate/
│   │   ├── the_house/
│   │   └── stephens_log/
│   ├── medium/
│   │   ├── the_cellar/
│   │   ├── the_stables/
│   │   └── schultz_library/
│   └── hard/
│       ├── the_archive/
│       ├── the_cage/
│       └── the_chains/
└── windows/
    ├── easy/
    │   ├── front_porch/
    │   ├── the_parlor/
    │   └── servants_quarters/
    ├── medium/
    │   ├── the_workshop/
    │   ├── the_clocktower/
    │   └── candyland_records/
    └── hard/
        ├── the_impersonator/
        ├── the_vault/
        └── stephens_shadow/
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
| 1 | Linux | [candyland_gate](linux/easy/candyland_gate/) |
| 2 | Linux | [the_house](linux/easy/the_house/) |
| 3 | Linux | [stephens_log](linux/easy/stephens_log/) |
| 4 | Windows | [front_porch](windows/easy/front_porch/) |
| 5 | Windows | [the_parlor](windows/easy/the_parlor/) |
| 6 | Windows | [servants_quarters](windows/easy/servants_quarters/) |

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
| 1 | Linux | [the_cellar](linux/medium/the_cellar/) |
| 2 | Linux | [the_stables](linux/medium/the_stables/) |
| 3 | Linux | [schultz_library](linux/medium/schultz_library/) |
| 4 | Windows | [the_workshop](windows/medium/the_workshop/) |
| 5 | Windows | [the_clocktower](windows/medium/the_clocktower/) |
| 6 | Windows | [candyland_records](windows/medium/candyland_records/) |

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
| 1 | Linux | [the_archive](linux/hard/the_archive/) |
| 2 | Linux | [the_cage](linux/hard/the_cage/) |
| 3 | Linux | [the_chains](linux/hard/the_chains/) |
| 4 | Windows | [the_impersonator](windows/hard/the_impersonator/) |
| 5 | Windows | [the_vault](windows/hard/the_vault/) |
| 6 | Windows | [stephens_shadow](windows/hard/stephens_shadow/) |

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
