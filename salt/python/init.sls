# Installs Python 2 & 3. Along with virtualenv.

python:
  pkg.installed

python-pip:
  pkg.installed

pipenv:
  pip.installed:
    - pip_bin: /usr/bin/pip3
    - require:
      - pkg: python-pip
