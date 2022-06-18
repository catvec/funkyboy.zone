# Install git.

# Package
git:
  pkg.installed

# User configuration
/home/noah/.gitconfig:
  file.managed:
    - source: salt://git/noah-gitconfig
    - template: jinja
    - user: noah
    - group: noah
    - mode: 644

/root/.gitconfig:
  file.managed:
    - source: salt://git/root-gitconfig
    - template: jinja
    - user: root
    - group: root
    - mode: 644
