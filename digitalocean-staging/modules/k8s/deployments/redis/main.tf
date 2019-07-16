resource "kubernetes_config_map" "redis" {
  metadata {
    name = "redis-config"
  }

  data = {
    redis_config_file = "${file("${path.module}/redis.conf")}"
  }
}