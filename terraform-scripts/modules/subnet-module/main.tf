resource "aws_subnet" "subnet" {
    vpc_id = "${var.vpc-id}"
    map_public_ip_on_launch = "${var.map-public-ip-on-launch}"
    cidr_block = "${var.cidr-block}"
    tags = {
        Name = "${var.name}"
    }
}