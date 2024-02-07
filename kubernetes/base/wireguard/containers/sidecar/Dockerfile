FROM linuxserver/wireguard:1.0.20210914

RUN curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /usr/bin/kubectl
RUN chmod +x /usr/bin/kubectl

COPY ./entrypoint.sh /etc/wireguard-docker-entrypoint.sh
RUN chmod +x /etc/wireguard-docker-entrypoint.sh
ENTRYPOINT /etc/wireguard-docker-entrypoint.sh