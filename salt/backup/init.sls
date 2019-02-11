# Install backup crond job.

{{ pillar.backup.group }}-group:
  group.present:
    - name: {{ pillar.backup.group }}

{{ pillar.backup.user }}-user:
  user.present:
    - name: {{ pillar.backup.user }}
    - createhome: False
    - groups:
      - {{ pillar.backup.group }}
    - require:
      - group: {{ pillar.backup.group }}-group

{{ pillar.backup.device }}:
  blockdev.formatted:
    - fs_type: ext4
