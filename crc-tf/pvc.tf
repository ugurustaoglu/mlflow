resource "kubernetes_persistent_volume_claim_v1" "mlflow-db" {
  metadata {
    name = "mlflow-db"
    namespace = "tf-mlflow"
    labels = {
      app: "mlflow"
    }
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}