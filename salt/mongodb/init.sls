# Installs Mongo Database

{{ pillar.mongodb.dir }}:
  archive.extracted:
    - source: {{ pillar.mongodb.source_url }}
    - source_hash: {{ pillar.mongodb.source_sha256sum }}
    - enforce_toplevel: False

{% for bin in pillar['mongodb']['bin_links'] %}
{{ pillar.mongodb.bin_dir }}/{{ bin }}:
  file.symlink:
    - target: {{ pillar.mongodb.dir}}/{{ pillar.mongodb.source_name}}/bin/{{ bin }}
    - mode: 755
    - require:
      - archive: {{ pillar.mongodb.dir }}
{% endfor %}
