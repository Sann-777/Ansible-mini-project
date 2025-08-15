variable "env" {
    default = "dev"
    type = string
}

variable "master" {
    default= "ansible-master"
    type = string
}

variable "server" {
    default= "ansible-server"
    type = string
}

variable "sg_name" {
    default= "ansible-servers-sg"
    type = string
}

variable "instance_type" {
    default = "t3.micro"
    type = string
}

variable "ami_id" {
    default = "ami-0d1b5a8c13042c939" # Ubuntu
}