FROM qmcgaw/gluetun:v3.35.0 as gluetun

FROM 1.20.6-alpine3.18

RUN mkdir /opt/network-policy-manager
WORKDIR /opt/network-policy-manager

# Get VPN servers
COPY --from=gluetun /gluetun/servers.json ./servers.json

# Build Go
COPY ./main.go ./
RUN go build -o network-policy-manager

ENTRYPOINT [ "/opt/network-policy-manager/network-policy-manager" ]