resource "aws_db_subnet_group" "wordpress" {
  name       = "wordpress-${var.environment}-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "wordpress-${var.environment}-db-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "wordpress-${var.environment}-rds-sg"
  description = "Allow access to RDS from EKS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.eks_cluster_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "wordpress" {
  allocated_storage    = 20
  engine               = "mariadb"
  engine_version       = "11.4"  # adjust as needed
  instance_class       = "db.t4g.micro"
  db_name              = var.db_name
   identifier          = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mariadb11.4"
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.wordpress.name

  tags = {
    Environment = var.environment
  }
}

output "endpoint" {
  description = "The RDS endpoint for the database"
  value       = aws_db_instance.wordpress.address
}

output "rds_resource_id" {
  description = "The DB instance resource ID for this environment"
  value       = aws_db_instance.wordpress.id
}
