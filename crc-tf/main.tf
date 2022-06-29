provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "crc-admin"
}

resource "kubernetes_namespace" "tf-mlflow" {
  metadata {
    name = "tf-mlflow"
  }
}