terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" {
    bucket         = "tf-state-appointease-prod-208179291544"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "tf-locks-appointease-prod"
    encrypt        = true
  }
}

provider "aws" {
  region = "ap-south-1"
}

module "networking" {
  source               = "../../modules/networking"
  project              = var.project
  env                  = "prod"
  vpc_cidr             = "10.4.0.0/16"
  public_subnet_cidrs  = ["10.4.1.0/24", "10.4.2.0/24"]
  private_subnet_cidrs = ["10.4.10.0/24", "10.4.11.0/24"]
  availability_zones   = ["ap-south-1a", "ap-south-1b"]
  app_port             = 8000
}

module "frontend" {
  source     = "../../modules/frontend"
  project    = var.project
  env        = "prod"
  enable_cdn = true
}

module "loadbalancer" {
  source            = "../../modules/loadbalancer"
  project           = var.project
  env               = "prod"
  alb_sg_id         = module.networking.alb_sg_id
  public_subnet_ids = module.networking.public_subnet_ids
  vpc_id            = module.networking.vpc_id
  app_port          = 8000
}

module "database" {
  source            = "../../modules/database"
  project           = var.project
  env               = "prod"
  subnet_ids        = module.networking.private_subnet_ids
  security_group_id = module.networking.rds_sg_id
  instance_class    = "db.t3.small"
  storage           = 100
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
}

module "cache" {
  source            = "../../modules/cache"
  project           = var.project
  env               = "prod"
  subnet_ids        = module.networking.private_subnet_ids
  security_group_id = module.networking.redis_sg_id
  node_type         = "cache.t3.small"
}

module "compute" {
  source              = "../../modules/compute"
  project             = var.project
  env                 = "prod"
  ami_id              = var.ami_id
  instance_type       = "t3.medium"
  security_group_id   = module.networking.compute_sg_id
  subnet_ids          = module.networking.private_subnet_ids
  asg_desired         = 2
  asg_min             = 2
  asg_max             = 10
  target_group_arn    = module.loadbalancer.target_group_arn
  repo_url            = "https://github.com/gautam-oss/AppointEase.git"
  database_url        = "postgresql+asyncpg://${var.db_username}:${var.db_password}@${module.database.db_address}:5432/${var.db_name}"
  redis_url           = module.cache.redis_url
  secret_key          = var.secret_key
  smtp_user           = var.smtp_user
  smtp_pass           = var.smtp_pass
  razorpay_key_id     = var.razorpay_key_id
  razorpay_key_secret = var.razorpay_key_secret
  frontend_url        = "https://${module.frontend.cdn_domain}"
  backend_url         = "https://${module.loadbalancer.alb_dns}"
}

module "billing" {
  source      = "../../modules/billing"
  project     = var.project
  alert_email = var.alert_email
}
