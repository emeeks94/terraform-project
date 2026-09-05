resource "aws_lb" "freshcart" {
  name               = "${var.environment}-freshcart-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    module.security.alb_security_group_id
  ]

  subnets = [
    module.network.public_subnet_a_id,
    module.network.public_subnet_b_id
  ]

  tags = {
    Name        = "${var.environment}-freshcart-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "freshcart" {
  name     = "${var.environment}-freshcart-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.network.vpc_id

  target_type = "instance"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = {
    Name        = "${var.environment}-freshcart-tg"
    Environment = var.environment
  }
}

resource "aws_lb_target_group_attachment" "backend" {
  target_group_arn = aws_lb_target_group.freshcart.arn
  target_id        = aws_instance.backend.id
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.freshcart.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    target_group_arn = aws_lb_target_group.freshcart.arn
  }
}
