resource "aws_db_subnet_group" "subnet-group" {
    name = "victor-terraform-subnet-group"
    subnet_ids = var.subnet-id
}

resource "aws_security_group" "DB-sg" {
    vpc_id = var.vpc-id
    dynamic "ingress" {
        for_each = var.security_groups
        content {
            from_port   = 3306
            to_port     = 3306
            protocol    = "tcp"
            security_groups = [ingress.value]
        }
    }
}

resource "aws_db_instance" "victor-database" {
    allocated_storage = 20
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    username = var.username
    password = var.password
    db_subnet_group_name = aws_db_subnet_group.subnet-group.id
    vpc_security_group_ids = [aws_security_group.DB-sg.id]
    skip_final_snapshot = true
}
