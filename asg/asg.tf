resource "aws_placement_group" "this" {
  name     = "${var.project}-${var.env}"
  strategy = "spread"
}

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.project}-${var.env}-ec2-asg-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

data "aws_iam_policy" "ssm" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm-attachment" {
  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.ssm.arn
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.project}-${var.env}-ec2-asg-instance-profile"
  role = aws_iam_role.this.name
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.project}-${var.env}-launch-tpl"
  image_id      = "ami-0d70546e43a941d70"
  instance_type = "t3.micro"

  iam_instance_profile {
    arn = aws_iam_instance_profile.this.arn
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.project}-${var.env}-test"
  max_size                  = 5
  min_size                  = 0
  desired_capacity          = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  placement_group           = aws_placement_group.this.id
  vpc_zone_identifier       = var.subnets

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  timeouts {
    delete = "1m"
  }

}