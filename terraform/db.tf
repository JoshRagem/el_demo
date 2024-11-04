resource "aws_db_subnet_group" "whc" {
  name       = "whc_rds"
  subnet_ids = aws_subnet.public.*.id

  tags = {
    Name = "whc_rds"
  }
}

resource "aws_security_group" "whc_rds" {
  name_prefix = "whc_rds."
  description = "Security group for whc rds instance"
  vpc_id      = aws_vpc.el_demo.id

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_security_group" "vpc_default" {
  vpc_id = aws_vpc.el_demo.id
  name   = "default"
}

resource "aws_security_group_rule" "el_demo_api_ingress" {
  type                     = "ingress"
  description              = "DB ingress from demo api"
  source_security_group_id = aws_security_group.api.id
  security_group_id        = aws_security_group.whc_rds.id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
}

resource "aws_db_instance" "whc" {
  apply_immediately           = true
  publicly_accessible = true
  allocated_storage           = 5
  storage_type                = "standard"
  storage_encrypted           = true
  identifier                  = "whc"
  engine                      = "postgres"
  engine_version              = "16.4"
  instance_class              = "db.t4g.medium"
  manage_master_user_password = true
  username                    = "postgres"
  availability_zone           = var.availability_zones[0]
  vpc_security_group_ids      = [aws_security_group.whc_rds.id, data.aws_security_group.vpc_default.id]
  db_subnet_group_name        = aws_db_subnet_group.whc.name
  multi_az                    = false
}
