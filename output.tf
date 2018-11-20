output "ec2_address" {
  value = "${aws_instance.ec2_ubuntu.public_dns}"
}