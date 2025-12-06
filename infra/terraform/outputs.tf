output "kubeconfig" {
  description = "Comando para obtener kubeconfig vía OCI CLI (referencia)"
  value       = "oci ce cluster create-kubeconfig --cluster-id ${module.oke.cluster_id} --file $HOME/.kube/config --region ${var.region} --token-version 2.0.0"
}

output "cluster_id" {
  value = module.oke.cluster_id
}
