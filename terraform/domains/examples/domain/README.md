# Domains Example
Shows how the Domain module can be used.

# Table Of Contents
- [Overview](#overview)

# Overview
Shows how `example.com` domain could be setup with the features:

- Web traffic would be forwarded to a virtual machine on DigitalOcean
- Keybase DNS TXT verification would be created
- Email would be configured to with some spam and ownership records
  - These settings are not meant to show a proper SPF, DKIM, and DMARC setup
  - The `spf` property will default to a "no email sent from this domain" policy if unset, and will still be created if `mx` is not provided
  - Properties which are arrays should have exactly the right length, as shown, due to the opinionated way this module is written
  - The `mx` property should have only 2 items, which are the hosts of the email provider. If it is empty or not provided then email records (expect for SPF) will not be created
  - The `dkim` property should container 3 items, which are tuples in the form `[Record name, value]`
  - The `dmarc` property should tell email servers what to do with spam reports
  - The `protonmail_verification` property is required for ProtonMail, my email provider, to know you own the domain
