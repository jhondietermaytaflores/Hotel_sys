output "cluster_id" {
  description = "OCID del cluster OKE"
  value       = module.oke.cluster_id
}

output "kubeconfig_command" {
  description = "Comando sugerido para generar kubeconfig vía OCI CLI"
  value       = "oci ce cluster create-kubeconfig --cluster-id ${module.oke.cluster_id} --file $HOME/.kube/config --region ${var.region} --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT"
}