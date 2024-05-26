output "instance_id" {
    value = aws_instance.ec2-instance.id
}
output "security-group-id" {
    value = aws_security_group.sg.id
}
