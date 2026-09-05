resource "aws_iam_instance_profile" "freshcart" {
  name = "${var.environment}-freshcart-instance-profile"
  role = "ECRPullPolicy"

  tags = {
    Name        = "${var.environment}-freshcart-instance-profile"
    Environment = var.environment
  }
}
