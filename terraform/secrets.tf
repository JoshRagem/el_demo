resource "random_password" "el_secret_key_base" {
  length  = 64
  special = false
  numeric = true
  upper   = true
  lower   = true
}
resource "random_password" "el_pg_password" {
  length  = 64
  special = false
  numeric = true
  upper   = true
  lower   = true
}

resource "aws_secretsmanager_secret" "el_secret_key_base" {
  name                    = "el-demo-secret-key-base"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "el_secret_key_base" {
  secret_id     = aws_secretsmanager_secret.el_secret_key_base.id
  secret_string = random_password.el_secret_key_base.result
}

resource "aws_secretsmanager_secret" "el_db_url" {
  name                    = "el-db-url"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "el_db_url" {
  secret_id = aws_secretsmanager_secret.el_db_url.id
  secret_string = "ecto://el:${random_password.el_pg_password.result}@${aws_db_instance.whc.address}/whc"
}