# List of objects which users state will configure users with
#
# Each object follows the following schema:
#
#   - name (String): Login name
#   - groups (String[]): List of group names which user should be added to
#       - wheel: Group allows users to run sudo
#   - public_key (String): User's public key which will be added to their 
#                          accounts authorized_keys file
#   - zsh_units (String[]): Names of Zsh profile files which will be copied to
#                           a user's ~/.zprofile.d directory. These files will
#                           be sourced when the user starts a Zsh shell.
#     
#                           See salt/users/zprofile.d for available file names.
#
#                           Or write 'all' instead of a list to include all of 
#                           the files.
#
users:
  - name: noah
    groups:
      - wheel
      - socklog
      - salt
    public_key: >-
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH7worAdtOa+cq2AuyFBdvbX+8Zy4zcHRChFb4EerKGX noah@katla
    zsh_units: all
  - name: jeff
    groups:
      - socklog
    public_key: >-
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMi4PzldEs2YCb1kZFiEeTcC5Ck4VBXHHJQVr0UanZ3L jeff@jeff-pc
    zsh_units: all
