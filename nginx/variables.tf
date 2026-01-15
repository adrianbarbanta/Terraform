variable "nginx_port" {
  description = "Portul extern pentru Nginx"
  type        = number
  default     = 30080
}

variable "tomcat_port" {
  description = "Portul extern pentru Tomcat"
  type        = number
  default     = 30081
}