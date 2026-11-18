output "instance_id" {
  description = "EC2 instance identifier."
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IPv4 address. AWS charges for public IPv4 while allocated."
  value       = aws_instance.web.public_ip
}

output "website_url" {
  description = "Demonstration website URL."
  value       = "http://${aws_instance.web.public_ip}"
}

output "node_exporter_target" {
  description = "Prometheus Node Exporter target. Access is restricted by monitoring_cidr."
  value       = "${aws_instance.web.public_ip}:9100"
}
