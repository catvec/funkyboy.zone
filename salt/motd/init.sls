# Sets up a message of the day. The message of the day includes a cool ascii
# drawing of the server name (Made by Figlet) and the server's rules.

/etc/motd:
  file.managed:
    - source: salt://motd/motd
