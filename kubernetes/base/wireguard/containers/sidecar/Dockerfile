FROM linuxserver/wireguard:1.0.20210914

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

COPY ./entrypoint.sh /etc/wireguard-docker-entrypoint.sh