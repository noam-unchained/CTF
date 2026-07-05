FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Samba AD DC + tools used by the provisioning script
RUN apt-get update && apt-get install -y --no-install-recommends \
        samba \
        smbclient \
        ldb-tools \
        krb5-user \
        krb5-config \
        winbind \
        libnss-winbind \
        libpam-winbind \
        dnsutils \
        procps \
        iproute2 \
    && rm -rf /var/lib/apt/lists/*

# Provisioning + startup scripts
COPY provision.sh /provision.sh
COPY entrypoint.sh /entrypoint.sh
COPY shares.conf /root/shares.conf
RUN chmod +x /provision.sh /entrypoint.sh

# SMB, LDAP, LDAPS, Kerberos, DNS, Global Catalog
EXPOSE 53/tcp 53/udp 88/tcp 88/udp 135/tcp 389/tcp 389/udp 445/tcp 464/tcp 636/tcp 3268/tcp 3269/tcp

ENTRYPOINT ["/entrypoint.sh"]
