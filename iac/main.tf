data "azurerm_resource_group" "rg_areaute_k8s" {
  name = "rg-AReaute2024_cours-projet"
}
resource "azurerm_kubernetes_cluster" "k8s" {
  location            = data.azurerm_resource_group.rg_areaute_k8s.location
  resource_group_name = data.azurerm_resource_group.rg_areaute_k8s.name
  name                = "cluster-ar"
  dns_prefix          = "k8s-ar-noeud"
  identity {
    type = "SystemAssigned"
  }
  default_node_pool {
    name       = "worker"
    vm_size    = "Standard_B2S"
    node_count = var.node_count
  }
  network_profile {
    network_plugin = "kubenet"
    network_policy = "calico"
  }
  tags = {
    cours     = "cours-projet",
    promotion = "HASDO_001",
    user      = "AReaute2024"
  }

  lifecycle {
    ignore_changes = [default_node_pool]
  }
}

data "ovh_domain_zone" "areaute2024_ovh" {
  name = "areaute2024.ovh"
}

resource "ovh_domain_zone_record" "cluster-ar_areaute2024_ovh" {
  zone      = data.ovh_domain_zone.areaute2024_ovh.id
  subdomain = "cluster-ar"
  fieldtype = "A"
  target    = "4.178.237.82"
}

resource "ovh_domain_zone_record" "ing_areaute2024_ovh" {
  zone      = data.ovh_domain_zone.areaute2024_ovh.id
  subdomain = "ing"
  fieldtype = "A"
  target    = "4.178.237.82"
}

resource "ovh_domain_zone_record" "CNAME_areaute2024_ovh" {
  for_each = toset(local.cname_domains)

  zone      = data.ovh_domain_zone.areaute2024_ovh.name
  subdomain = each.value
  fieldtype = "CNAME"
  target    = "ing"
}

