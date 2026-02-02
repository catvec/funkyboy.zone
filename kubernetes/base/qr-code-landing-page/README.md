# QR Code Landing Page
- [Setup](#setup)

# Setup
Make a copy of the following `.env` configuration files and fill in your own values (Remove `.example` from the name when making a copy):

- `conf/postgres.example.env`
- `conf/app-config.example.env`
- `conf/app-secret.example.env`

## Google OAuth (Optional)
If you want to enable Google Sign-In, configure the following in your config files:

1. Create OAuth credentials at https://console.cloud.google.com/apis/credentials
2. Add redirect URI: `https://qr.k8s.funkyboy.zone/accounts/google/login/callback/`
3. Set `GOOGLE_OAUTH_CLIENT_ID` in `conf/app-config.env`
4. Set `GOOGLE_OAUTH_SECRET` in `conf/app-secret.env`

# Todo
- Setup PG backups
