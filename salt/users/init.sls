{% for user in pillar['users'] %}
{{ user.name }}:
  user.present:
    - shell: /bin/zsh
    {% if user.groups %}
    - groups:
      {% for group in user.groups %}
      - {{ group }}
      {% endfor %} 
    {% endif %}
/home/{{ user.name }}/.ssh:
  file.directory:
    - makedirs: True
    - user: {{ user.name }}
    - mode: 700
    - require:
      - user: {{ user.name }}

/home/{{ user.name}}/.ssh/authorized_keys:
  file.managed:
    - contents: |
        {{ user.public_key }}
    - create: True
    - user: {{ user.name }}
    - mode: 600
    - require:
      - file: /home/{{ user.name }}/.ssh
{% endfor %}
