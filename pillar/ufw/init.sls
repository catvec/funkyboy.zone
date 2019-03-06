# Configuration for ufw formula: https://github.com/mariodpros/ufw-formula
{% set dir = '/etc/ufw' %}

ufw:
  directory: {{ dir }}
  package: ufw
  service: ufw
  rules_ip4_file: {{ dir }}/user.rules
  rules_ip6_file: {{ dir }}/user6.rules
  rules:
    # SSH
    - port: 22
      allow:
        - tcp
        - udp
      deny: []

    # HTTP
    - port: 80
      allow:
        - tcp
        - udp
      deny: []
    - port: 443
      allow:
        - tcp
        - udp
      deny: []

    # IRC
    - port: 6697
      allow:
        - tcp
      deny:
        - udp

    # Factorio
    - port: 34197
      allow:
        - udp
      deny:
        - tcp
    - port: 27015
      allow:
        - tcp
      deny:
        - udp
