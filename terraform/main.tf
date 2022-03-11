module "all_cloud" {
  source = "./modules/all-cloud"

  linux_server_ipv4 = digitalocean_droplet.funkyboy_zone.ipv4_address
}
