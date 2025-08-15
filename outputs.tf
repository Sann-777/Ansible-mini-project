output "master_private_ip" {
    value = aws_instance.ansible-master.private_ip
}

output "master_public_ip" {
    value = aws_instance.ansible-master.public_ip
}

output "master_public_dns" {
    value = aws_instance.ansible-master.public_dns
}

output "server_private_ip" {
    value = aws_instance.ansible-server[*].private_ip
}

output "server_public_ip" {
    value = aws_instance.ansible-server[*].public_ip
}

output "server_public_dns" {
    value = aws_instance.ansible-server[*].public_dns
}