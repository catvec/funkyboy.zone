# Installs and configures Wireguard.

# Install
{{ pillar.wireguard.package }}:
  pkg.installed

{{ pillar.wireguard.kernel_module }}-kernel-module:
  kmod.present:
    - name: {{ pillar.wireguard.kernel_module }}
    - persist: True

{{ pillar.wireguard.directory }}:
  file.directory:
    - makedirs: True
    - dir_mode: 700

# Setup script
{{ pillar.wireguard.setup_script }}:
  file.managed:
    - source: salt://wireguard/setup.sh
    - mode: 750
    - require:
      - file: {{ pillar.wireguard.directory }}

# Configuration files
{{ pillar.wireguard.config_file }}:
  file.managed:
    - source: salt://wireguard/wg0.conf
    - mode: 600
    - template: jinja
    - require:
      - file: {{ pillar.wireguard.directory }}

configure:
  cmd.run:
    - name: {{ pillar.wireguard.setup_script }} -i {{ pillar.wireguard.interface.name }} -c {{ pillar.wireguard.config_file }}
    - unless: {{ pillar.wireguard.setup_script }} -i {{ pillar.wireguard.interface.name }} -c {{ pillar.wireguard.config_file }} -u
    - require:
      - file: {{ pillar.wireguard.config_file }}
      - file: {{ pillar.wireguard.setup_script }}

# Public key website
{{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.wireguard_public_key.www_dir }}:
  file.recurse:
    - source: salt://wireguard/guide-website-www
    - template: jinja
    - dir_mode: 755
    - file_mode: 755
