caddy:
  serve_dir: /srv/caddy
  config_parent_dir: /etc/caddy
  config_dir: /etc/caddy/Caddyfile.d
  config_file: /etc/caddy/Caddyfile
  files:
    user: caddy
    group: caddy
    mode: 775
  tls: False
  static_sites:
    funkyboy:
      www_dir: funkyboy
      hosts:
        - http://funkyboy.zone
        - https://funkyboy.zone
        - "http://*.funkyboy.zone"
        - "https://*.funkyboy.zone"
    noahhuppert:
      www_parent_dir: noahhuppert
      www_dir: noahhuppert/www
      hosts:
        - http://noahh.io
        - https://noahh.io
        - "http://*.noahh.io"
        - "https://*.noahh.io"
        - http://noahhuppert.com
        - https://noahhuppert.com
        - "http://*.noahhuppert.com"
        - "https://*.noahhuppert.com"
    file_modes:
      www_dir: file-modes
      hosts:
        - http://modes.funkyboy.zone
        - https://modes.funkyboy.zone
