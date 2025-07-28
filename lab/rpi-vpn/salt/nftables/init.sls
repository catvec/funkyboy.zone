# Install and configure nftables firewall
nftables_pkg:
  pkg.installed:
    - name: {{ pillar.nftables.pkg }}

{{ pillar.nftables.config_file }}:
  file.managed:
    - source: salt://nftables-secret/nftables.conf
    - template: jinja
    - check_cmd: nft -c -f
    - require:
      - pkg: nftables_pkg

{{ pillar.nftables.service }}:
  service.running:
    - enable: True
    - restart: True
    - watch:
      - file: {{ pillar.nftables.config_file }}
    - require:
      - pkg: nftables_pkg
      - file: {{ pillar.nftables.config_file }}
