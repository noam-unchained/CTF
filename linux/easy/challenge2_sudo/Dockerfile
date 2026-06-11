FROM ubuntu:22.04

RUN apt-get update -qq && apt-get install -y sudo vim 2>/dev/null

RUN useradd -m -s /bin/bash player && \
    echo "player:player123" | chpasswd

# Flag readable only by root
RUN echo "CTF{sud0_v1m_g4v3_m3_r00t}" > /root/flag.txt && \
    chmod 600 /root/flag.txt

# Misconfigured sudoers: player can run vim as root without a password
RUN echo "player ALL=(root) NOPASSWD: /usr/bin/vim" >> /etc/sudoers

USER player
WORKDIR /home/player

CMD ["/bin/bash"]
