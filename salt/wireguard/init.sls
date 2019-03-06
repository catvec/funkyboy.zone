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

# Interface
{{ pillar.wireguard.setup_script }}:
  file.managed:
    - source: salt://wireguard/setup.sh
    - mode: 700
    - require:
      - file: {{ pillar.wireguard.directory }}

{{ pillar.wireguard.run_setup_script }}-managed:
  file.managed:
    - name: {{ pillar.wireguard.run_setup_script }}
    - mode: 700
    - source: salt://wireguard/run-setup.sh
    - template: jinja
    - require:
      - file: {{ pillar.wireguard.directory }}

{{ pillar.wireguard.check_setup_script }}:
  file.managed:
    - mode: 700
    - source: salt://wireguard/check-setup.sh
    - require:
      - file: {{ pillar.wireguard.directory }}

{{ pillar.wireguard.run_check_setup_script }}:
  file.managed:
    - name: {{ pillar.wireguard.run_check_setup_script }}
    - mode: 700
    - source: salt://wireguard/run-check-setup.sh
    - template: jinja
    - require:
      - file: {{ pillar.wireguard.directory }}

{{ pillar.wireguard.run_setup_script }}-run:
  cmd.run:
    - name: {{ pillar.wireguard.run_setup_script }}
    - unless: {{ pillar.wireguard.run_check_setup_script }}
    - require:
      - kmod: {{ pillar.wireguard.kernel_module }}
      - file: {{ pillar.wireguard.run_setup_script }}-managed
      - file: {{ pillar.wireguard.run_check_setup_script }}
