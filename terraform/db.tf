resource "aws_db_subnet_group" "whc" {
  name       = "whc_rds"
  subnet_ids = aws_aws_subnet.public.*.id

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

resource "aws_db_instance" "whc" {
  allocated_storage           = 5
  storage_type                = "standard"
  db_name                     = "whc"
  identifier                  = "whc"
  engine                      = "postgresql"
  engine_version              = "16.4"
  instance_class              = "db.t4g.medium"
  manage_master_user_password = true
  username                    = "postgres"
  availability_zone           = [var.availability_zones[1]]
  vpc_security_group_ids      = [aws_security_group.whc_rds.id]
  db_subnet_group_name        = aws_db_subnet_group.whc.name
  multi_az                    = false
}
