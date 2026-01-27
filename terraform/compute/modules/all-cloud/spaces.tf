resource "digitalocean_spaces_bucket" "game_deals" {
  name   = "game-deals-storage"
  region = "nyc3"
  acl    = "private"
}

resource "digitalocean_spaces_key" "game_deals" {
  name = "game-deals"

  grant {
    bucket     = digitalocean_spaces_bucket.game_deals.name
    permission = "readwrite"
  }
}
