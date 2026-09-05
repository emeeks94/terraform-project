resource "aws_instance" "backend" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id = module.network.private_subnet_a_id

  vpc_security_group_ids = [
    module.security.ec2_security_group_id
  ]

  iam_instance_profile = aws_iam_instance_profile.freshcart.name

  associate_public_ip_address = false

  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/user-data.sh.tpl", {
    checkout_api_image = var.checkout_api_image
    storefront_image   = var.storefront_image
    db_init_sql        = file("${path.module}/../freshcart-terraform/checkout-api/db/init.sql")
  })

  tags = {
    Name        = "${var.environment}-freshcart-backend"
    Environment = var.environment
    Role        = "application-server"
  }
}
