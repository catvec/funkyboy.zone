{% set source_name = 'mongodb-linux-x86_64-ubuntu2004-4.4.0' %}

mongodb:
  dir: /opt/mongodb

  source_name: {{ source_name }}
  source_url: https://fastdl.mongodb.org/linux/{{ source_name }}.tgz
  source_sha256sum: e9054fb822b415945926b5875636ada50c46e0716ea0cbb82e2919e3f7912737

  bin_dir: /usr/local/bin
  bin_links:
    - mongo
    - mongod
