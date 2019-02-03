{% set group = 'salt' %}
{% set dir = '/opt/funkyboy.zone' %}

{{ group }}:
  group.present

{{ dir }}:
  file.directory:
    - group: {{ group }}
  #    - recurse:
    #      - group
    #      - mode
    - dir_mode: 775
