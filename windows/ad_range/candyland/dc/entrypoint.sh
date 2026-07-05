#!/bin/bash
# ============================================================
#  DC entrypoint: provision once, then run Samba in foreground
# ============================================================
set -e

if [ ! -f /var/lib/samba/private/sam.ldb ]; then
    echo "[dc] First boot - provisioning CANDYLAND.LOCAL ..."
    /provision.sh
    echo "[dc] Provisioning complete."
else
    echo "[dc] Existing domain found - skipping provision."
fi

# Samba AD DC ships its own kerberos config
cp -f /var/lib/samba/private/krb5.conf /etc/krb5.conf 2>/dev/null || true

echo "[dc] Starting Samba AD DC ..."
exec samba -i -s /etc/samba/smb.conf
