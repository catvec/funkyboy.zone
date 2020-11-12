# List of objects which users state will configure users with
#
# Each object follows the following schema:
#
#   - name (String): Login name
#   - groups (String[]): List of group names which user should be added to
#       - wheel: Group allows users to run sudo
#   - authorized_keys (String): Public keys which can SSH into account
#   - ssh_key (String): (Optional) Name of SSH key file without extension. 
#                       Files with name ~/.ssh/ssh_key{,.pub} will placed on
#                       the server. These files will be sourced from the 
#                       keys/name directory in the ssh-secret state.
#   - zsh_units (String[]): Names of Zsh profile files which will be copied to
#                           a user's ~/.zprofile.d directory. These files will
#                           be sourced when the user starts a Zsh shell.
#     
#                           See salt/users/zprofile.d for available file names.
#
#                           Or write 'all' instead of a list to include all of 
#                           the files.
#
users_nologin_shell: /sbin/nologin
users:
  - name: root
    zsh_units: all
  - name: noah
    groups:
      - wheel
      - socklog
      - salt
      - docker
      - factorio-mods
      - factorio-admin
      - s3cmd
    authorized_keys: >-
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH7worAdtOa+cq2AuyFBdvbX+8Zy4zcHRChFb4EerKGX noah@katla
    ssh_key: id_ed25519
    zsh_units: all
  - name: jeff
    groups:
      - socklog
    authorized_keys: >-
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMi4PzldEs2YCb1kZFiEeTcC5Ck4VBXHHJQVr0UanZ3L jeff@jeff-pc
    zsh_units: all
  - name: zach
    groups:
      - socklog
      - factorio-mods
      - factorio-admin
    authorized_keys: >-
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFqsP4F+7j3DPPezHqrAO6xmRzr7s9Wi6qYpuq3od/CrMkVl6oTrOmPvwn6H473YRyesDTW6lkfUR1k00InybeFiW8embKXsU5voqj9w7lTT+1yTnjyoLK95jkYwg9FK0eKeAZ9K8pkFOJE9owirWghDG74TgAmYIBMI4w62MGza30wALNrTClUIONdMeVPIL3djev+CsYT3UIjybXlwalYUtoWsoaOCgFkprs4GZ6JEb6CGMpgdDMDRWF6/yp9qrUx/5wcItwCdgp7H3QCVfzcLdHuTUINaOisRfF/MJ5etunhdEONQsOtbq+nAU2c3AbacJY7f0E4Rrc9wf2+18d Zacharie Day
    zsh_units: all
  - name: chris
    groups:
      - socklog
    authorized_keys: >-
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAiXbgdFfrO9J7f7FD2qe4AuDVryo7MVhtcavsF09riHs3PjZsYnulH14ySOxxxqn1jgnBd47otoI3cEyKj3v2Ypo/kxVtuqlvqKakpYxmSAcH/i5AuojWtzWXOzdNOrZxVlcuT/653bShnrBDVNLbdBOnZBW0WFSG7cV6ICvr7H+edTAsnZ5iXu8P2AMxu3BtacBRrJcd6T9itsRtFu2llhH2JTVMSXLtBeg54+8Fpk3mKiLdW2fucbyuBtIXaQeh+cpmyE0Me51KbRwOaZWGGLKZgZHGeD50RuaU7ZLL73vpRZEUf1MVyUGl5CVmp3h+9yEJxrtIpb6gyjeQSK23 chrisae9@penguin
    zsh_units: all
  - name: tyler
    groups:
      - socklog
      - factorio-mods
      - factorio-admin
    authorized_keys: >-
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDkxXpd/7Um7XqNmSNaVd5Ni4Iity6lEToCiKbNSbIBJhRq1YJmKCXdjQUCfYXvR3OeDF58cdVab4RZqZxD9qc4AwhIZ3QikMe71bqWuYIZltgZ3ha/cCoYxWrq/xAjVsGwLL2S4HU5QpaKVNu14f6QeLI5QOLORTjJDsGv3kQ8hdLmbFIK3DF8QUWF4uZvphhCZ5R4mpVw+Gyr/z6fJwIuwxPPOaTNv53KTve3ihPKUjmBNe0L6MlwM/iBw9Z/sbYvHER+t0D35XfqwcfRkcQh+9UrFYQxTUe1USOsEjIJUYA1d1s6F0va6BgxeqMoRLHlIkGf7zIsGlMBwSXadqR3dKLEZACWNBuTTJS9ZSvgeA1ge3/oHn3xdXkWegqTSLvqFX7MJ2eh9VE6wrPAIShMPpWdsWgdq+PrZ+uWDir1a+8FDuFUfk5gD2VMe3pqkct0koaD2ED9C0iniVFyHBZ6rEaf7yoBdBA2Khj3SESN89zLz2ewdjJfEKDL+eamnV9z9hrPtRTn2QFYQ7rdZa9/UFqOIW+0IEAgXhaLcY7tghF5uxL0zCIGBAQYuklSmUv56cbbrhLT0at8nzTKbJ0eIm9WcoUhni/oXP4Q8uIp5vXIKxBBpmY6YEaSooNlBF2rzp5TUoSPxHZHEfU7naLQsjR52GIIF0h7JMPb2l0hvw== tchar@DESKTOP-NIIA71T
    zsh_units: all
  - name: matt
    groups:
      - socklog
      - factorio-mods
      - factorio-admin
    authorized_keys: >-
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDvm5JxUdmriau0Vo2E1TJXCx5A2WocosWFQYltwWpm15v8mBvYivm6Y9sEZFc2UkLo6+i58nIn/noYuZQbF8su9O4sqchUduRes2Cm+FlDUF+h0+9FvpKep6EoR8W3SEsjaMr24y12R5RuZBY9Hm+34UtLjik/K+JhyglIZXZEdGewDP8ESn+PBYn8m4h+JRhAapuPZxNbxBPLDTmqu8aVUstLMkLxQQ3BsDA+TATKuDcuTjlr4ebHeEQduhYJMNe/O10wmjK2/KRnkup9cBhiMVsWthheiseIw4d0ZxhlzUA0DIZapqCPk9lgV/LUvGBGUgOOFE48LP/U2ByZFEqYcqtCUOy2tybnuniE5/UY905WaAnd3gbS7uHoVmS3laY/UUadNknlMeVduBMgJD8JyfRgXKcz321pbtJoeZKERRrpNl3pB9yqDTAOxCyIxlwVqwncW1+u8+jScbw5YvDMFGnVLjgd9zqDDgqh3cObTFTVLvjretJ1IE/qb5UHMF8xHCXu4GX5KeK1eVmn2gLms+qmKNLwgXQzSkfl/invfpjJ5sZ/XASZr/hvnPQ1dmilv4wgmRMBIl73PRMIOWbZ4NPwOstAJ5+IJil85qh36j6wqHRBN/zvVaEDjgMBZDIVAuc0FLdvXGF/oNAcPVj+mi20dxPw4gpIgnPBYU6WZw== Matthew Oslan (derpthemeus@gmail.com)
    zsh_units: all
