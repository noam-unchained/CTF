FROM ubuntu:22.04

RUN apt-get update -qq && apt-get install -y docker.io curl 2>/dev/null

# Django is trapped inside a container — but the docker socket is mounted
RUN useradd -m -s /bin/bash django && \
    echo "django:freedom" | chpasswd && \
    usermod -aG docker django

# The flag lives on the HOST — Django must escape the container to reach it
# For the challenge, we simulate the host flag inside a special location
# that is only accessible if you mount the host filesystem via the docker socket
RUN mkdir -p /host-simulation && \
    echo "CTF{3sc4p3d_c4ndyl4nd_dj4ng0_1s_fr33}" > /host-simulation/flag.txt && \
    chmod 700 /host-simulation && \
    chmod 600 /host-simulation/flag.txt

# Drop a clue
RUN echo "The master's tools are at your disposal. Look carefully at what is mounted." \
    > /home/django/note.txt && \
    chown django:django /home/django/note.txt

USER django
WORKDIR /home/django

CMD ["/bin/bash"]
