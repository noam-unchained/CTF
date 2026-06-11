FROM ubuntu:22.04

RUN apt-get update -qq && apt-get install -y cron 2>/dev/null

RUN useradd -m -s /bin/bash player && \
    echo "player:player123" | chpasswd

# Flag readable only by root
RUN echo "CTF{cr0n_wr1t4bl3_pwn3d}" > /root/flag.txt && \
    chmod 600 /root/flag.txt

# Create a script that root's cron job runs every minute
RUN mkdir -p /opt/maintenance && \
    echo '#!/bin/bash\necho "cleanup done" >> /var/log/maintenance.log' > /opt/maintenance/cleanup.sh && \
    chmod 777 /opt/maintenance/cleanup.sh

# Root crontab runs the script every minute
RUN echo "* * * * * root /opt/maintenance/cleanup.sh" >> /etc/cron.d/maintenance && \
    chmod 644 /etc/cron.d/maintenance

# A hint file for the player
RUN echo "Maintenance scripts live in /opt/maintenance/" > /home/player/README.txt && \
    chown player:player /home/player/README.txt

USER player
WORKDIR /home/player

CMD ["bash", "-c", "service cron start && /bin/bash"]
