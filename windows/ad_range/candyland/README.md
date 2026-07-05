# Raid on Candyland &mdash; Active Directory Attack Range

**Theme:** Django Unchained &nbsp;|&nbsp; **Domain:** `CANDYLAND.LOCAL` &nbsp;|&nbsp; **Goal:** Domain Admin

A self-contained, multi-host **Windows Active Directory** lab you attack over SSH.
Unlike the single-host `windows/` privesc challenges, this is a whole **network**:
a domain controller, file servers, a web portal, and 15+ domain accounts. You start
with one low-privileged foothold and work your way to **Domain Admin** using the
attacks you will actually use on a real engagement.

It runs on your laptop with Docker &mdash; the "Windows" domain is served by
**Samba Active Directory**, which speaks real Kerberos, LDAP and SMB, so tools like
Impacket, BloodHound and NetExec behave the way they do against Windows.

---

## Story

You are **Django**. Dr. Schultz has slipped you onto a Linux box camped just inside
Candyland's network. **Calvin Candie** runs this estate as **Domain Admin**, his
enforcer **Stephen** really pulls the strings, and their sysadmin left every corner
cut. Broomhilda is locked in the vault. Fight your way from a set of forged guest
papers to the master's own credentials and set her free.

---

## Architecture

```
                    docker network 172.28.10.0/24
   ┌──────────────┐
   │   foothold   │  172.28.10.100   <-- you SSH in here (port 2222)
   │  (Kali-ish)  │      tools + internet
   └──────┬───────┘
          │
   ┌──────┴───────────────────────────────────────────┐
   │                                                   │
┌──┴───────────┐   ┌───────────────┐   ┌───────────────┴─┐
│      dc      │   │    stables    │   │       web       │
│ 172.28.10.10 │   │ 172.28.10.20  │   │  172.28.10.30   │
│ Samba AD DC  │   │ anon SMB      │   │ Records portal  │
│ DNS/Krb/LDAP │   │ (recon)       │   │ (recon)         │
│ SMB + vault  │   └───────────────┘   └─────────────────┘
└──────────────┘
```

---

## Requirements

- Docker Desktop (or Docker Engine) with Compose. See the repo [Setup Guide](../../../SETUP.md).
- ~2 GB disk, a couple GB RAM. Works on Apple Silicon and Intel/AMD.

---

## Run it

```bash
cd windows/ad_range/candyland
docker compose up -d --build      # first build takes a few minutes
```

Give the DC ~60&ndash;90 seconds to finish provisioning the domain on first boot
(`docker compose logs -f dc` &mdash; wait for *"CANDYLAND.LOCAL provisioned"*).

Then SSH into your foothold:

```bash
ssh django@localhost -p 2222      # password: freedom
cat ~/MISSION.txt                 # your brief
cat ~/tools.md                    # what's installed + how to grab more
```

Tear down (wipes the domain too):

```bash
docker compose down -v
```

---

## What you're given

| Thing | Value |
|-------|-------|
| SSH foothold | `django` / `freedom` on `localhost:2222` |
| Forged guest domain account | `d.jango` / `Freedom1858!` (low-priv, non-admin) |
| Target | Domain Admin, then read `\\dc\vault\broomhilda.txt` |

Everything else &mdash; the other 14 accounts, the service passwords, Stephen's and
Candie's credentials &mdash; you have to earn.

---

## The attacks this range teaches

This is the standard AD kill chain, in order:

1. **Enumeration** &mdash; SMB null sessions, LDAP, RID cycling to build the user list.
2. **AS-REP Roasting** &mdash; an account with Kerberos pre-auth disabled.
3. **Password Spraying** &mdash; a cracked password reused across the domain.
4. **Kerberoasting** &mdash; a service account (SPN) with a weak password.
5. **SMB share looting** &mdash; a credential left in a script on a share.
6. **ACL abuse (BloodHound)** &mdash; a `GenericAll` edge onto a privileged user.
7. **DCSync** &mdash; replication rights used to dump the domain's hashes.
8. **Pass-the-Hash** &mdash; use Candie's NT hash to open the vault.

Full solution and graduated hints are in **[WALKTHROUGH.md](WALKTHROUGH.md)** &mdash;
try each stage yourself first.

---

## Note on realism

The domain is served by **Samba AD**, not Windows Server, so a few things differ:
there is no WinRM/RDP and no real MSSQL daemon &mdash; the service accounts exist with
their SPNs (which is all Kerberoasting needs), and remote access is via SMB/Impacket
rather than `evil-winrm`. The *techniques* (roasting, spraying, ACL abuse, DCSync,
pass-the-hash) are identical to a Windows environment.
