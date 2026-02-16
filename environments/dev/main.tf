module "networking" {
  source       = "../../modules/networking"
  project_name = var.project_name
  location     = var.location
}

module "vm" {
  source = "../../modules/vm"

  project_name        = var.project_name
  resource_group_name = module.networking.resource_group_name
  location            = var.location
  subnet_id           = module.networking.subnet_id
  public_ip_id        = module.networking.public_ip_id
  vm_size             = var.vm_size
  vm_zone             = var.vm_zone
}