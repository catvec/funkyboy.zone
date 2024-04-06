# Domain name
module "domains" {
  name = "example.com"
  
  target = digitalocean_droplet.web.ipv4_address
  
  keybase_verification = "keybase-site-verification=ABC"

  # Email settings
  spf = "v=spf1 include:_spf.emailprovider.com mx ~all"
  mx = [
    "mx1.emailprovider.com",
    "mx2.emailprovider.com",
  ]
  dkim = [
    ["emailprovider1._domainkey", "abc1"],
    ["emailprovider2._domainkey", "abc2"],
    ["emailprovider3._domainkey", "abc3"],
  ]
  dmarc = "v=DMARC1; p=none; rua=mailto:webmaster@example.com"
  protonmail_verification = "abc"
}

# Example server
resource "digitalocean_droplet" "web" {
  image  = "ubuntu-18-04-x64"
  name   = "web-1"
  region = "nyc2"
  size   = "s-1vcpu-1gb"
}
