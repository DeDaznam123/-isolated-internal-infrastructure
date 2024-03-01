resource "aws_route_table" "rt" {
  vpc_id = "${var.vpc-id}"
  dynamic "route" {
    for_each = "${var.use-internet-gateway}" ? [1] : []
    content {
        cidr_block = "${var.cidr-block}"
        gateway_id = "${var.IG-id}"
    }
  }
  dynamic "route" {
    for_each = "${var.use-internet-gateway}" ? [] : [1]
    content {
        cidr_block = "${var.cidr-block}"
        nat_gateway_id = "${var.NG-id}"
    }
  }
  tags = {
    Name = "${var.name}"
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id = "${var.subnet-id}"
  route_table_id = aws_route_table.rt.id
  depends_on = [ aws_route_table.rt ]
}
