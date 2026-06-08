terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" {
    bucket         = "tf-state-appointease-dev-208179291544"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "tf-locks-appointease-dev"
    encrypt        = true
    profile        = "dev"
  }
}

provider "aws" {
  region  = "ap-south-1"
  profile = "dev"
}

module "networking" {
  source               = "../../modules/networking"
  project              = var.project
  env                  = "dev"
  vpc_cidr             = "10.3.0.0/16"
  public_subnet_cidrs  = ["10.3.1.0/24", "10.3.2.0/24"]
  private_subnet_cidrs = ["10.3.10.0/24", "10.3.11.0/24"]
  availability_zones   = ["ap-south-1a", "ap-south-1b"]
  app_port             = 8000
}

module "frontend" {
  source     = "../../modules/frontend"
  project    = var.project
  env        = "dev"
  enable_cdn = false
}

module "loadbalancer" {
  source            = "../../modules/loadbalancer"
  project           = var.project
  env               = "dev"
  alb_sg_id         = module.networking.alb_sg_id
  public_subnet_ids = module.networking.public_subnet_ids
  vpc_id            = module.networking.vpc_id
  app_port          = 8000
}

module "database" {
  source            = "../../modules/database"
  project           = var.project
  env               = "dev"
  subnet_ids        = module.networking.private_subnet_ids
  security_group_id = module.networking.rds_sg_id
  instance_class    = "db.t3.micro"
  storage           = 20
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
}

module "cache" {
  source            = "../../modules/cache"
  project           = var.project
  env               = "dev"
  subnet_ids        = module.networking.private_subnet_ids
  security_group_id = module.networking.redis_sg_id
  node_type         = "cache.t3.micro"
}

module "compute" {
  source              = "../../modules/compute"
  project             = var.project
  env                 = "dev"
  ami_id              = var.ami_id
  instance_type       = "t3.small"
  security_group_id   = module.networking.compute_sg_id
  subnet_ids          = module.networking.private_subnet_ids
  asg_desired         = 1
  asg_min             = 1
  asg_max             = 1
  target_group_arn    = module.loadbalancer.target_group_arn
  repo_url            = "https://github.com/gautam-oss/AppointEase.git"
  database_url        = "postgresql+asyncpg://${var.db_username}:${var.db_password}@${module.database.db_address}:5432/${var.db_name}"
  redis_url           = module.cache.redis_url
  secret_key          = var.secret_key
  smtp_user           = var.smtp_user
  smtp_pass           = var.smtp_pass
  razorpay_key_id     = var.razorpay_key_id
  razorpay_key_secret = var.razorpay_key_secret
  frontend_url        = "http://${module.frontend.website_url}"
  backend_url         = "http://${module.loadbalancer.alb_dns}"
}

module "billing" {
  source      = "../../modules/billing"
  project     = var.project
  alert_email = var.alert_email
}
