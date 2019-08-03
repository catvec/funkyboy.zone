package main

import (
	"github.com/caddyserver/caddy/caddy/caddymain"

	_ "github.com/BTBurke/caddy-jwt"
	_ "github.com/caddyserver/dnsproviders/digitalocean"
	_ "github.com/miekg/caddy-prometheus"
	_ "github.com/tarent/loginsrv/caddy"
)

func main() {
	caddymain.Run()
}
