# Toolkit on this foothold box

Pre-installed and on your PATH:

| Tool | Use |
|------|-----|
| `nmap` | port/service scanning |
| `smbclient` | browse SMB shares, null sessions |
| `ldapsearch` (ldap-utils) | LDAP enumeration |
| `GetNPUsers.py` (impacket) | AS-REP roasting |
| `GetUserSPNs.py` (impacket) | Kerberoasting |
| `secretsdump.py` (impacket) | DCSync / dump hashes |
| `psexec.py` / `wmiexec.py` (impacket) | remote exec / pass-the-hash |
| `bloodhound-python` | collect AD data for BloodHound |
| `john` | crack hashes |
| `kinit` / `klist` | Kerberos tickets |
| `rockyou.txt` | wordlist in your home dir |

> If an Impacket script isn't found by its `*.py` name, run `pipx list` or try the
> `impacket-` prefix (e.g. `impacket-secretsdump`).

## Downloading more tools (you have internet)

```bash
# examples
wget https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64 -O kerbrute
chmod +x kerbrute

pipx install netexec          # nxc (successor to crackmapexec)
pipx install bloodyAD         # ACL abuse / password resets over LDAP
```

## Cracking hashes here

```bash
john --format=krb5asrep --wordlist=~/rockyou.txt hashes.txt   # AS-REP
john --format=krb5tgs   --wordlist=~/rockyou.txt hashes.txt   # Kerberoast
```

(If you prefer hashcat, copy the hash to your own machine: AS-REP = mode 18200,
Kerberoast = mode 13100, NTLM = mode 1000.)
