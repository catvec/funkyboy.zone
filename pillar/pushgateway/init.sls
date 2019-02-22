{% set svc_name = 'pushgateway' %}
{% set svc_dir = '/etc/sv/' + svc_name %}
{% set port = 9091 %}

pushgateway:
  docker_image: prom/pushgateway
  docker_container_name: pushgateway
  port: {{ port }}
  host: localhost:{{ port }}
  service:
    name: {{ svc_name }}
    directory: {{ svc_dir }}
    run_file: {{ svc_dir }}/run
    finish_file: {{ svc_dir }}/finish
