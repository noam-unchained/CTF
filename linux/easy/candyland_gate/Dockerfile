FROM ubuntu:22.04

RUN useradd -m -s /bin/bash player && \
    echo "player:player123" | chpasswd

# Create the flag readable only by root
RUN mkdir -p /root && \
    echo "CTF{su1d_b1n4ry_1s_d4ng3r0us}" > /root/flag.txt && \
    chmod 600 /root/flag.txt

# Give 'find' the SUID bit — the classic misconfiguration
RUN chmod u+s /usr/bin/find

USER player
WORKDIR /home/player

CMD ["/bin/bash"]
