#!/bin/bash
# ============================================================
#  Provision CANDYLAND.LOCAL  (Django Unchained AD range)
#  Runs ONCE on first boot of the dc container.
#
#  Intended attack chain (see WALKTHROUGH.md):
#    recon -> AS-REP roast -> spray -> Kerberoast -> SMB loot
#         -> GenericAll ACL abuse -> DCSync -> Pass-the-Hash -> flag
# ============================================================
set -e

REALM="CANDYLAND.LOCAL"
DOMAIN="CANDYLAND"
BASEDN="DC=candyland,DC=local"
USERS_DN="CN=Users,${BASEDN}"
ADMINPASS="Adm1n#Provision#2024!"     # Administrator (a DA, but NOT given to players)
SAMLDB="/var/lib/samba/private/sam.ldb"

# ---- 1. Provision the domain ------------------------------------------------
rm -f /etc/samba/smb.conf
samba-tool domain provision \
    --use-rfc2307 \
    --realm="${REALM}" \
    --domain="${DOMAIN}" \
    --server-role=dc \
    --dns-backend=SAMBA_INTERNAL \
    --adminpass="${ADMINPASS}" \
    --option="dns forwarder=8.8.8.8"

# ---- 2. Relax password policy so weak/crackable passwords are allowed --------
samba-tool domain passwordsettings set --complexity=off        >/dev/null
samba-tool domain passwordsettings set --min-pwd-length=1       >/dev/null
samba-tool domain passwordsettings set --min-pwd-age=0          >/dev/null
samba-tool domain passwordsettings set --max-pwd-age=0          >/dev/null
samba-tool domain passwordsettings set --history-length=0       >/dev/null

# ---- 3. Helper --------------------------------------------------------------
mkuser () {  # mkuser <sam> <password> <given> <surname> <description>
    samba-tool user create "$1" "$2" \
        --given-name="$3" --surname="$4" --description="$5" >/dev/null
    echo "    [+] user $1"
}
sid_of () { samba-tool user show "$1" --attributes=objectSid | awk '/^objectSid:/{print $2}'; }

echo "[*] Creating users ..."

# --- The prize: Calvin Candie is Domain Admin (password NOT given) ---
mkuser calvin.candie 'S3cr3t_C4ndyl4nd_Pl4nt4t10n!' Calvin Candie 'Owner of Candyland'
samba-tool group addmembers "Domain Admins" calvin.candie >/dev/null

# --- Stephen: the loyal enforcer. Holds domain replication rights (DCSync). ---
#     Password is strong/unknown; players take him over via a GenericAll edge.
mkuser stephen 'Str0ng#Oversee3r_Stephen' Stephen Warren 'Head house servant - runs the estate'

# --- Given-in-brief foothold identity (non-admin). Schultz forged your papers. ---
mkuser d.jango 'Freedom1858!' Django Freeman 'Freed bounty hunter (guest papers)'

# --- AS-REP roastable: Kerberos pre-auth disabled (set below). Cracks to letmein. ---
mkuser b.pooch 'letmein' Butch Pooch 'Candie henchman'

# --- Password-reuse victim: same weak password, revealed by spraying. ---
mkuser l.candie 'letmein' 'Lara Lee' 'Candie-Fitzwilly' 'Calvins sister'

# --- Kerberoastable service account (SPN below). Cracks to Password1. ---
mkuser svc_sql 'Password1' SQL Service 'Candyland Records database service'

# --- Second SPN: strong password = red herring (will NOT crack). ---
mkuser svc_web 'Th1s0neD0esNotCr4ck#42' Web Service 'Records web portal app pool'

# --- Backup service account: creds sit in an SMB share. Has GenericAll on stephen. ---
mkuser svc_backup 'Backup#2023' Backup Service 'Nightly backup task account'

# --- Flavour / spray noise (none are on the intended path) ---
mkuser k.schultz    'Dent1st_Bounty#1858'  King    Schultz     'Travelling dentist'
mkuser b.hildy      'n0R3us3_Br00mhilda!'  Broomhilda vonShaft 'House servant'
mkuser b.crash      'spring2020'           Billy   Crash       'Candie gunhand'
mkuser cora         'C4ndyl4nd#Cora'       Cora    House       'House servant'
mkuser sheba        'Sh3ba#Candie7'        Sheba   Companion   'Candies companion'
mkuser m.stonesipher 'Tr4ck3rD0gs#9'       Ace     Stonesipher 'Slave tracker'
mkuser lil.raj      'R4jExpr3ss!22'        Roger   LilRaj      'House valet'

# ---- 4. Kerberoast: register SPNs on the service accounts --------------------
echo "[*] Registering SPNs ..."
samba-tool spn add MSSQLSvc/records.candyland.local:1433 svc_sql >/dev/null
samba-tool spn add MSSQLSvc/records.candyland.local     svc_sql >/dev/null
samba-tool spn add HTTP/web.candyland.local             svc_web >/dev/null

# ---- 5. AS-REP roast: disable Kerberos pre-auth on b.pooch -------------------
#     userAccountControl 512 (NORMAL_ACCOUNT) | 0x400000 (DONT_REQ_PREAUTH) = 4194816
echo "[*] Disabling Kerberos pre-auth on b.pooch ..."
ldbmodify -H "${SAMLDB}" <<EOF
dn: CN=b.pooch,${USERS_DN}
changetype: modify
replace: userAccountControl
userAccountControl: 4194816
EOF

# ---- 6. ACL abuse: svc_backup gets GenericAll over stephen -------------------
echo "[*] Granting svc_backup GenericAll over stephen ..."
SVC_BACKUP_SID=$(sid_of svc_backup)
samba-tool dsacl set \
    --objectdn="CN=stephen,${USERS_DN}" \
    --sddl="(A;;GA;;;${SVC_BACKUP_SID})" >/dev/null

# ---- 7. DCSync: stephen gets the two replication control rights on the domain -
echo "[*] Granting stephen DS-Replication rights (DCSync) ..."
STEPHEN_SID=$(sid_of stephen)
samba-tool dsacl set \
    --objectdn="${BASEDN}" \
    --sddl="(OA;;CR;1131f6aa-9c07-11d1-f79f-00c04fc2dcd2;;${STEPHEN_SID})(OA;;CR;1131f6ad-9c07-11d1-f79f-00c04fc2dcd2;;${STEPHEN_SID})" >/dev/null

# ---- 8. File shares (records / sql_backups / vault) --------------------------
echo "[*] Building SMB shares ..."
mkdir -p /srv/shares/records /srv/shares/sql_backups /srv/shares/vault

# Public-ish memo: leaks the sAMAccountName convention + a red herring.
cat > /srv/shares/records/README-staff.txt <<'EOF'
CANDYLAND ESTATE - STAFF IT NOTICE
==================================
All estate accounts follow: first-initial.surname   (e.g. Calvin Candie -> calvin.candie)
Service accounts are prefixed svc_ (svc_sql, svc_web, svc_backup).

Reminder from Mr. Stephen: STOP writing passwords on notes in the house.
The old database service password was reset. Do NOT reuse "letmein" anymore.
EOF

# Gated to svc_sql only (reachable after Kerberoasting svc_sql).
cat > /srv/shares/sql_backups/restore_task.ps1 <<'EOF'
# Candyland Records - nightly restore task (scheduled)
# Maps the backup vault using the dedicated backup account.
$user = "CANDYLAND\svc_backup"
$pass = "Backup#2023"
net use B: \\dc\backups /user:$user $pass
Write-Host "Backup account handles restores. Talk to Stephen for estate-wide access."
EOF

# The flag - Domain Admins only. Read it via Pass-the-Hash as calvin.candie.
cat > /srv/shares/vault/broomhilda.txt <<'EOF'
You found her.

Broomhilda von Shaft is free. Candyland has fallen.

CTF{c4ndyl4nd_h4s_f4ll3n_dj4ng0_unch41n3d}
EOF

chmod -R a+rX /srv/shares

cat /root/shares.conf >> /etc/samba/smb.conf

echo "[*] CANDYLAND.LOCAL provisioned. The estate awaits."
