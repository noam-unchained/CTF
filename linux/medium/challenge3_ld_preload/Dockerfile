FROM ubuntu:22.04

RUN apt-get update -qq && apt-get install -y sudo gcc 2>/dev/null

RUN useradd -m -s /bin/bash player && \
    echo "player:player123" | chpasswd

RUN echo "CTF{ld_pr3l04d_w1th_sud0}" > /root/flag.txt && \
    chmod 600 /root/flag.txt

# Misconfigured sudoers: player can run apache2 as root AND preserve environment
# env_keep+=LD_PRELOAD is the critical misconfiguration
RUN echo "Defaults env_keep+=LD_PRELOAD" >> /etc/sudoers && \
    echo "player ALL=(root) NOPASSWD: /usr/sbin/apache2" >> /etc/sudoers

# Install apache2 to make the sudo entry valid
RUN apt-get install -y apache2 2>/dev/null

USER player
WORKDIR /home/player

CMD ["/bin/bash"]
