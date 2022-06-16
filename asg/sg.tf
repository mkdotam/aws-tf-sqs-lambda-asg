resource "aws_security_group" "asg_sg" {
  name   = "${var.project}-${var.env}-asg-sg"
  vpc_id = var.vpc_id

  egress {
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}
