# Creates users, sets up their ssh key in their account, and configures their
# Zsh profile.
#
# See the users pillar for an explanation of the pillar values.

{% for user in pillar['users'] %}

{% set zsh_units_dir = '/home/' + user['name'] + '/.zprofile.d' %}

# Create user
{{ user.name }}:
  user.present:
    - shell: /bin/zsh
    {% if user.groups %}
    - groups:
      {% for group in user.groups %}
      - {{ group }}
      {% endfor %} 
    {% endif %}

#  Add user's SSH key to authorized_keys
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

# Load Zsh profile which loads Zsh units
/home/{{ user.name }}/.zshrc:
  file.managed:
    - source: salt://users/zshrc
    - user: {{ user.name }}

# Load user's Zsh units
# ... If we should load all Zsh units
{% if user.zsh_units == 'all' %}

{{ zsh_units_dir }}:
  file.recurse:
    - source: salt://users/zprofile.d
    - user: {{ user.name }}

{% else %}
# ... If we should load a few specific units

{% for zsh_unit in user.zsh_units %}

{{ zsh_units_dir }}/{{ zsh_unit }}:
  file.managed:
    - source: salt://users/zprofile.d/{{ zsh_unit }}
    - user: {{ user.name }}

{% endfor %}
{% endif %}
{% endfor %}
