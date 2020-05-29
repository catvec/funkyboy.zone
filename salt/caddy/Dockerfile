FROM alpine:latest

RUN apk add go git
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*

RUN adduser -h /home/caddy caddy
RUN chgrp -R /home/caddy caddy
RUN chown -R /home/caddy caddy
USER caddy

COPY --chown=caddy:caddy main.go .
RUN go mod init caddy
RUN go build

CMD /home/app/caddy
