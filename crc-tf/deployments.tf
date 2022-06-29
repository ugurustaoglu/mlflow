resource "kubernetes_deployment_v1" "mlflow-db" {
  metadata {
    namespace = "tf-mlflow"
    name      = "mlflow-db"
    labels = {
      app = "mlflow"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app        = "mlflow"
        deployment = "mlflow-db"
      }
    }

    template {
      metadata {
        labels = {
          app        = "mlflow"
          deployment = "mlflow-db"
        }
      }

      spec {
        container {
          image = "postgres"
          name  = "postgresql"
          env_from {
            config_map_ref {
              name = "mlflow-db-config"
            }
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            tcp_socket {
              port = 5432
            }
            initial_delay_seconds = 3
            period_seconds        = 3
          }
          readiness_probe {
            exec {
              command = [
                "/bin/sh",
                "-i",
                "-c",
                "psql -h 127.0.0.1  -U mlflow_user -tc \"SELECT 1 FROM pg_database WHERE datname = 'mlflow_db'\" | grep -q 1 || psql -U mlflow_user -c \"CREATE DATABASE mlflow_db\""
              ]
            }
          }

          volume_mount {
            mount_path = "/var/lib/postgresql/mlflow"
            name       = "data"
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = "mlflow-db"
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment_v1" "mlflow-deployment" {
  metadata {
    namespace = "tf-mlflow"
    name      = "mlflow-deployment"
    labels = {
      app        = "mlflow"
      deployment = "mlflow-app"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app        = "mlflow"
        deployment = "mlflow-app"
      }
    }

    template {
      metadata {
        labels = {
          app        = "mlflow"
          deployment = "mlflow-app"
        }
      }

      spec {
        container {
          image = "default-route-openshift-image-registry.apps-crc.testing/mlflow/mlflow:0.0.2"
          name  = "mlflow-deployment"

          resources {
            requests = {
              cpu    = "200m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "1"
              memory = "1Gi"
            }
          }
          args = [
            "--host=0.0.0.0",
            "--port=5000",
            "--backend-store-uri=postgresql://mlflow_user:mlflow_pwd@mlflow-db.mlflow.svc.cluster.local:5432/mlflow_db",
            "--default-artifact-root=s3://mlflow/",
            "--workers=2"
          ]
          env_from {
            config_map_ref {
              name = "mlflow-config"
            }
          }
          port {
            container_port = 5000
            protocol       = "TCP"
            name           = "http"
          }
        }
      }
    }
  }
}