# Install Go.

go:
  pkg.installed

#{% set repo = 'https://github.com/noah-huppert/void-packages' %}
#{% set dir = '/opt/void-packages' %}
#{% set branch = 'go-1-12' %}
#
#{{ repo }}:
#  git.latest:
#    - branch: {{ branch }}
#    - target: {{ dir }}
#
#bootstrap:
#  cmd.run:
#    - name: {{ dir }}/xbps-src binary-bootstrap
#    - require:
#      - git: {{ repo }}
#
#'{{ dir }}/xbps-src install go':
#  cmd.run:
#    - require:
#      - cmd: bootstrap
