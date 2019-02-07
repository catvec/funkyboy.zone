# Hosts a website with Nginx which shows useful information about Linux 
# file permissions.

{{ pillar.caddy.serve_dir }}/{{ pillar.file_modes_website.www_dir }}:
  file.recurse:
    - source: salt://file-modes-website/html
