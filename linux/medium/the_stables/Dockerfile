FROM ubuntu:22.04

RUN apt-get update -qq && apt-get install -y gcc procps 2>/dev/null

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
    system("service apache2 status");
    return 0;
}
EOF

RUN gcc /tmp/monitor.c -o /usr/local/bin/monitor && \
    chmod 4755 /usr/local/bin/monitor && \
    rm /tmp/monitor.c

# Kali-style terminal setup
RUN cat > /home/player/.bashrc << 'BASHRC'
export TERM=xterm-256color
force_color_prompt=yes

PS1='\[\033[01;31m\][django@candyland-stables]\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

alias ls='ls --color=auto'
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'

HISTSIZE=1000
HISTFILESIZE=2000
HISTCONTROL=ignoreboth
BASHRC

RUN cat > /home/player/.bash_profile << 'PROFILE'
cat /etc/motd
echo ""
if [ -f ~/.bashrc ]; then . ~/.bashrc; fi
PROFILE

RUN cat > /etc/motd << 'MOTD'

  ╔══════════════════════════════════════════════════════════════════╗
  ║                                                                  ║
  ║        T H E   S T A B L E S                                    ║
  ║        Django Unchained CTF  //  Medium #2                      ║
  ║                                                                  ║
  ║  Candie's overseers built a monitoring tool to check on         ║
  ║  operations across the plantation. It runs with root's          ║
  ║  authority — and it calls another program by name alone,        ║
  ║  without specifying exactly where to find it.                   ║
  ║                                                                  ║
  ║  That path is yours to control.                                 ║
  ║                                                                  ║
  ║  The binary is at /usr/local/bin/monitor.                       ║
  ║  Candie's private papers are in /root/flag.txt.                 ║
  ║                                                                  ║
  ║  "100 miles of bad road."              — Dr. King Schultz       ║
  ║                                                                  ║
  ╚══════════════════════════════════════════════════════════════════╝

MOTD

RUN chown player:player /home/player/.bashrc /home/player/.bash_profile

USER player
WORKDIR /home/player

CMD ["/bin/bash", "--login"]
