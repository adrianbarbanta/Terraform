terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

provider "kubernetes" {
  # Calea către fișierul de configurare K3s de pe VM-ul tău
  config_path = "/etc/rancher/k3s/k3s.yaml"
}

# ---------------------------------------------------------
# 1. COMPONENTA NGINX
# ---------------------------------------------------------

resource "kubernetes_deployment" "nginx" {
  metadata { name = "nginx-server" }
  spec {
    replicas = 1
    selector { match_labels = { app = "nginx" } }
    template {
      metadata { labels = { app = "nginx" } }
      spec {
        container {
          image = "nginx:latest"
          name  = "nginx-container"
          port { container_port = 80 }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx_service" {
  metadata { name = "nginx-service" }
  spec {
    selector = { app = "nginx" }
    port {
      port        = 80
      target_port = 80
      node_port   = 30080 # Accesibil pe portul 30080
    }
    type = "NodePort"
  }
}

# ---------------------------------------------------------
# 2. COMPONENTA TOMCAT
# ---------------------------------------------------------

resource "kubernetes_deployment" "tomcat" {
  metadata { name = "tomcat-server" }
  spec {
    replicas = 1
    selector { match_labels = { app = "tomcat" } }
    template {
      metadata { labels = { app = "tomcat" } }
      spec {
        container {
          image = "tomcat:9.0-jdk11-openjdk"
          name  = "tomcat-container"
          port { container_port = 8080 }
        }
      }
    }
  }
}

resource "kubernetes_service" "tomcat_service" {
  metadata { name = "tomcat-service" }
  spec {
    selector = { app = "tomcat" }
    port {
      port        = 8080
      target_port = 8080
      node_port   = 30081 # Accesibil pe portul 30081
    }
    type = "NodePort"
  }
}