znc:
  directory: /etc/znc
  config_file: configs/znc.conf
  caddy:
    host: znc.funkyboy.zone
    config_file: znc
  ports:
    internal_web: 6668
    irc: 6697
  pem_file: znc.pem
  users:
    noah:
      nick: noah_h
      quit_msg: o/
      real_name: n/a
      networks:
        - server: chat.freenode.net +6697
          channels:
            - "#salt"
            - "#voidlinux"
            - "#xbps"
