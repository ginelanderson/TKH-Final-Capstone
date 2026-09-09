#--------AWS Provider------

provider "aws" {
    region = "us-east-1"
}

#---------VPC--------

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "TKH-Capstone-VPC"
  }
}

#-------Public Subnet-------

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "TKH-Capstone-Public-Subnet"
  }
}

#---------Internet Gateway--------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "TKH-Capstone-IGW"
  }
}

#------------Public Routing Tables-------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "TKH-Capstone-Public-Route-Table"
  }
}

#-------------Route Table Association-----------

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

#---------Security Group/ Firewall-----------

resource "aws_security_group" "web_sg" {
  name        = "TKH-Capstone-Web-SG"
  description = "Allow HTTP and restricted SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH from my public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.59.209.248/32"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TKH-Capstone-Web-SG"
  }
}


#---------- EC2 Web Server ----------

resource "aws_instance" "web" {
  ami           = "ami-0db1c5c6dc64eb019"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

    #----------Automatically install and start Apache at launch------------------
  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF
}