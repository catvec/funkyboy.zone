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

#configure:
#  cmd.run:
#    - name: wg setconf {{ pillar.wireguard.interface.name }} {{ pillar.wireguard.config_file }}
#    - onchanges:
#      - file: {{ pillar.wireguard.config_file }}
#    - require:
#      - cmd: {{ pillar.wireguard.run_setup_script }}-run
#      - file: {{ pillar.wireguard.config_file }}

# Interface
#{{ pillar.wireguard.setup_script }}:
#  file.managed:
#    - source: salt://wireguard/setup.sh
#    - mode: 700
#    - require:
#      - file: {{ pillar.wireguard.directory }}
#
#{{ pillar.wireguard.run_setup_script }}-managed:
#  file.managed:
#    - name: {{ pillar.wireguard.run_setup_script }}
#    - mode: 700
#    - source: salt://wireguard/run-setup.sh
#    - template: jinja
#    - require:
#      - file: {{ pillar.wireguard.directory }}
#
#{{ pillar.wireguard.check_setup_script }}:
#  file.managed:
#    - mode: 700
#    - source: salt://wireguard/check-setup.sh
#    - require:
#      - file: {{ pillar.wireguard.directory }}
#
#{{ pillar.wireguard.run_check_setup_script }}:
#  file.managed:
#    - name: {{ pillar.wireguard.run_check_setup_script }}
#    - mode: 700
#    - source: salt://wireguard/run-check-setup.sh
#    - template: jinja
#    - require:
#      - file: {{ pillar.wireguard.directory }}
#
#{{ pillar.wireguard.run_setup_script }}-run:
#  cmd.run:
#    - name: {{ pillar.wireguard.run_setup_script }}
#    - unless: {{ pillar.wireguard.run_check_setup_script }}
#    - require:
#      - kmod: {{ pillar.wireguard.kernel_module }}
#      - file: {{ pillar.wireguard.run_setup_script }}-managed
#      - file: {{ pillar.wireguard.run_check_setup_script }}

# Public key website
{{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.wireguard_public_key.www_dir }}:
  file.recurse:
    - source: salt://wireguard/public-key-www
    - template: jinja
    - dir_mode: 755
    - file_mode: 755
