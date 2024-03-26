# Disable discord-azure-boot bot, which is now hosted via Kubernetes

# Ensure doesn't run service
{{ pillar.discord_azure_boot.svc }}-disabled:
  service.disabled:
    - name: {{ pillar.discord_azure_boot.svc }}

{{ pillar.discord_azure_boot.svc }}-dead:
  service.dead:
    - name: {{ pillar.discord_azure_boot.svc }}
