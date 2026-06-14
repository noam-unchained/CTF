FROM ubuntu:22.04

RUN apt-get update -qq && apt-get install -y sudo gcc procps 2>/dev/null

RUN useradd -m -s /bin/bash player && \
    echo "player:player123" | chpasswd

RUN echo "CTF{ld_pr3l04d_w1th_sud0}" > /root/flag.txt && \
    chmod 600 /root/flag.txt

# Misconfigured sudoers: LD_PRELOAD survives into the root process
RUN echo "Defaults env_keep+=LD_PRELOAD" >> /etc/sudoers && \
    echo "player ALL=(root) NOPASSWD: /usr/sbin/apache2" >> /etc/sudoers

RUN apt-get install -y apache2 2>/dev/null

# Kali-style terminal setup
RUN cat > /home/player/.bashrc << 'BASHRC'
export TERM=xterm-256color
force_color_prompt=yes

PS1='\[\033[01;31m\][django@schultz-study]\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

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
  ║        S C H U L T Z ' S   L I B R A R Y                       ║
  ║        Django Unchained CTF  //  Medium #3                      ║
  ║                                                                  ║
  ║  Dr. King Schultz kept a hidden study full of records,          ║
  ║  bounty papers, and the trail that leads to Broomhilda.         ║
  ║  After Schultz was killed, Candie's men took over the room.     ║
  ║                                                                  ║
  ║  They let you restart the web server as root. What they         ║
  ║  forgot is what that actually means when the environment        ║
  ║  isn't cleaned up first.                                        ║
  ║                                                                  ║
  ║  Check your sudo rights. Then think about what you can          ║
  ║  make root load before anything else runs.                      ║
  ║                                                                  ║
  ║  "I'm known to be quite vexing."       — Dr. King Schultz       ║
  ║                                                                  ║
  ╚══════════════════════════════════════════════════════════════════╝

MOTD

RUN chown player:player /home/player/.bashrc /home/player/.bash_profile

USER player
WORKDIR /home/player

CMD ["/bin/bash", "--login"]
