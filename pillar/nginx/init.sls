{% set service_dir = '/srv/nginx' %}

nginx:
  service_dir: {{ service_dir }}
  html_dir: {{ service_dir}}/html
  config_dir: /etc/nginx/sites-enabled
  files:
    user: nginx
    group: nginx
    mode: 775
