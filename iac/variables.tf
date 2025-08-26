variable "resource_group_location" {
  default     = "francecentral"
  description = "Localisation géographique du groupe de ressources"
}
variable "node_count" {
  default     = 3
  description = "Quantité initiale de nœuds pour la réserve (pool)"
}


locals {
  cname_domains = ["todolist", "grafana"]
}

variable "ovh_application_key" {
  description = "OVH API Application Key"
}
variable "ovh_application_secret" {
  description = "OVH API Application Secret"
}
variable "ovh_consumer_key" {
  description = "OVH API Consumer Key"
}
