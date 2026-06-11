FROM ubuntu:22.04

RUN apt-get update -qq && apt-get install -y gcc 2>/dev/null

RUN useradd -m -s /bin/bash player && \
    echo "player:player123" | chpasswd

RUN echo "CTF{p4th_h1j4ck_v14_su1d}" > /root/flag.txt && \
    chmod 600 /root/flag.txt

# A vulnerable SUID C binary that calls system("service apache2 status")
# without using an absolute path for 'service'
RUN cat > /tmp/monitor.c << 'EOF'
#include <stdlib.h>
#include <unistd.h>
int main() {
    setuid(0);
    // Calls 'service' without full path — relies on PATH
    system("service apache2 status");
    return 0;
}
EOF

RUN gcc /tmp/monitor.c -o /usr/local/bin/monitor && \
    chmod 4755 /usr/local/bin/monitor && \
    rm /tmp/monitor.c

USER player
WORKDIR /home/player

CMD ["/bin/bash"]
