resource "aws_instance" "vault" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"
  subnet_id     = module.vpc.public_subnets[0]
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.vault.id]
  associate_public_ip_address = true

  tags = {
    Name    = "vault"
    Project = "soraban"
  }
}

resource "aws_security_group" "vault" {
  name   = "vault-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider tightening
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}