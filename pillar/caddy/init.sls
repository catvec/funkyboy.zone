caddy:
  serve_dir: /srv/caddy
  config_parent_dir: /etc/caddy
  config_dir: /etc/caddy/Caddyfile.d
  config_file: /etc/caddy/Caddyfile
  caddy_path: /var/lib/caddy
  files:
    user: caddy
    group: caddy
    mode: 775
  tls: True
  static_sites:
    funkyboy:
      www_dir: funkyboy
      hosts:
        {% for subdomain in [ '', '*.' ] %}
        - "{{ subdomain }}funkyboy.zone"
        {% endfor %}
    noahhuppert:
      www_parent_dir: noahhuppert
      www_dir: noahhuppert/www
      hosts:
        {% for host in [ 'noahh.io', 'noahhuppert.com' ] %}
        {% for subdomain in [ '', '*.' ] %}
        - "{{ subdomain }}{{ host }}"
        {% endfor %}
        {% endfor %}
    file_modes:
      www_dir: file-modes
      hosts:
        - modes.funkyboy.zone
    workout:
      www_dir: workout
      hosts:
        - swoll.funkyboy.zone
    public_www:
      www_dir: public-www
      hosts:
        - public.funkyboy.zone
