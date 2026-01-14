output "container_id" {
  description = "ID-ul containerului Nginx"
  value       = docker_container.nginx_test.id
}

output "web_url" {
  description = "Adresa la care poti accesa serverul"
  value       = "http://localhost:${var.external_port}"
}