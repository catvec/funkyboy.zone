# Installs postfix for a send only email setup.

{% set postfix_svc = 'postfix' %}
{% set opendkim_svc = 'opendkim' %}
{% set opendkim_svc_dir = '/etc/sv/' + opendkim_svc %}
{% set opendkim_svc_file = opendkim_svc_dir + '/run' %}

mailx:
  pkg.installed

postfix:
  pkg.installed

opendkim:
  pkg.installed

# Postfix configuration
{{ pillar.email.postfix.config_file }}:
  file.managed:
    - source: salt://email/main.cf
    - mode: 644

{{ pillar.email.aliases_file }}:
  file.managed:
    - source: salt://email/aliases
    - mode: 644
    - template: jinja

newaliases:
  cmd.run:
    - onchanges:
      - file: {{ pillar.email.aliases_file }}

# OpenDKIM user
{{ pillar.email.opendkim.group }}-group:
  group.present:
    - name: {{ pillar.email.opendkim.group }}
    - members:
      - {{ pillar.email.postfix.user }}
    - require:
      - pkg: postfix

{{ pillar.email.opendkim.user }}-user:
  user.present:
    - name: {{ pillar.email.opendkim.user }}
    - createhome: False
    - groups:
      - {{ pillar.email.opendkim.group }}
    - require:
      - group: {{ pillar.email.opendkim.group }}-group

# OpenDKIM configuration
{{ pillar.email.opendkim.directory }}:
  file.directory:
    - user: {{ pillar.email.opendkim.user }}
    - group: {{ pillar.email.opendkim.group }}
    - file_mode: 775
    - dir_mode: 775

{{ pillar.email.opendkim.run_directory }}:
  file.directory:
    - user: {{ pillar.email.opendkim.user }}
    - group: {{ pillar.email.opendkim.group }}
    - file_mode: 775
    - dir_mode: 775

{{ pillar.email.opendkim.config_file }}:
  file.managed:
    - source: salt://email/opendkim.conf
    - template: jinja
    - user: {{ pillar.email.opendkim.user }}
    - group: {{ pillar.email.opendkim.group }}
    - mode: 775
    - require: 
      - file: {{ pillar.email.opendkim.directory }}

{{ pillar.email.opendkim.trusted_hosts_file }}:
  file.managed:
    - source: salt://email/trusted-hosts
    - user: {{ pillar.email.opendkim.user }}
    - group: {{ pillar.email.opendkim.group }}
    - mode: 775
    - require: 
      - file: {{ pillar.email.opendkim.directory }}

{{ pillar.email.opendkim.key_table_file }}:
  file.managed:
    - source: salt://email/key-table
    - template: jinja
    - user: {{ pillar.email.opendkim.user }}
    - group: {{ pillar.email.opendkim.group }}
    - mode: 775
    - require: 
      - file: {{ pillar.email.opendkim.directory }}

{{ pillar.email.opendkim.signing_table_file }}:
  file.managed:
    - source: salt://email/signing-table
    - template: jinja
    - user: {{ pillar.email.opendkim.user }}
    - group: {{ pillar.email.opendkim.group }}
    - mode: 775
    - require: 
      - file: {{ pillar.email.opendkim.directory }}

# OpenDKIM keys
{{ pillar.email.opendkim.keys_directory }}:
  file.directory:
    - user: {{ pillar.email.opendkim.user }}
    - group: {{ pillar.email.opendkim.group }}
    - file_mode: 775
    - dir_mode: 775
    - require:
      - file: {{ pillar.email.opendkim.directory }}

{% for host in pillar['email']['hosts'] %}

{% set key_dir = pillar['email']['opendkim']['keys_directory'] + '/' + host %}

{{ key_dir }}:
  file.directory:
    - user: {{ pillar.email.opendkim.user }}
    - group: {{ pillar.email.opendkim.group }}
    - file_mode: 775
    - dir_mode: 775
    - require:
      - file: {{ pillar.email.opendkim.keys_directory }}

{{ key_dir }}/mail.private:
  file.managed:
    - source: salt://email-secret/{{ host | replace(".", "-") }}.private
    - user: {{ pillar.email.opendkim.user }}
    - group: {{ pillar.email.opendkim.group }}
    - mode: 775
    - require:
      - file: {{ key_dir }}

{{ key_dir }}/mail.txt:
  file.managed:
    - source: salt://email-secret/{{ host | replace(".", "-") }}.txt
    - user: {{ pillar.email.opendkim.user }}
    - group: {{ pillar.email.opendkim.group }}
    - mode: 775
    - require:
      - file: {{ key_dir }}

{% endfor %}

# Postfix service
{{ postfix_svc }}-enabled:
  service.enabled:
    - name: {{ postfix_svc }}
    - require:
      - file: {{ pillar.email.postfix.config_file }}
      - file: {{ pillar.email.aliases_file }}
      - group: {{ pillar.email.opendkim.group }}-group

{{ postfix_svc }}-running:
  service.running:
    - name: {{ postfix_svc }}
    - watch:
      - file: {{ pillar.email.postfix.config_file }}
    - require:
      - service: {{ postfix_svc }}-enabled

# OpenDKIM service
{{ opendkim_svc_dir }}:
  file.directory:
    - mode: 755

{{ opendkim_svc_file }}:
  file.managed:
    - source: salt://email/opendkim-run
    - mode: 755
    - template: jinja

{{ opendkim_svc }}-enabled:
  service.enabled:
    - name: {{ opendkim_svc }}
    - require:
      - file: {{ opendkim_svc_file }}

{{ opendkim_svc }}-running:
  service.running:
    - name: {{ opendkim_svc }}
    - require:
      - service: {{ opendkim_svc }}-enabled
    - watch:
      - file: {{ pillar.email.opendkim.directory }}/*
