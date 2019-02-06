# Sets permissions on the directory which this repository is uploaded to on
# the server so that users in the salt group can access it.

{% set group = 'salt' %}
{% set dir = '/opt/funkyboy.zone' %}

{{ group }}:
  group.present

{{ dir }}:
  file.directory:
    - group: {{ group }}
    - recurse:
      - group
      - mode
    - dir_mode: 771
