FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends samba \
    && rm -rf /var/lib/apt/lists/*

COPY smb.conf /etc/samba/smb.conf
COPY share/ /srv/stables/
RUN chmod -R a+rX /srv/stables \
    && mkdir -p /var/run/samba /var/lib/samba/private /var/log/samba

EXPOSE 139/tcp 445/tcp
# nmblookup registers the workgroup; smbd serves the anonymous share
CMD ["smbd", "--foreground", "--no-process-group", "--debuglevel=1"]
