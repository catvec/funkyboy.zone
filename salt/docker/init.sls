# Install Docker.
{% for pkg in pillar['docker']['pkgs'] %}
{{ pkg }}-install:
  pkg.installed:
    - name: {{ pkg }}
{% endfor %}

{% for pkg in pillar['docker']['py3_pkgs'] %}
# Install python bindings so Salt can use Docker
install_py3_bindings_{{ pkg }}:
  cmd.run:
    - name: pip3 install {{ pkg }}
    - unless: pip3 show {{ pkg }}
{% endfor %}

{% for pkg in pillar['docker']['py2_pkgs'] %}
# Install python bindings so Salt can use Docker
install_py2_bindings_{{ pkg }}:
  cmd.run:
    - name: pip2 install {{ pkg }}
    - unless: pip2 show {{ pkg }}
{% endfor %}

{{ pillar.docker.svc }}-service-enabled:
  service.enabled:
    - name: {{ pillar.docker.svc }}
    - require:
      {% for pkg in pillar['docker']['pkgs'] %}
      - pkg: {{ pkg }}-install
      {% endfor %}

{{ pillar.docker.svc }}-service-running:
  service.running:
    - name: {{ pillar.docker.svc }}
    - require:
      - service: {{ pillar.docker.svc }}-service-enabled
