output "instance_names_and_ips" {
  description = "Names and public IPs of the EC2 instances"
  value = "${aws_instance.instance.tags["Name"]}: ${aws_instance.instance.public_ip}"
}