package main

import (
	"github.com/caddyserver/caddy/caddy/caddymain"

	// {% for pkg in pillar['caddy']['plugins'] %}
	_ "{{ pkg }}"
	// {% endfor %}
)

func main() {
	caddymain.Run()
}
