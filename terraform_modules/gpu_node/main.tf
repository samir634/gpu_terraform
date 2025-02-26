resource "aws_instance" "gpu_instance" {
  count         = var.instance_count
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id

  ebs_optimized = true

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  vpc_security_group_ids = [aws_security_group.gpu_sg.id]

  user_data = var.user_data

  tags = {
    Name = "${var.instance_name}-${count.index + 1}"
  }
}

resource "aws_security_group" "gpu_sg" {
  name        = "gpu-node-sg"
  description = "Allow SSH and necessary traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
