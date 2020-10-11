# The sites section of the configuration allows virtual hosts which simply 
# server static content to be configured.
#
# The static_sites section holds a series of maps which contain the keys:
#
#   - www_dir (String): Name of directory inside serve_dir which static content 
#                       will be served out of
#   - hosts (String[]): List of hosts which content will be served out of,
#                       should not include a scheme
#   - browse (Boolean): (Optional) If true makes Caddy show file listing page

{% set build_dir = '/opt/caddy' %}

caddy:
  # List of plugins to import into plugins_file
  plugins:
    # Digital Ocean DNS-01 Let's Encrypt
    - 'github.com/caddyserver/dnsproviders/digitalocean'

    # JWT support
    - 'github.com/BTBurke/caddy-jwt'

    # OAuth & htpasswd resource authentication
    - 'github.com/tarent/loginsrv/caddy'

    # Prometheus metrics exporter
    - 'github.com/miekg/caddy-prometheus'

  # Install location
  install_file: /usr/local/bin/caddy

  build_main: {{ build_dir }}/main.go

  build_dir: {{ build_dir }}
  build_script: {{ build_dir }}/build.sh

  svc: caddy
  svc_file: /etc/sv/caddy/run
  svc_log_file: /etc/sv/caddy/log/run

  # Config
  serve_dir: /srv/caddy
  config_parent_dir: /etc/caddy
  config_dir: /etc/caddy/Caddyfile.d
  config_file: /etc/caddy/Caddyfile
  caddy_path: /var/lib/caddy
  files:
    user: caddy
    group: caddy
    mode: 775

  # Host which metrics for Prometheus will be available on
  metrics_host: 'localhost:9180'

  # Let's Encrypt endpoint
  # staging: https://acme-staging-v02.api.letsencrypt.org/directory
  lets_encrypt_endpoint: https://acme-v02.api.letsencrypt.org/directory

  # Sites
  tls: True
  static_sites:
    # Funky Boy Homepage
    funkyboy:
      www_dir: funkyboy
      hosts:
        {% for subdomain in [ '', '*.' ] %}
        - '{{ subdomain }}funkyboy.zone'
        {% endfor %}

    # Linux file mode permissions cheat sheet site
    file_modes:
      www_dir: file-modes
      hosts:
        - modes.funkyboy.zone

    # Workout plan site
    workout:
      www_dir: workout
      hosts:
        - swoll.funkyboy.zone

    # Public content
    public_www:
      www_dir: public-www
      browse: True
      hosts:
        - public.funkyboy.zone

    # System guide site
    system_guide:
      www_dir: system-guide
      hosts:
        - guide.funkyboy.zone

    # gondola.zone site
    gondola_zone:
      www_dir: gondola-zone
      hosts:
        - gondola.zone
        - '*.gondola.zone'

    # goldblum.zone site
    goldblum_zone:
      www_dir: goldblum-zone
      hosts:
        - goldblum.zone
        - '*.goldblum.zone'

    # Wireguard public key site
    wireguard_public_key:
      www_dir: wireguard-guide
      hosts:
        - wireguard.funkyboy.zone

    # Wiki site
    wiki:
      www_dir: wiki
      hosts:
        - wiki.funkyboy.zone

    # Activism website
    activism:
      www_dir: activism
      hosts:
        - act.funkyboy.zone
