# Clones down a local version of the void-packages repository so packages can
# be built locally.

{{ pillar.void_packages_repo.repo }}:
  git.latest:
    - target: {{ pillar.void_packages_repo.directory }}
    - branch: {{ pillar.void_packages_repo.branch }}
