# List of objects which users state will configure users with
#
# Each object follows the following schema:
#
#   - name (String): Login name
#   - groups (String[]): List of group names which user should be added to
#       - wheel: Group allows users to run sudo
#   - public_key (String): User's public key which will be added to their 
#                          accounts authorized_keys file
#
users:
  - name: noah
    groups:
      - wheel
      - socklog
    public_key: >-
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH7worAdtOa+cq2AuyFBdvbX+8Zy4zcHRChFb4EerKGX noah@katla
  - name: jeff
    groups:
      - socklog
    public_key: >-
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMi4PzldEs2YCb1kZFiEeTcC5Ck4VBXHHJQVr0UanZ3L jeff@jeff-pc
