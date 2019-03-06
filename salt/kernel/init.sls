# Install Linux Kernel

{{ pillar.kernel.kernel_package }}:
  pkg.installed

{{ pillar.kernel.headers_package }}:
  pkg.installed

reconfigure:
  cmd.run:
    - name: xbps-reconfigure -f {{ pillar.kernel.kernel_package }}
    - onchanges:
      - pkg: {{ pillar.kernel.kernel_package }}
      - pkg: {{ pillar.kernel.headers_package }}
    - require:
      - pkg: {{ pillar.kernel.kernel_package }}
      - pkg: {{ pillar.kernel.headers_package }}
