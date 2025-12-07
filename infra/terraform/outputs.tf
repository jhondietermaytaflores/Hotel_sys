# -------------------------------------------------------------------
# OUTPUTS
# -------------------------------------------------------------------

output "cluster_id" {
  value = oci_containerengine_cluster.oke.id
}

output "kubeconfig_command" {
  description = "Comando para generar kubeconfig con OCI CLI"
  value       = "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.oke.id} --file $HOME/.kube/config --region ${var.region} --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT"
}