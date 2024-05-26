resource "aws_security_group" "sg" {
    vpc_id = var.vpc-id
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "SSH"
    }
   
    dynamic "ingress" {
        for_each = var.ingress-rules
        content {
            from_port   = ingress.value.from_port
            to_port     = ingress.value.to_port
            protocol    = ingress.value.protocol
            cidr_blocks = ingress.value.cidr_blocks
            description = ingress.value.description
        }
    }
}

resource "aws_instance" "ec2-instance" {
    ami           = var.ami
    instance_type = var.instance-type
    key_name      = var.key-name
    security_groups = [aws_security_group.sg.id]
    subnet_id = var.subnet-id
    root_block_device {
        volume_size = var.volume-size
        volume_type = var.volume-type
    }
    tags = {
        Name = var.name
    }
    user_data = var.user-data
    depends_on = [aws_security_group.sg]
}
