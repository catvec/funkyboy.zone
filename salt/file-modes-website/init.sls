# Hosts a website with Nginx which shows useful information about Linux 
# file permissions.

{{ pillar.nginx.html_dir }}/{{ pillar.file_modes_website.html_dir }}:
  file.recurse:
    - source: salt://file-modes-website/html
    - user: {{ pillar.nginx.files.user }}
    - group: {{ pillar.nginx.files.group }}
    - dir_mode: {{ pillar.nginx.files.mode }}
    - file_mode: {{ pillar.nginx.files.mode }}

{{ pillar.nginx.config_dir }}/{{ pillar.file_modes_website.config_file }}:
  file.managed:
    - source: salt://file-modes-website/nginx.conf
    - template: jinja
