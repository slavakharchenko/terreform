module "training_terraform_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.1"

  name = "training_terraform_vpc"
  cidr = "10.0.0.0/24"

  azs             = ["eu-central-1a", "eu-central-1b"]
  private_subnets = ["10.0.0.0/28", "10.0.0.16/28"]
  public_subnets  = ["10.0.0.32/28", "10.0.0.48/28"]

  enable_nat_gateway = true

  tags = {
    project = "training_terraform"
  }
}

resource "aws_security_group" "security_group_for_launch_template" {
  vpc_id = module.training_terraform_vpc.vpc_id

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = module.training_terraform_vpc.public_subnets_cidr_blocks
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = module.training_terraform_vpc.public_subnets_cidr_blocks
  }

  tags = {
    Name    = "Terraform_security_group_for_launch_template"
    project = "training_terraform"
  }
}

resource "aws_security_group" "security_group_for_alb" {
  vpc_id = module.training_terraform_vpc.vpc_id

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "Terraform_security_group_for_alb"
    project = "training_terraform"
  }
}

resource "aws_launch_template" "terraform_launch_template" {
  name        = "terraform_launch_template"
  description = "Created by terraform. Training infrastructure"

  image_id      = "ami-08f54b258788948e1"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.security_group_for_launch_template.id]

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
  vpc_id   = module.training_terraform_vpc.vpc_id

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
  security_groups    = [aws_security_group.security_group_for_alb.id]
  subnets            = module.training_terraform_vpc.public_subnets

  enable_deletion_protection = false

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
  vpc_zone_identifier = module.training_terraform_vpc.private_subnets
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