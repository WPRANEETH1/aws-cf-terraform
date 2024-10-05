# Define local variables for tags
locals {
  tags = {
    Project     = var.project,
    Environment = var.environment,
    VPCName     = join("-", [var.vpc_name, var.project, var.environment])
  }
  description = "Extra tags to billing/ organization policy"
}

# VPC module configuration
module "vpc_module" {
  source                     = "./modules/vpc"
  vpc_name                   = var.vpc_name
  environment                = var.environment
  project                    = var.project
  tags                       = local.tags
  region                     = var.region
  cidr_block_primary         = "192.168.0.0/16"
  public_subnet_cidr_blocks  = ["192.168.0.0/24", "192.168.1.0/24"]
  private_subnet_cidr_blocks = ["192.168.2.0/24", "192.168.3.0/24"]
  availability_zones_ref     = ["a", "b"]
  create_natgw               = true
}

# EC2 instance for SSM module configuration
module "ec2_ssm_module" {
  depends_on = [module.vpc_module]

  source                  = "./modules/ec2"
  vpc_name                = var.vpc_name
  vpc_id                  = module.vpc_module.output_vpc_id
  environment             = var.environment
  project                 = var.project
  tags                    = local.tags
  region                  = var.region
  ec2_name                = "ec2-ssm"
  security_groups_allowed = []
  instance_type           = "t2.medium"
  ec2_subnet              = module.vpc_module.output_public_subnets
  public_ip_address       = true
}

# MariaDB RDS module configuration
module "mariadb_module" {
  depends_on = [module.ec2_ssm_module]

  source                  = "./modules/mariadb"
  vpc_name                = var.vpc_name
  vpc_id                  = module.vpc_module.output_vpc_id
  environment             = var.environment
  project                 = var.project
  tags                    = local.tags
  region                  = var.region
  private_subnets         = module.vpc_module.output_private_subnets
  security_groups_allowed = [module.ec2_ssm_module.output_ec2_sg]
  username                = "admin"
  password                = "DevOps123"
}

# EC2 service module configuration
module "ec2_service_module" {
  depends_on = [module.mariadb_module]

  source        = "./modules/ec2-service"
  vpc_name      = var.vpc_name
  vpc_id        = module.vpc_module.output_vpc_id
  environment   = var.environment
  project       = var.project
  tags          = local.tags
  region        = var.region
  ec2_name      = "ec2-service"
  instance_type = "t2.medium"
  ec2_subnets   = module.vpc_module.output_private_subnets
  nlb_subnets   = module.vpc_module.output_public_subnets
  rds_endpoint  = module.mariadb_module.rds_endpoint
  mariadb_sg    = module.mariadb_module.mariadb_sg
}

# CDN (CloudFront) module configuration
module "cdn_module" {
  depends_on = [module.ec2_service_module]

  source      = "./modules/cdn"
  bucket_name = "website-bucket-01"
  tags        = local.tags
  dns_name    = module.ec2_service_module.output_nlb_dns_name
}

# Output for CloudFront URL
output "cloudfront_url" {
  description = "The URL of the CloudFront distribution"
  value       = "https://${module.cdn_module.cloudfront_url}"
}

# Output for EC2 service URL through CloudFront
output "ec2_service_url" {
  description = "The URL of the EC2 Server through CloudFront distribution"
  value       = "https://${module.cdn_module.cloudfront_url}/api/"
}


