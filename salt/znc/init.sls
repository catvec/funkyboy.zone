# Installs ZNC IRC bouncer (https://wiki.znc.in/ZNC).
#
# Relies on files placed by the znc-secret state.

{% set pkg = 'znc' %}
{% set svc = 'znc' %}
{% set svc_run_f = '/etc/sv/znc/run' %}
{% set znc_conf_f = pillar['znc']['directory'] + '/' + pillar['znc']['config_file'] %}

{{ pkg }}:
  pkg.installed

# Configuration
{{ znc_conf_f }}:
  file.managed:
    - source: salt://znc/znc.conf
    - template: jinja
    - makedirs: True
    - mode: 775
    - dir_mode: 775

{{ pillar.znc.directory }}:
  file.directory:
    - user: znc
    - group: znc
    - mode: 775
    - recurse:
      - user
      - group
      - mode
    - require:
      - file: {{ znc_conf_f }}

# Service
{{ svc_run_f }}:
  file.managed:
    - source: salt://znc/run
    - template: jinja
    - mode: 755
    - require:
      - pkg: {{ pkg }}

{{ svc }}-enabled:
  service.enabled:
    - name: {{ svc }}
    - require:
      - file: {{ svc_run_f }}

{{ svc }}-running:
  service.running:
    - name: {{ svc }}
    - require:
      - service: {{ svc }}-enabled
    - watch:
      - file: {{ svc_run_f }}
      #      - file: {{ znc_conf_f }}

# Caddy
{{ pillar.caddy.config_dir }}/{{ pillar.znc.caddy.config_file }}:
  file.managed:
    - source: salt://znc/Caddyfile
    - template: jinja
    - user: {{ pillar.caddy.files.user }}
    - group: {{ pillar.caddy.files.group }}
    - mode: {{ pillar.caddy.files.mode }}
