resource "digitalocean_droplet" "funkyboy_zone" {
  name = "funkyboy.zone"
  region = "nyc1"
  image = data.digitalocean_image.void_linux.image
  size = "s-1vcpu-2gb"
  ssh_keys = [
    data.digitalocean_ssh_key.katla.fingerprint
  ]
  backups = true
}
