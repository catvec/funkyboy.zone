# Install Docker.

{% set pkg = 'docker' %}
{% set svc = 'docker' %}

{{ pkg }}-pkg:
  pkg.installed:
    - name: {{ pkg }}

# Install python bindings so Salt can use Docker
install_py3_bindings:
  cmd.run:
    - name: pip3 install docker
    - unless: pip3 show docker

install_py2_bindings:
  cmd.run:
    - name: pip2 install docker
    - unless: pip2 show docker


{{ svc }}-service-enabled:
  service.enabled:
    - name: {{ svc }}
    - require:
      - pkg: {{ pkg }}-pkg

{{ svc }}-service-running:
  service.running:
    - name: {{ svc }}
    - require:
      - service: {{ svc }}-service-enabled
