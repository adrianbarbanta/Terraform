# 1. PROVIDE CONFIGURATION
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5"
    }
  }
}

# K8 PROVIDER
provider "kubernetes" {
  config_path = "/etc/rancher/k3s/k3s.yaml"
}

# HELM PROVIDER
provider "helm" {
  kubernetes {
    config_path = "/etc/rancher/k3s/k3s.yaml"
  }
}

# 2. NGINX MAIN PAGE CONTENT
resource "kubernetes_config_map_v1" "nginx_html" {
  metadata {
    name      = "nginx-index-html"
    namespace = "default"
  }

  data = {
    "index.html" = <<-EOT
      <html>
        <body style="background-color: #f0f0f0; font-family: sans-serif; text-align: center; margin-top: 50px;">
          <h1>DevOps Server Status: Online</h1>
          <p>${var.mesaj_site}</p>
          <hr>
          <small>Gestionat de Terraform & K3s</small>
        </body>
      </html>
    EOT
  }
}
# ---------------------------------------------------------
# NGINX COMPONENT
# ---------------------------------------------------------

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx-server"
    labels = { app = "nginx" }
  }

  spec {
    replicas = 3
    selector {
      match_labels = { app = "nginx" }
    }
    template {
      metadata { labels = { app = "nginx" } }
      spec {
        container {
          image = "nginx:latest"
          name  = "nginx-container"
          port { container_port = 80 }
          volume_mount {
            name       = "html-storage"
            mount_path = "/usr/share/nginx/html"
          }
        }
        volume {
          name = "html-storage"
          config_map {
            name = kubernetes_config_map_v1.nginx_html.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx_service" {
  metadata {
    name = "nginx-service"
  }
  spec {
    selector = {
      app = "nginx" # <--- Aici se face legatura cu labels de mai sus!
    }
    port {
      port        = 80
      target_port = 80
      node_port   = 30080
    }
    type = "NodePort"
  }
}
# ---------------------------------------------------------
# TOMCAT COMPONENT
# ---------------------------------------------------------

resource "kubernetes_deployment" "tomcat" {
  metadata {
    name = "tomcat-server"
    labels = { app = "tomcat" }
  }

  spec {
    replicas = 1
    selector {
      match_labels = { app = "tomcat" }
    }
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
      node_port   = var.tomcat_port # Folosim variabila
    }
    type = "NodePort"
  }
}
# 3. HELM INSTALLS
#K8 DASHBOARD
resource "helm_release" "k8s_dashboard" {
  name       = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"
  namespace  = "kube-system"

  set {
    name  = "service.type"
    value = "NodePort"
  }

  set {
    name  = "service.nodePort"
    value = "30443"
  }
  set {
    name  = "protocolHttp"
    value = "true"
  }
}

#K8 GRAFANA
resource "helm_release" "grafana" {
  name       = "my-grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "kube-system"
  set {
    name  = "service.type"
    value = "NodePort"
  }

  set {
    name  = "service.nodePort"
    value = "32000"
  }

  # TOTALLY WRONG AND UNSECURE
  set {
    name  = "adminPassword"
    value = "devops2024"
  }
}
