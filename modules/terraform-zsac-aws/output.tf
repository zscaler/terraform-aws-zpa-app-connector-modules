output "private_ip" {
  value = aws_instance.ac-vm.*.private_ip
}

output availability_zone {
  value = aws_instance.ac-vm.*.availability_zone
}

output "id" {
  value = aws_instance.ac-vm.*.id
}