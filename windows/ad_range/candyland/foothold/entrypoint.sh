#!/bin/bash
set -e

# Fallback name resolution (in case DNS to the DC is slow to come up).
grep -q candyland.local /etc/hosts || cat >> /etc/hosts <<'EOF'
172.28.10.10   dc.candyland.local dc candyland.local records.candyland.local
172.28.10.20   stables.candyland.local stables
172.28.10.30   web.candyland.local web
EOF

# Fetch rockyou for cracking if we have internet and it's not already here.
if [ ! -f /home/django/rockyou.txt ]; then
    ( wget -q -O /home/django/rockyou.txt \
        https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt \
        && chown django:django /home/django/rockyou.txt ) \
      || echo "[foothold] (no internet yet - grab a wordlist later with wget)"
fi

echo "[foothold] Ready. SSH in with:  ssh django@localhost -p 2222   (password: freedom)"
exec /usr/sbin/sshd -D -e
