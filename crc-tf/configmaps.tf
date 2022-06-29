resource "kubernetes_config_map_v1" "mlflow-db-config" {
  metadata {
    name = "mlflow-db-config"
    namespace = "tf-mlflow"
  }
  data = {
    PGPASSWORD        = "mlflow_pwd"
    POSTGRES_USER     = "mlflow_user"
    POSTGRES_PASSWORD = "mlflow_pwd"
    POSTGRES_DATABASE = "mlflow_db"
    PGDATA            = "/var/lib/postgresql/mlflow/data"
  }
}

resource "kubernetes_config_map_v1" "mlflow-config" {
  metadata {
    name = "mlflow-config"
    namespace = "tf-mlflow"
  }
  data = {
    MLFLOW_S3_ENDPOINT_URL =  "http://127.0.0.1:9000"
    AWS_ACCESS_KEY_ID = "**"
    AWS_SECRET_ACCESS_KEY = "**"
    MLFLOW_TRACKING_INSECURE_TLS = "true"
    MLFLOW_S3_IGNORE_TLS = "true"
  }
}