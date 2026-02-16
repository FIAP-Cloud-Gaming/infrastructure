module "networking" {
  source       = "../../modules/networking"
  project_name = var.project_name
  location     = var.location
}