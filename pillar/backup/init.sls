{% set scripts_dir = '/opt/backup' %}

backup:
  user: backup
  group: backup
  mode: 775
  device: /dev/disk/by-id/scsi-0DO_Volume_funkyboy-zone-backup
  mount_point: /backup
