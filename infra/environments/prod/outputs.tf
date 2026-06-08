output "frontend_url" { value = module.frontend.website_url }
output "cdn_domain"   { value = module.frontend.cdn_domain }
output "alb_dns"      { value = module.loadbalancer.alb_dns }
output "db_endpoint"  { value = module.database.db_endpoint }
output "redis_url"    { value = module.cache.redis_url }
