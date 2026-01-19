variable "nginx_port" {
  description = "External Nginx Port"
  type        = number
  default     = 30080
}

variable "tomcat_port" {
  description = "External Tomcat Port"
  type        = number
  default     = 30081
}

variable "mesaj_site" {
  description = "Main page text"
  type        = string
  default     = "HELLO! This is my Terraform page"
}
