FROM ubuntu:22.04

RUN apt-get update -qq && apt-get install -y procps 2>/dev/null

RUN useradd -m -s /bin/bash player && \
    echo "player:player123" | chpasswd

RUN echo "CTF{su1d_b1n4ry_1s_d4ng3r0us}" > /root/flag.txt && \
    chmod 600 /root/flag.txt

# Give 'find' the SUID bit — the classic misconfiguration
RUN chmod u+s /usr/bin/find

# Kali-style terminal setup
RUN cat > /home/player/.bashrc << 'BASHRC'
export TERM=xterm-256color
force_color_prompt=yes

PS1='\[\033[01;31m\][django@candyland-gate]\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

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
  ║        C A N D Y L A N D   G A T E                              ║
  ║        Django Unchained CTF  //  Easy #1                        ║
  ║                                                                  ║
  ║  You and Dr. Schultz have ridden through the night to reach     ║
  ║  Candie's plantation. The gate overseer has stepped away.       ║
  ║                                                                  ║
  ║  Somewhere on this system, a tool was given more power than     ║
  ║  it should have. Use it. Broomhilda's location is in the        ║
  ║  master's private files — locked away in /root/flag.txt.        ║
  ║                                                                  ║
  ║  "The D is silent."                        — Django Freeman     ║
  ║                                                                  ║
  ╚══════════════════════════════════════════════════════════════════╝

MOTD

RUN chown player:player /home/player/.bashrc /home/player/.bash_profile

USER player
WORKDIR /home/player

CMD ["/bin/bash", "--login"]
