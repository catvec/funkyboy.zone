# Runs the inject-log-service script which ensures that all (non system) 
# services are logging using vlogger to syslog

{{ pillar.inject_log_service.script_dir }}:
  file.directory

{{ pillar.inject_log_service.check_script_file }}:
  file.managed:
    - source: salt://inject-log-service/check-log-service-injected
    - mode: 755
    - require:
      - file: {{ pillar.inject_log_service.script_dir }}

{{ pillar.inject_log_service.inject_script_file }}-exists:
  file.managed:
    - name: {{ pillar.inject_log_service.inject_script_file }}
    - source: salt://inject-log-service/inject-log-service
    - mode: 755
    - require:
      - file: {{ pillar.inject_log_service.script_dir }}

#{{ pillar.inject_log_service.inject_script_file }}-run:
#  cmd.run:
#    - name: {{ pillar.inject_log_service.inject_script_file }}
#    - unless: {{ pillar.inject_log_service.check_script_file }}
