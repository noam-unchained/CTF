FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Core attacker toolkit + SSH. Internet stays open so you can wget/curl more.
RUN apt-get update && apt-get install -y --no-install-recommends \
        openssh-server \
        python3 python3-pip python3-venv \
        nmap \
        smbclient \
        samba-common-bin \
        ldap-utils \
        krb5-user \
        dnsutils \
        netcat-openbsd \
        iproute2 iputils-ping \
        curl wget git \
        john \
        sudo \
        vim less \
    && rm -rf /var/lib/apt/lists/*

# Impacket (GetNPUsers / GetUserSPNs / secretsdump ...) + bloodhound-python + bloodyAD,
# installed globally so the scripts are on PATH for the ssh user.
# impacket is pinned to 0.11.0 - that release installs the example scripts with their
# classic *.py names (GetNPUsers.py, secretsdump.py, ...) which the walkthrough uses.
ENV PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin
RUN pip3 install --no-cache-dir --upgrade pipx \
    && pipx install impacket==0.11.0 \
    && pipx install bloodhound \
    && pipx install bloodyAD \
    && ls -1 /usr/local/bin | grep -Ei 'GetNPUsers|secretsdump|GetUserSPNs'

# The player logs in here.
RUN useradd -m -s /bin/bash django \
    && echo 'django:freedom' | chpasswd \
    && usermod -aG sudo django \
    && echo 'django ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/django

# Kerberos realm config for the impacket/kinit tooling
COPY krb5.conf /etc/krb5.conf
COPY MISSION.txt /home/django/MISSION.txt
COPY tools.md    /home/django/tools.md
COPY entrypoint.sh /entrypoint.sh
RUN chown django:django /home/django/MISSION.txt /home/django/tools.md \
    && chmod +x /entrypoint.sh \
    && mkdir -p /run/sshd

EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
