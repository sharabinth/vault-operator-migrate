storage_source "consul" {
  address = "10.100.1.11:8500"
  path    = "vault"
}

storage_destination "consul" {
  address = "198.100.1.13:8500"
  path    = "vault"
}