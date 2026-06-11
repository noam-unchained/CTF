FROM ubuntu:22.04

RUN apt-get update -qq && apt-get install -y python3 libcap2-bin 2>/dev/null

RUN useradd -m -s /bin/bash player && \
    echo "player:player123" | chpasswd

RUN echo "CTF{c4p4b1l1t13s_4r3_n0t_h4rml3ss}" > /root/flag.txt && \
    chmod 600 /root/flag.txt

# Grant python3 the cap_setuid+ep capability
# This lets it call setuid(0) regardless of who runs it
RUN setcap cap_setuid+ep /usr/bin/python3.10

USER player
WORKDIR /home/player

CMD ["/bin/bash"]
