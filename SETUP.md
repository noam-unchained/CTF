# Setup Guide

This guide is for people who have never used Docker before. The Linux challenges
run inside Docker containers, so you need Docker installed and running before you
can start. The Windows challenges do not use Docker - see the bottom of this page.

If you already have Docker working (`docker ps` runs without an error), skip
straight to [Running a challenge](#running-a-challenge).

---

## What is Docker and why do I need it?

Each Linux challenge ships a `Dockerfile` - a recipe that builds a small,
disposable Linux machine with the challenge already set up inside it. Docker
builds that machine and drops you into a shell as a low-privileged user. Your
job is to escalate to root and read the flag.

Using a container means you can break things freely. When you are done, you throw
the container away and your real computer is untouched.

---

## Installing Docker

### macOS

1. Download **Docker Desktop** from
   <https://www.docker.com/products/docker-desktop/> (pick the build that matches
   your chip - Apple Silicon for M1/M2/M3, Intel otherwise).
2. Open the downloaded `.dmg` and drag **Docker** into Applications.
3. Launch Docker Desktop from Applications. The first launch takes a minute and
   asks for your password.
4. Wait until the whale icon in the menu bar stops animating - that means the
   Docker engine is running.

### Windows

1. Download **Docker Desktop** from
   <https://www.docker.com/products/docker-desktop/>.
2. Run the installer. When asked, leave **"Use WSL 2"** enabled (this is the
   recommended backend; the installer sets it up for you).
3. Reboot if prompted.
4. Launch Docker Desktop from the Start menu and wait until it says
   **"Engine running"**.
5. Use **PowerShell** or **Windows Terminal** to run the `docker` commands below.

### Linux

Install Docker Engine using your distro's package manager. On Debian/Ubuntu the
quickest route is the official convenience script:

```bash
curl -fsSL https://get.docker.com | sh
```

For other distros, follow the official instructions:
<https://docs.docker.com/engine/install/>.

By default Docker needs `sudo`. To run it without `sudo`, add yourself to the
`docker` group, then log out and back in:

```bash
sudo usermod -aG docker $USER
```

---

## Check that Docker is working

Open a terminal and run:

```bash
docker --version
docker ps
```

- `docker --version` should print a version number.
- `docker ps` should print a header row (an empty list is fine).

If `docker ps` errors with something like *"Cannot connect to the Docker
daemon"*, Docker is installed but **not running** - open Docker Desktop (macOS /
Windows) or start the service (`sudo systemctl start docker` on Linux) and try
again.

---

## Running a challenge

Every Linux challenge has the exact two commands in its `instructions.md`. The
pattern is always the same. From inside a challenge folder (the one containing
the `Dockerfile`):

```bash
# 1. Build the image from the Dockerfile in the current directory
docker build -t ctf-challenge .

# 2. Start a container and drop into an interactive shell
docker run -it --rm ctf-challenge
```

What the flags mean:

- `build -t ctf-challenge .` - build an image and name ("tag") it
  `ctf-challenge`. The `.` means "use the Dockerfile in this folder".
- `run -it` - run interactively and attach your terminal so you get a shell.
- `--rm` - automatically delete the container when you exit, so nothing piles up.

You will land in a shell as a low-privileged user. From here, follow the
challenge instructions to escalate to root and read the flag.

To leave the container, type `exit`. Because of `--rm`, the container is removed
automatically.

---

## Cleaning up

`--rm` removes the container on exit, but the built images stay on disk. To list
and remove them:

```bash
docker images              # list images
docker rmi ctf-challenge   # remove one image by name
docker system prune        # remove all unused images, containers, and cache
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `Cannot connect to the Docker daemon` | Docker is not running. Open Docker Desktop, or `sudo systemctl start docker` on Linux. |
| `permission denied while trying to connect` (Linux) | Use `sudo`, or add yourself to the `docker` group (see above) and re-login. |
| `docker: command not found` | Docker is not installed, or your terminal needs to be reopened after install. |
| Build is very slow the first time | Normal - it downloads a base image once, then caches it. |
| Port or name already in use | A previous container is still around. Run `docker ps -a` and `docker rm <id>`. |

---

## Windows challenges

The Windows challenges do **not** use Docker. They need a real Windows VM
(Windows 10 or Windows Server 2019/2022) in VMware, VirtualBox, UTM, or
Parallels. Each challenge has a `setup.ps1` you run as Administrator.

**Always take a VM snapshot before running a setup script, and revert to it
after each challenge.** The scripts intentionally weaken the machine's security.
