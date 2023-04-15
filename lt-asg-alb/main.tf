// Get default VPC
data "aws_vpc" "default-vpc" {
  default = "true"
}

// Get all subnets id from default VPC for APL
data "aws_subnets" "default-subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default-vpc.id]
  }
}

// Get security group from default VPC for APL
data "aws_security_group" "default-security-group" {
  vpc_id = data.aws_vpc.default-vpc.id
}

resource "aws_launch_template" "terraform_launch_template" {
  name        = "terraform_launch_template"
  description = "Created by terraform. Training infrastructure"

  image_id      = "ami-08f54b258788948e1"
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
  }

  key_name  = "ec2"
  user_data = filebase64("webserver.sh")

  tags = {
    project = "training_terraform"
  }
}

resource "aws_lb_listener" "terraform-listener" {
  load_balancer_arn = aws_lb.terraform-application-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.terraform-target-group.arn
  }
}

resource "aws_lb_target_group" "terraform-target-group" {
  name     = "terraform-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default-vpc.id
  health_check {
    path                = "/"
    port                = 80
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    project = "training_terraform"
  }
}

resource "aws_lb" "terraform-application-lb" {
  name               = "terraform-application-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.default-security-group.id]
  subnets            = data.aws_subnets.default-subnets.ids

  enable_deletion_protection = true

  tags = {
    project = "training_terraform"
  }
}

resource "aws_autoscaling_policy" "terraform_autoscaling_policy" {
  name                   = "terraform_autoscaling_policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.terraform_autoscaling_group.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 10.0 // so small for testing policy
  }
}

resource "aws_autoscaling_group" "terraform_autoscaling_group" {
  availability_zones = ["eu-central-1a", "eu-central-1b"]
  desired_capacity   = 2
  max_size           = 3
  min_size           = 2
  default_cooldown   = 60
  target_group_arns  =  [aws_lb_target_group.terraform-target-group.arn]


  health_check_grace_period = 60
  health_check_type         = "ELB"

  force_delete = true

  launch_template {
    id      = aws_launch_template.terraform_launch_template.id
    version = "$Latest"
  }
}