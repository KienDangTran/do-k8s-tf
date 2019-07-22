# variable "namespace" {}

# resource "kubernetes_config_map" "postgre_config" {
#   metadata {
#     name      = "postgres-config"
#     namespace = "${var.namespace}"
#     labels = {
#       app = "postgres"
#     }
#   }

#   data = {
#     config_file = "${file("${path.module}/postgresql.conf")}"
#     hba_file    = "${file("${path.module}/pg_hba.conf")}",
#   }
# }

# resource "kubernetes_config_map" "initdb_scripts" {
#   metadata {
#     name      = "initdb-scripts"
#     namespace = "${var.namespace}"
#     labels = {
#       app = "postgres"
#     }
#   }

#   data = {
#     init_auth    = "${file("${path.module}/initdb_scripts/1_init_auth.sql")}"
#     init_lottery = "${file("${path.module}/initdb_scripts/2_init_lottery.sql")}",
#     init_account = "${file("${path.module}/initdb_scripts/3_init_account.sql")}",
#     init_payment = "${file("${path.module}/initdb_scripts/4_init_payment.sql")}",
#   }
# }

# resource "kubernetes_secret" "postgres_env" {
#   metadata {
#     name      = "postgres-env"
#     namespace = "${var.namespace}"
#     labels = {
#       app = "postgres"
#     }
#   }

#   data = {
#     POSTGRES_PASSWORD    = "${base64encode("8StcOPuqTC5d")}"
#     POSTGRES_DB          = "${base64encode("3bwins")}"
#     POSTGRES_USER        = "${base64encode("postgres")}"
#     POSTGRES_INITDB_ARGS = "${base64encode("--data-checksums")}"
#   }
# }

# resource "kubernetes_persistent_volume" "pgdata" {
#   metadata {
#     name = "pgdata"
#     labels = {
#       app = "postgres"
#     }
#   }
#   spec {
#     capacity = {
#       storage = "10Gi"
#     }
#     access_modes = ["ReadWriteMany"]
#     persistent_volume_source {
#       local {
#         path = "/var/lib/postgresql/data/pgdata"
#       }
#     }
#   }
# }

# resource "kubernetes_persistent_volume_claim" "pgdata_claim" {
#   metadata {
#     name      = "pgdata-claim"
#     namespace = "${var.namespace}"
#     labels = {
#       app = "postgres"
#     }
#   }
#   spec {
#     access_modes = ["ReadWriteMany"]
#     resources {
#       requests = {
#         storage = "5Gi"
#       }
#     }
#     volume_name = "${kubernetes_persistent_volume.pgdata.metadata.0.name}"
#   }
# }

# resource "kubernetes_deployment" "postgres_deployment" {
#   metadata {
#     name      = "postgres-deployment"
#     namespace = "${var.namespace}"
#     labels = {
#       app = "postgres"
#     }
#   }

#   spec {
#     replicas = 1

#     selector {
#       match_labels = {
#         app = "postgres"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           app = "postgres"
#         }
#       }

#       spec {
#         container {
#           image             = "postgres:10.6"
#           image_pull_policy = "IfNotPresent"
#           name              = "postgres"
#           args = [
#             "-c", "config_file=/etc/postgresql/postgresql.conf",
#             "-c", "hba_file=/etc/postgresql/pg_hba.conf"
#           ]
#           env_from {
#             secret_ref {
#               name = "${kubernetes_secret.postgres_env.metadata.0.name}"
#             }
#           }
#           port {
#             container_port = 5432
#             protocol       = "TCP"
#           }
#           liveness_probe {
#             tcp_socket {
#               port = 5432
#             }
#             failure_threshold     = 3
#             initial_delay_seconds = 3
#             period_seconds        = 10
#             success_threshold     = 1
#             timeout_seconds       = 2
#           }
#           readiness_probe {
#             tcp_socket {
#               port = 5432
#             }
#             failure_threshold     = 1
#             initial_delay_seconds = 10
#             period_seconds        = 10
#             success_threshold     = 1
#             timeout_seconds       = 2
#           }
#           volume_mount {
#             mount_path = "/docker-entrypoint-initdb.d"
#             name       = "initdb-vol"
#           }
#           volume_mount {
#             mount_path = "/etc/postgresql"
#             name       = "config-files-vol"
#           }
#         }

#         volume {
#           name = "initdb-vol"
#           config_map {
#             name = "${kubernetes_config_map.initdb_scripts.metadata.0.name}"
#           }
#         }

#         volume {
#           name = "config-files-vol"
#           config_map {
#             name = "${kubernetes_config_map.postgre_config.metadata.0.name}"
#           }
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service" "postgres_service" {
#   metadata {
#     name      = "postgres-service"
#     namespace = "${var.namespace}"
#     labels = {
#       app = "postgres"
#     }
#   }
#   spec {
#     selector = {
#       app = "postgres"
#     }
#     session_affinity = "ClientIP"
#     port {
#       port        = 5432
#       target_port = 5432
#     }
#   }
# }
