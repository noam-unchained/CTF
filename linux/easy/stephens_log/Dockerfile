FROM ubuntu:22.04

RUN apt-get update -qq && apt-get install -y cron procps 2>/dev/null

RUN useradd -m -s /bin/bash player && \
    echo "player:player123" | chpasswd

RUN echo "CTF{cr0n_wr1t4bl3_pwn3d}" > /root/flag.txt && \
    chmod 600 /root/flag.txt

# Stephen's nightly cleanup — root cron job calling a world-writable script
RUN mkdir -p /opt/maintenance && \
    printf '#!/bin/bash\necho "inventory done" >> /var/log/maintenance.log\n' > /opt/maintenance/cleanup.sh && \
    chmod 777 /opt/maintenance/cleanup.sh

RUN echo "* * * * * root /opt/maintenance/cleanup.sh" >> /etc/cron.d/maintenance && \
    chmod 644 /etc/cron.d/maintenance

RUN echo "Stephen's nightly inventory script runs automatically. Check /opt/maintenance/" \
    > /home/player/note.txt && \
    chown player:player /home/player/note.txt

# Kali-style terminal setup
RUN cat > /home/player/.bashrc << 'BASHRC'
export TERM=xterm-256color
force_color_prompt=yes

PS1='\[\033[01;31m\][django@candie-manor]\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

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
  ║        S T E P H E N ' S   L O G                                ║
  ║        Django Unchained CTF  //  Easy #3                        ║
  ║                                                                  ║
  ║  Stephen runs Candie Manor like clockwork. Every minute, a      ║
  ║  task fires automatically — updating the inventory as root.     ║
  ║                                                                  ║
  ║  Stephen is meticulous. But he left one thing unsecured:        ║
  ║  the script itself. Anyone can write to it.                     ║
  ║                                                                  ║
  ║  There's a note.txt in your home directory with a clue.         ║
  ║                                                                  ║
  ║  "I count, Monsieur Candie."                   — Stephen        ║
  ║                                                                  ║
  ╚══════════════════════════════════════════════════════════════════╝

MOTD

RUN chown player:player /home/player/.bashrc /home/player/.bash_profile

USER player
WORKDIR /home/player

CMD ["bash", "-c", "service cron start && exec /bin/bash --login"]
