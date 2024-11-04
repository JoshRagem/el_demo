
resource "aws_security_group" "alb" {
  name_prefix = "el_demo."
  description = "Security group for load balancer"

  vpc_id = aws_vpc.el_demo.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "alb_internet_access" {
  type              = "egress"
  description       = "Internet access"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = -1
}

resource "aws_security_group_rule" "internet_to_alb_https_ingress" {
  type              = "ingress"
  description       = "HTTPS ingress"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
}

# -----------------------------------------------------------------------------

resource "aws_lb" "el_demo" {
  name_prefix        = "eldemo"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]

  subnets = aws_subnet.public.*.id
}

resource "aws_lb_target_group" "el_demo_api" {
  name        = "el-demo-api"
  port        = 4000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.el_demo.id
  target_type = "ip"

  health_check {
    enabled = true
    path    = "/healthz"
    matcher = "200"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.el_demo.id
  port              = 443
  protocol          = "HTTPS"

  certificate_arn = aws_acm_certificate.el_demo.arn

  default_action {
    target_group_arn = aws_lb_target_group.el_demo_api.arn
    type             = "forward"
  }

  depends_on = [
    aws_acm_certificate_validation.el_demo
  ]
}


data "aws_route53_zone" "el_demo" {
  private_zone = false
  name = format(
    # Need to add a trailing dot
    "%s.",

    # Extract the last two parts from the domain name
    regex("[\\w-]+\\.[a-z]+$", var.domain_name)
  )
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.el_demo.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.el_demo.dns_name
    zone_id                = aws_lb.el_demo.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "el_demo" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "el_demo_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.el_demo.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  type    = each.value.type
  zone_id = data.aws_route53_zone.el_demo.zone_id
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "el_demo" {
  certificate_arn         = aws_acm_certificate.el_demo.arn
  validation_record_fqdns = [for record in aws_route53_record.el_demo_cert_validation : record.fqdn]
}
