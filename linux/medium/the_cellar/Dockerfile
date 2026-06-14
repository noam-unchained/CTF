FROM ubuntu:22.04

RUN apt-get update -qq && apt-get install -y python3 libcap2-bin procps 2>/dev/null

RUN useradd -m -s /bin/bash player && \
    echo "player:player123" | chpasswd

RUN echo "CTF{c4p4b1l1t13s_4r3_n0t_h4rml3ss}" > /root/flag.txt && \
    chmod 600 /root/flag.txt

# Grant python3 the cap_setuid+ep capability
RUN setcap cap_setuid+ep /usr/bin/python3.10

# Kali-style terminal setup
RUN cat > /home/player/.bashrc << 'BASHRC'
export TERM=xterm-256color
force_color_prompt=yes

PS1='\[\033[01;31m\][django@candyland-cellar]\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

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
  ║        T H E   C E L L A R                                      ║
  ║        Django Unchained CTF  //  Medium #1                      ║
  ║                                                                  ║
  ║  Beneath Candie Manor, the overseers keep records of the        ║
  ║  Mandingo fighters. To manage access without going full root,   ║
  ║  they gave the record tool a "limited" special privilege.       ║
  ║                                                                  ║
  ║  Limited. That's what they thought.                             ║
  ║                                                                  ║
  ║  Find the tool. Understand what it can do. Use it to read       ║
  ║  Candie's private files in /root/flag.txt.                      ║
  ║                                                                  ║
  ║  "The Beethoven of Mandingo fighting." — Calvin J. Candie       ║
  ║                                                                  ║
  ╚══════════════════════════════════════════════════════════════════╝

MOTD

RUN chown player:player /home/player/.bashrc /home/player/.bash_profile

USER player
WORKDIR /home/player

CMD ["/bin/bash", "--login"]
