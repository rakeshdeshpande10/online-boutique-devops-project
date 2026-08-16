resource "aws_vpc" "main" {
    cidr_block           = var.vpc_cidr
}

resource "aws_subnet" "public_subnet1" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.public_subnet_cidr
    availability_zone = var.availability_zone1
    map_public_ip_on_launch = true

    tags = {
        "kubernetes.io/role/elb" = "1"
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
}

resource "aws_subnet" "public_subnet2" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.public_subnet_cidr_2
    availability_zone = var.availability_zone2
    map_public_ip_on_launch = true

    tags = {
        "kubernetes.io/role/elb" = "1"
        "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
}

resource "aws_subnet" "private_subnet1" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.private_subnet_cidr
    availability_zone = var.availability_zone1

    tags = {
      "kubernetes.io/role/internal-elb" = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
}

resource "aws_subnet" "private_subnet2" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.private_subnet_cidr_2
    availability_zone = var.availability_zone2

    tags = {
      "kubernetes.io/role/internal-elb" = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
}

resource "aws_eip" "nat_eip" {
    domain = "vpc"
}

resource "aws_nat_gateway" "main" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = aws_subnet.public_subnet1.id
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.main.id
    }
}

resource "aws_route_table_association" "public1" {
    subnet_id = aws_subnet.public_subnet1.id
    route_table_id = aws_route_table.public.id

}

resource "aws_route_table_association" "public2" {
    subnet_id = aws_subnet.public_subnet2.id
    route_table_id = aws_route_table.public.id

}

resource "aws_route_table_association" "private1" {
    subnet_id = aws_subnet.private_subnet1.id
    route_table_id = aws_route_table.private.id

}

resource "aws_route_table_association" "private2" {
    subnet_id = aws_subnet.private_subnet2.id
    route_table_id = aws_route_table.private.id

}