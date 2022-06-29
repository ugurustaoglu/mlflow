resource "kubernetes_ingress_v1" "mlflow-ingress" {
  metadata {
    name      = "mlflow-ingress"
    namespace = "tf-mlflow"
  }

  spec {
    rule {
      host = "tf-mlflow-test.apps-crc.testing"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "mlflow-service"
              port {
                number = 5000
              }
            }
          }
        }

      }
    }

  }
}
