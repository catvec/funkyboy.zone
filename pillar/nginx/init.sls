nginx:
  service_dir: /srv/nginx
  html_dir: html
  config_dir: /etc/nginx/sites-enabled
  files:
    user: nginx
    group: nginx
    mode: 775
