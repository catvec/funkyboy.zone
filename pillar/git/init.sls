git:
  # Git now doesn't let you clone into directories that aren't owned by you sometimes, so we need to explicitly allow them via the .gitconfig file. This will populate the user Salt runs as's .gitconfig.
  safe_dirs:
    - /srv/caddy/noahhuppert
