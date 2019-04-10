# Installs and configures Wireguard.

# Install
{{ pillar.wireguard.package }}:
  pkg.installed

{{ pillar.wireguard.kernel_module }}-kernel-module:
  kmod.present:
    - name: {{ pillar.wireguard.kernel_module }}
    - persist: True

# Configuration files
{{ pillar.wireguard.directory }}:
  file.directory:
    - makedirs: True
    - dir_mode: 700

{{ pillar.wireguard.config_file }}:
  file.managed:
    - source: salt://wireguard/wg0.conf
    - mode: 600
    - template: jinja
    - require:
      - file: {{ pillar.wireguard.directory }}

configure:
  cmd.run:
    - name: wg-quick up {{ pillar.wireguard.interface.name }}
    - unless: wg show {{ pillar.wireguard.interface.name }}
    - require:
      - file: {{ pillar.wireguard.config_file }}

# Public key website
{{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.wireguard_public_key.www_dir }}:
  file.recurse:
    - source: salt://wireguard/guide-website-www
    - template: jinja
    - dir_mode: 755
    - file_mode: 755
