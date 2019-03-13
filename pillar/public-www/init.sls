{% set ensure_access_svc = 'public-www-ensure-access' %}
public_www:
  # Shorter easier to remember symbolic link to Caddy serve directory
  shortcut_directory: /public

  # Details about ensure-access invocation. Used to ensure that Caddy can 
  # access files placed by users
  ensure_access:
    # Name of service
    service: {{ ensure_access_svc }}
    service_directory: /etc/sv/{{ ensure_access_svc }}

    # Minimum mode required for each file and directory
    mode: "005"

    # Poll interval in seconds of how often ensure-access should run
    poll: 10

  # Users which shouldn't have a public directory
  excluded_users:
    - root
