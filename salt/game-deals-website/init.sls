# Clone down coming soon page for oliversgame.deals
{{ pillar.game_deals_website.repository }}:
  git.latest:
    - target: {{ pillar.caddy.serve_dir }}/{{ pillar.caddy.static_sites.game_deals.www_dir }}
    - branch: {{ pillar.game_deals_website.branch }}
    - user: caddy
    - rev: {{ pillar.game_deals_website.rev }}
    - force_reset: True
