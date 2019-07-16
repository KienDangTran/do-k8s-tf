output "cluster_master_ipv4" {
  value       = "${digitalocean_kubernetes_cluster.staging_3bwins.ipv4_address}"
  description = "The public IPv4 address of the Kubernetes master node"
}
