# ===== Key Pairs =====

resource aws_key_pair master_key {
    key_name = "${var.master}-key"
    public_key = file("ansible-master-key.pub")

    tags = {
        Environment = var.env
    }
}

resource aws_key_pair server_key {
    key_name = "${var.server}-key"
    public_key = file("ansible-server-key.pub")

    tags = {
        Environment = var.env
    }
}

# ===== Default VPC Data Source =====

resource aws_default_vpc default {

}

# ===== Security Group for Servers =====

resource aws_security_group instance_sg {
    name = var.sg_name
    description = "This will add a TF generated SSH and HTTP access"
    vpc_id = aws_default_vpc.default.id # interpolation

    # inbound rules
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # source IPs
        description = "SSH access"
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP access"
    }

    # outbound rules
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1" # all protocols
        cidr_blocks = ["0.0.0.0/0"]
        description = "all access open"
    }

    tags = {
        Name = "ansible-sg"
    }
}

# ===== Master Instance =====

resource "aws_instance" "ansible-master" {
    
    depends_on = [ aws_security_group.instance_sg, aws_key_pair.master_key ]
    
    key_name = aws_key_pair.master_key.key_name
    security_groups = [aws_security_group.instance_sg.name]
    instance_type = var.instance_type
    ami = var.ami_id

    root_block_device {
        volume_size =  16
        volume_type = "gp3"
    }
    tags = {
        Name = var.master
        Environment = var.env
    }
}

# ===== 3 Server Instances =====

resource "aws_instance" "ansible-server" {
    count = 3
    
    depends_on = [ aws_security_group.instance_sg, aws_key_pair.server_key ]
    
    key_name = aws_key_pair.server_key.key_name
    security_groups = [aws_security_group.instance_sg.name]
    instance_type = var.instance_type
    ami = var.ami_id

    root_block_device {
        volume_size =  8
        volume_type = "gp3"
    }
    tags = {
        Name = "${var.server}-${count.index + 1}"
        Environment = var.env
    }
}