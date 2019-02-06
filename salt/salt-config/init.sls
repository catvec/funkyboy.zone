# Configures the Salt master to find Salt states in:
#
#   - /srv/salt
#   - /srv/salt-secrets
#
# And pillars in:
#
#   - /srv/pillar
#   - /srv/pillar-secrets
#
# This is where the scripts in this repository will upload the latest 
# Salt files.

/etc/salt/master:
  file.managed:
    - source: salt://salt-config/master
    - mode: 664
