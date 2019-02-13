{% set opendkim_dir = '/etc/opendkim' %}
email:
  postfix: 
    config_file: /etc/postfix/main.cf
  opendkim:
    user: opendkim
    group: opendkim
    directory: {{ opendkim_dir }}
    keys_directory: {{ opendkim_dir }}/keys
    config_file: {{ opendkim_dir }}/opendkim.conf
    trusted_hosts_file: {{ opendkim_dir }}/trusted-hosts
    key_table_file: {{ opendkim_dir }}/key-table
    signing_table_file: {{ opendkim_dir }}/signing-table
    run_directory: /var/run/opendkim
  hosts:
    - funkyboy.zone
  aliases_file: /etc/aliases
