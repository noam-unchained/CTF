FROM ubuntu:22.04

RUN apt-get update -qq && apt-get install -y sudo vim procps 2>/dev/null

RUN useradd -m -s /bin/bash player && \
    echo "player:player123" | chpasswd

RUN echo "CTF{sud0_v1m_g4v3_m3_r00t}" > /root/flag.txt && \
    chmod 600 /root/flag.txt

# Misconfigured sudoers: player can run vim as root without a password
RUN echo "player ALL=(root) NOPASSWD: /usr/bin/vim" >> /etc/sudoers

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
  ║        T H E   B I G   H O U S E                                ║
  ║        Django Unchained CTF  //  Easy #2                        ║
  ║                                                                  ║
  ║  You've made it inside Candie Manor. Stephen left the study     ║
  ║  unattended — and something is running here with far more       ║
  ║  privilege than it needs.                                        ║
  ║                                                                  ║
  ║  Calvin's private ledger is locked in /root/flag.txt.           ║
  ║  Find what Stephen left behind and use it to get inside.        ║
  ║                                                                  ║
  ║  "Gentlemen, you had my curiosity.                              ║
  ║   Now you have my attention."          — Calvin J. Candie       ║
  ║                                                                  ║
  ╚══════════════════════════════════════════════════════════════════╝

MOTD

RUN chown player:player /home/player/.bashrc /home/player/.bash_profile

USER player
WORKDIR /home/player

CMD ["/bin/bash", "--login"]
