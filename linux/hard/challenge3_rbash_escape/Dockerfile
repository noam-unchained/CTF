FROM ubuntu:22.04

RUN apt-get update -qq && apt-get install -y sudo vim less man-db 2>/dev/null

# Django lands in a restricted bash shell (rbash)
# rbash blocks: cd, PATH changes, redirects, and running commands with /
RUN useradd -m -s /bin/rbash django && \
    echo "django:freedom" | chpasswd

# Only allow a few commands via a restricted bin
RUN mkdir -p /home/django/bin && \
    ln -s /usr/bin/less /home/django/bin/less && \
    ln -s /usr/bin/vim  /home/django/bin/vim  && \
    ln -s /usr/bin/man  /home/django/bin/man  && \
    echo 'export PATH=/home/django/bin' >> /home/django/.bashrc && \
    chown -R django:django /home/django/bin

# Once out of rbash, django can use vim as root via sudo — the second step
RUN echo "django ALL=(root) NOPASSWD: /usr/bin/vim" >> /etc/sudoers

# The flag
RUN echo "CTF{n04m_unch41n3d_dj4ng0_br0k3_fr33}" > /root/flag.txt && \
    chmod 600 /root/flag.txt

# Lock down .bashrc so django can't just edit it in the container startup
RUN chown root:root /home/django/.bashrc && chmod 644 /home/django/.bashrc

USER django
WORKDIR /home/django

CMD ["/bin/bash", "--rcfile", "/home/django/.bashrc"]
