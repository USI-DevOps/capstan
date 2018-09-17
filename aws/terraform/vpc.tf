#
#
# Network


resource "aws_vpc" "containernet" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
     "Name", "${var.net_name}",
     "kubernetes.io/cluster/${var.gen_solution_name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.containernet.id}"

  tags {
    Name = "${var.net_name}"
  }
}


resource "aws_route_table" "rt" {
  vpc_id = "${aws_vpc.containernet.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ig.id}"
  }
}



resource "aws_subnet" "sbnet" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.containernet.id}"

  tags = "${
    map(
     "Name", "${var.gen_solution_name}-sb",
     "kubernetes.io/cluster/${var.gen_solution_name}", "shared",
    )
  }"
}

resource "aws_route_table_association" "rta" {
  count = 2

  subnet_id      = "${aws_subnet.sbnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.rt.id}"
}