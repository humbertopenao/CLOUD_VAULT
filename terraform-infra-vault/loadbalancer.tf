module "elb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "5.9.0"

  name_prefix                = "vault"
  load_balancer_type         = "network"
  vpc_id                     = module.network.vpc_id
  subnets                    = module.network.public_subnets
  enable_deletion_protection = false
  idle_timeout               = 60
  internal                   = var.internal_lb
  ip_address_type            = "ipv4"
  tags                       = var.tags

  target_groups = [
    {
      name_prefix      = "vault"
      backend_protocol = "TCP"
      backend_port     = var.vault_port
      target_type      = "instance"

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/v1/sys/health"
        port                = var.vault_port
        healthy_threshold   = 2
        unhealthy_threshold = 2
        protocol            = "HTTPS"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = var.vault_port
      protocol           = "TCP"
      target_group_index = 0
    }
  ]
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
  count            = length(module.ec2_vault.private_ip)
  target_group_arn = module.elb.target_group_arns[0]
  target_id        = module.ec2_vault.id[count.index]
  port             = var.vault_port
  depends_on       = [module.ec2_vault]
}
