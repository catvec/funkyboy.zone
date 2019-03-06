base:
  '*':
    # Low level system configuration
    - system-config
    - hostname

    # System daemons
    - syslog
    - ufw
    - crond

    # User setup
    - zsh
    - docker
    - users

    # Tools
    - rm-container-script
    - digitalocean-spaces
    - digitalocean-spaces-secret
    - s3cmd
    - s3fs
    - vsv
    - prometheus-push-cli

    # Services
    - backup
    - email
    - email-secret
    - caddy
    - caddy-secret
    - prometheus
    - prometheus-secret
    - alertmanager
    - alertmanager-secret
    - grafana 
    - node-exporter
    - pushgateway
    - void-scripts
    - znc-secret
    - znc
    - factorio
    - factorio-secret
    - public-www
    - linux-install-repo
