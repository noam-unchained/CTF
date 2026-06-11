FROM ubuntu:22.04

RUN apt-get update -qq && apt-get install -y cron tar 2>/dev/null

# Users — Django is the player, Stephen is the privileged cron runner
RUN useradd -m -s /bin/bash django && \
    echo "django:freedom" | chpasswd

# Broomhilda's letter — the flag, locked away by Candie
RUN mkdir -p /home/candie/vault && \
    echo "CTF{br00mh1lda_w1ll_b3_fr33_dj4ng0}" > /home/candie/vault/broomhilda.txt && \
    chmod 700 /home/candie/vault && \
    chmod 600 /home/candie/vault/broomhilda.txt && \
    useradd -m candie && \
    chown -R candie:candie /home/candie/vault

# The backup directory — Stephen runs tar on it every minute as root
RUN mkdir -p /opt/candyland/backups && \
    chmod 777 /opt/candyland/backups

# Stephen's cron job: tar everything in /opt/candyland/backups
RUN echo '* * * * * root cd /opt/candyland/backups && tar czf /tmp/backup.tar.gz *' \
    >> /etc/cron.d/candyland && \
    chmod 644 /etc/cron.d/candyland

# A clue for Django
RUN echo "Stephen runs a backup of this directory every minute. Watch your step." \
    > /opt/candyland/backups/README.txt && \
    chown django:django /opt/candyland/backups/README.txt

USER django
WORKDIR /home/django

CMD ["bash", "-c", "service cron start && /bin/bash"]
