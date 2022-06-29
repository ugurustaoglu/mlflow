resource "kubernetes_service" "mlflow-db" {
  metadata {
    name = "mlflow-db"
    namespace = "tf-mlflow"
  }
  spec {
    selector = {
      app: "mlflow"
      deployment: "mlflow-db"
    }
    port {
      name = "5432-tcp"
      protocol = "TCP"
      port = "5432"
      target_port = "5432"
    }
  }
}

resource "kubernetes_service" "mlflow-service" {
  metadata {
    name = "mlflow-service"
    namespace = "tf-mlflow"
  }
  spec {
    selector = {
      app: "mlflow"
      deployment: "mlflow-app"
    }
    port {
      port = "5000"
      target_port = "5000"
      protocol = "TCP"
      name = "5000-tcp"
    }
  }
}